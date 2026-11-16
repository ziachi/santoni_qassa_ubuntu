#!/system/bin/sh
#
# init.ubuntu.sh — bring up the Ubuntu chroot as a 24/7 VPS.
#
# Started by init.ubuntu.rc from `on boot`, so /data is already decrypted and
# mounted. Android's own boot is deliberately not waited for: the framework is
# stopped below, so sys.boot_completed would never arrive.

UBUNTU_ROOT=/data/ubuntu
ZRAM_DEV=/dev/block/zram0
ZRAM_BYTES=2147483648
WAKE_LOCK=vps_server_lock

log() {
    echo "vps-boot: $*"
}

# init sends a service's stdout to /dev/null, so nothing this script prints is
# visible after boot and a failed bring-up leaves no trace. Keep a copy on
# /data, capped so it cannot grow without bound across reboots.
BOOT_LOG=/data/ubuntu-boot.log
if [ -f "$BOOT_LOG" ]; then
    _size=$(wc -c < "$BOOT_LOG" 2>/dev/null)
    [ "${_size:-0}" -gt 65536 ] && : > "$BOOT_LOG"
fi
exec >>"$BOOT_LOG" 2>&1
log "=== boot $(date) ==="

# --- 1. Anti deep-sleep --------------------------------------------------
# A held wake lock keeps the SoC out of suspend so sshd stays reachable.
if [ -w /sys/power/wake_lock ]; then
    if echo "$WAKE_LOCK" > /sys/power/wake_lock 2>/dev/null; then
        log "wake lock '$WAKE_LOCK' held"
    else
        log "could not take wake lock '$WAKE_LOCK'"
    fi
else
    log "no /sys/power/wake_lock, skipping"
fi

# --- 2. ZRAM 2 GB --------------------------------------------------------
# fstab.qcom already asks for zramsize=2147483648, so normally this is only a
# check. It reconfigures when the running size differs, which is what happens
# on a device that booted with the old 1 GB fstab.
if [ -e "$ZRAM_DEV" ]; then
    current=$(cat /sys/block/zram0/disksize 2>/dev/null)
    if [ "$current" != "$ZRAM_BYTES" ]; then
        log "zram0 is ${current:-unknown} bytes, resizing to $ZRAM_BYTES"
        swapoff "$ZRAM_DEV" 2>/dev/null
        echo 1 > /sys/block/zram0/reset 2>/dev/null
        echo "$ZRAM_BYTES" > /sys/block/zram0/disksize 2>/dev/null
        mkswap "$ZRAM_DEV" >/dev/null 2>&1
    fi
    if grep -q "^$ZRAM_DEV " /proc/swaps 2>/dev/null; then
        log "zram0 swap already active"
    elif swapon "$ZRAM_DEV" 2>/dev/null; then
        log "zram0 swap active"
    else
        log "could not swapon $ZRAM_DEV"
    fi
else
    log "no $ZRAM_DEV, skipping swap"
fi

# --- 3. ADB Wi-Fi password -----------------------------------------------
# ubuntu-enter falls back to "santoniadmin" when the file is missing, but
# creating it here makes the default explicit and puts the 0600 root:root mode
# in place from the first boot instead of leaving the password readable. This
# runs before the chroot check so a device without Ubuntu still gets the file.
PASS_FILE=/data/adb_wifi_pass
if [ ! -s "$PASS_FILE" ]; then
    if echo "santoniadmin" > "$PASS_FILE" 2>/dev/null; then
        log "created $PASS_FILE with the default password"
    else
        log "could not create $PASS_FILE"
    fi
fi
if [ -e "$PASS_FILE" ]; then
    chmod 600 "$PASS_FILE" 2>/dev/null
    chown 0:0 "$PASS_FILE" 2>/dev/null
fi

# --- 4. True headless: stop the graphics stack and the Java runtime ------
# The device is a VPS: nothing draws, so SurfaceFlinger, the HWC and both
# zygotes are pure RAM cost. Stopping them frees roughly 300 MB and makes
# scrcpy impossible. adbd, netd, wpa_supplicant and the chroot's sshd are
# native services and keep running.
#
# SurfaceFlinger goes first: its service definition carries
# `onrestart restart zygote`, and a stop does not fire onrestart, but stopping
# zygote first would leave SurfaceFlinger running against a dead client.
for svc in surfaceflinger vendor.hwcomposer-2-1 zygote zygote_secondary; do
    stop "$svc" 2>/dev/null
done
sleep 1
for svc in surfaceflinger vendor.hwcomposer-2-1 zygote zygote_secondary; do
    log "$svc: $(getprop init.svc.$svc)"
done

# --- 4b. Native services a VPS has no use for ----------------------------
# Camera, radio and the media stack are the largest things left after the
# framework goes: qcamerasvr 36 MB, the two rild 56 MB, audioserver 27 MB,
# mediaextractor 23 MB, media.swcodec 20 MB, the audio HAL 18 MB, mediaserver
# 17 MB and cameraserver 15 MB -- about 210 MB of RSS between them. Nothing in
# the chroot touches any of them, and with zygote gone nothing will ask for
# them again, so stop them once instead of leaving them resident. `stop` also
# keeps init from restarting them, which a kill would not.
for svc in qcamerasvr cameraserver ril-daemon ril-daemon2 \
           vendor.audio-hal-2-0 audioserver media mediaextractor \
           media.swcodec; do
    stop "$svc" 2>/dev/null
done

# The panel keeps the last frame after SurfaceFlinger stops, so blank the
# backlight as well.
if [ -w /sys/class/leds/lcd-backlight/brightness ]; then
    echo 0 > /sys/class/leds/lcd-backlight/brightness 2>/dev/null \
        && log "backlight off"
fi

# --- 5. Wi-Fi without the framework --------------------------------------
# Zygote is gone, so `cmd wifi` and `svc wifi` no longer exist. wpa_supplicant
# is a native init service and survives, and /system/bin/wifi drives it
# directly. The link itself does not survive: wificond's ClientInterfaceImpl
# destructor runs when its client (system_server) dies and calls
# SetUpState(false), which takes wlan0 down. So the interface is brought back
# up and the saved network re-selected, then udhcpc takes over the lease.
wlan_ip() {
    ip -4 addr show wlan0 2>/dev/null \
        | sed -n 's/.*inet \([0-9.]*\).*/\1/p' | head -1
}

# The bring-up runs in the background, after sshd is listening (see the end of
# this script). A router that is off at boot makes `wifi reconnect` burn its
# 20 s supplicant wait plus its 30 s association wait, and `wait_ip` another
# 45 s; none of that may hold up the rest of the boot.
wifi_bringup() {
    if [ ! -x /system/bin/wifi ]; then
        log "no /system/bin/wifi, skipping Wi-Fi bring-up"
        return 0
    fi
    ip link set wlan0 up 2>/dev/null
    if [ -s /data/vps_wifi.conf ]; then
        /system/bin/wifi reconnect
    else
        log "no /data/vps_wifi.conf, run vps-setup to join a network"
    fi
    /system/bin/wifi dhcp
    _ip=$(wlan_ip)
    log "wlan0 ${_ip:-no address}"

    # Android routes unmarked traffic through the main table, which holds only
    # the local subnet plus an `unreachable default`. Processes inside the
    # chroot are unmarked, so without a real default route in main every
    # outbound packet dies with ENETUNREACH and DNS fails no matter which
    # resolver is configured. Copy the gateway netd put in the wlan0 table
    # into main.
    # udhcpc normally installed this route already; the wait covers a device
    # whose Wi-Fi section could not run, and the add is skipped when the route
    # is there.
    _route_try=0
    while [ $_route_try -lt 30 ]; do
        GW=$(ip route show table all 2>/dev/null | awk '/^default via/ && /dev wlan0/ {print $3; exit}')
        if [ -n "$GW" ]; then
            if ! ip route show 2>/dev/null | grep -q '^default via'; then
                ip route add default via "$GW" dev wlan0 2>/dev/null \
                    && log "default route -> $GW"
            fi
            break
        fi
        _route_try=$((_route_try + 1))
        sleep 2
    done

    # udhcpc's hook writes resolv.conf from the lease, which is the
    # authoritative answer and is refreshed on every renewal. Only build one
    # here when the hook never ran, which is the case on a device with no
    # saved network. The directory check keeps a device without Ubuntu from
    # logging a redirect error.
    if [ -d "$UBUNTU_ROOT/etc" ] && [ ! -s "$UBUNTU_ROOT/etc/resolv.conf" ]; then
        # Keep every address netd lists, IPv6 included, in netd's order.
        # Filtering down to IPv4 silently drops the IPv6 resolver, and glibc
        # tries the entries in sequence, so the order netd chose is the one to
        # keep.
        DNS_LIST=$(dumpsys connectivity 2>/dev/null \
            | sed -n 's/.*DnsAddresses: \[\([^]]*\)\].*/\1/p' \
            | grep -v '^ *$' | head -1 \
            | tr ',' '\n' | tr -d ' /' | grep -v '^$')
        [ -n "$DNS_LIST" ] || DNS_LIST=$(getprop net.dns1 2>/dev/null)
        [ -n "$DNS_LIST" ] || DNS_LIST=$(ip route show table all 2>/dev/null | awk '/^default/ {print $3; exit}')
        if [ -z "$DNS_LIST" ]; then
            # Android keeps the default route in a per-network table that
            # toybox `ip route` does not print, so derive the router from the
            # subnet.
            IP=$(ip -4 addr show wlan0 2>/dev/null | awk '/inet / {print $2; exit}' | cut -d/ -f1)
            [ -n "$IP" ] && DNS_LIST=$(echo "$IP" | awk -F. '{print $1"."$2"."$3".1"}')
        fi
        if [ -n "$DNS_LIST" ]; then
            {
                for ns in $DNS_LIST; do echo "nameserver $ns"; done
                echo "nameserver 8.8.8.8"
                echo "nameserver 223.5.5.5"
            } > "$UBUNTU_ROOT/etc/resolv.conf"
            log "resolv.conf -> $(echo $DNS_LIST)"
        fi
    fi
}

# --- 6. Ubuntu chroot ----------------------------------------------------
if [ ! -x "$UBUNTU_ROOT/bin/bash" ]; then
    log "no Ubuntu at $UBUNTU_ROOT — run vps-setup over USB"
    wifi_bringup &
    exit 0
fi

# toybox mount takes the -o forms; util-linux takes --rbind/--make-rslave.
# Probe once so the same script works on either, and fall back to busybox when
# the built-in mount understands neither.
MOUNT_STYLE=short
if mount --help 2>&1 | grep -q -- "--rbind"; then
    MOUNT_STYLE=long
elif command -v busybox >/dev/null 2>&1 && ! mount --help 2>&1 | grep -q "rbind"; then
    MOUNT_STYLE=busybox
fi
log "mount syntax: $MOUNT_STYLE"

rbind() {
    case "$MOUNT_STYLE" in
        long)    mount --rbind "$1" "$2" ;;
        busybox) busybox mount -o rbind "$1" "$2" ;;
        *)       mount -o rbind "$1" "$2" ;;
    esac
}

make_rslave() {
    case "$MOUNT_STYLE" in
        long)    mount --make-rslave "$1" ;;
        busybox) busybox mount -o rslave "$1" ;;
        *)       mount -o rslave "$1" ;;
    esac
}

# /dev is rbind-mounted, not bind-mounted. ueventd keeps creating nodes after
# boot (/dev/video*, /dev/snd/*, /dev/input/*), and a plain bind would freeze
# the chroot's view at the moment of the mount. --make-rslave stops an unmount
# inside the chroot from propagating back into Android's /dev.
mkdir -p "$UBUNTU_ROOT/dev"
if grep -q " $UBUNTU_ROOT/dev " /proc/mounts 2>/dev/null; then
    log "/dev already mounted in chroot"
elif rbind /dev "$UBUNTU_ROOT/dev" 2>/dev/null; then
    make_rslave "$UBUNTU_ROOT/dev"
    log "rbind-mounted /dev (rslave)"
else
    log "could not rbind /dev"
fi

# The rbind above normally brings /dev/pts with it. Mount a fresh devpts only
# when it did not, otherwise the chroot ends up with two devpts instances and
# pty allocation breaks.
mkdir -p "$UBUNTU_ROOT/dev/pts"
if grep -q " $UBUNTU_ROOT/dev/pts " /proc/mounts 2>/dev/null; then
    log "/dev/pts already mounted in chroot"
elif mount -t devpts devpts "$UBUNTU_ROOT/dev/pts" \
        -o mode=0620,ptmxmode=0666,gid=5 2>/dev/null \
        || mount -t devpts devpts "$UBUNTU_ROOT/dev/pts" 2>/dev/null; then
    log "mounted devpts"
else
    log "could not mount devpts"
fi

mkdir -p "$UBUNTU_ROOT/proc"
if grep -q " $UBUNTU_ROOT/proc " /proc/mounts 2>/dev/null; then
    log "/proc already mounted in chroot"
elif mount -t proc proc "$UBUNTU_ROOT/proc" 2>/dev/null; then
    log "mounted /proc"
else
    log "could not mount /proc"
fi

mkdir -p "$UBUNTU_ROOT/sys"
if grep -q " $UBUNTU_ROOT/sys " /proc/mounts 2>/dev/null; then
    log "/sys already mounted in chroot"
elif mount -t sysfs sysfs "$UBUNTU_ROOT/sys" 2>/dev/null; then
    log "mounted /sys"
else
    log "could not mount /sys"
fi

# sshd refuses to start without /run/sshd, and apt needs a writable /tmp.
mkdir -p "$UBUNTU_ROOT/tmp" "$UBUNTU_ROOT/run/sshd"
chmod 1777 "$UBUNTU_ROOT/tmp" 2>/dev/null
chmod 0755 "$UBUNTU_ROOT/run/sshd" 2>/dev/null

if [ -x "$UBUNTU_ROOT/usr/sbin/sshd" ]; then
    # `service ssh start` goes through the Debian init script, which expects
    # systemd and fails silently in a chroot. Generate any missing host keys
    # and run sshd directly instead.
    # /run lives on /data, so /run/sshd.pid survives a reboot and can name a
    # PID that now belongs to an unrelated process. Clear it first so nothing
    # mistakes the previous daemon for a running one.
    rm -f "$UBUNTU_ROOT/run/sshd.pid"
    # sshd's own stderr is kept: it is the only place that says why a start
    # failed, and it now lands in $BOOT_LOG.
    if chroot "$UBUNTU_ROOT" /bin/sh -c \
            'export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
             export TMPDIR=/tmp
             mkdir -p /run/sshd && chmod 0755 /run/sshd
             ssh-keygen -A
             /usr/sbin/sshd'; then
        log "sshd started"
    else
        log "sshd failed to start"
    fi
    sleep 1
    if netstat -tln 2>/dev/null | grep -q ':22 '; then
        log "sshd listening on :22"
    else
        log "sshd is NOT listening on :22"
    fi
else
    log "openssh-server not installed — apt install -y openssh-server"
fi

# --- 7. Wi-Fi, in the background -----------------------------------------
# sshd is listening by now, so the device becomes reachable the moment the
# link comes up. Running the bring-up here keeps a dead router from delaying
# anything else: the script returns and init marks the service done while
# wpa_cli and udhcpc work through their own timeouts.
wifi_bringup &
log "Wi-Fi bring-up running in the background (pid $!)"
