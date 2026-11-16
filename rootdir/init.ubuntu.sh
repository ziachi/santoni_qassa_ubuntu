#!/system/bin/sh
#
# init.ubuntu.sh — bring up the Ubuntu chroot as a 24/7 VPS.
#
# Started by init.ubuntu.rc once sys.boot_completed=1, so Android has already
# finished booting and /data is decrypted and mounted.

UBUNTU_ROOT=/data/ubuntu
ZRAM_DEV=/dev/block/zram0
ZRAM_BYTES=2147483648
WAKE_LOCK=vps_server_lock

log() {
    echo "vps-boot: $*"
}

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

# --- 4. Ubuntu chroot ----------------------------------------------------
if [ ! -x "$UBUNTU_ROOT/bin/bash" ]; then
    log "no Ubuntu at $UBUNTU_ROOT — run vps-setup over USB"
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
elif mount -t devpts devpts "$UBUNTU_ROOT/dev/pts" 2>/dev/null; then
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

# The chroot keeps its own resolv.conf and the gateway changes when the
# device moves networks, so refresh it from the current default route.
# Android resolves through netd and has no resolv.conf to copy. The resolver
# the framework actually uses is the only one known to work on this network,
# so read it out of dumpsys first. The gateway is not a reliable fallback: on
# the santoni test network it routes but does not answer DNS.
# Android routes unmarked traffic through the main table, which holds only the
# local subnet plus an `unreachable default`. Processes inside the chroot are
# unmarked, so without a real default route in main every outbound packet dies
# with ENETUNREACH and DNS fails no matter which resolver is configured. Copy
# the gateway netd put in the wlan0 table into main.
# Wi-Fi comes up after this script runs, so wait for the gateway to appear.
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

DNS=$(dumpsys connectivity 2>/dev/null \
    | sed -n 's/.*DnsAddresses: \[\([^]]*\)\].*/\1/p' \
    | tr ',' '\n' | grep -o '[0-9]\{1,3\}\(\.[0-9]\{1,3\}\)\{3\}' | head -1)
[ -n "$DNS" ] || DNS=$(getprop net.dns1 2>/dev/null)
[ -n "$DNS" ] || DNS=$(ip route show table all 2>/dev/null | awk '/^default/ {print $3; exit}')
if [ -z "$DNS" ]; then
    # Android keeps the default route in a per-network table that toybox
    # `ip route` does not print, so derive the router from the subnet.
    IP=$(ip -4 addr show wlan0 2>/dev/null | awk '/inet / {print $2; exit}' | cut -d/ -f1)
    [ -n "$IP" ] && DNS=$(echo "$IP" | awk -F. '{print $1"."$2"."$3".1"}')
fi
if [ -n "$DNS" ]; then
    printf 'nameserver %s\nnameserver 8.8.8.8\nnameserver 223.5.5.5\n' "$DNS" \
        > "$UBUNTU_ROOT/etc/resolv.conf"
    log "resolv.conf -> $DNS"
fi

if [ -x "$UBUNTU_ROOT/usr/sbin/sshd" ]; then
    # `service ssh start` goes through the Debian init script, which expects
    # systemd and fails silently in a chroot. Generate any missing host keys
    # and run sshd directly instead.
    if chroot "$UBUNTU_ROOT" /bin/sh -c \
            'export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
             mkdir -p /run/sshd && chmod 0755 /run/sshd
             ssh-keygen -A >/dev/null 2>&1
             /usr/sbin/sshd' >/dev/null 2>&1; then
        log "sshd started"
    else
        log "sshd failed to start"
    fi
else
    log "openssh-server not installed — apt install -y openssh-server"
fi
