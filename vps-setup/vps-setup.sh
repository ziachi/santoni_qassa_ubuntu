#!/system/bin/sh
# Copyright (c) 2026 ziachi - https://github.com/ziachi/santoni_qassa_ubuntu
#
# vps-setup — one-shot first-time setup for the headless santoni VPS.
#
#   adb shell vps-setup <SSID> <WIFI_PASSWORD>
#
# Joins the Wi-Fi network, downloads the Ubuntu 22.04 arm64 base rootfs,
# unpacks it into /data/ubuntu, prepares it for chroot, seeds the ADB-over-Wi-Fi
# password file and installs openssh-server inside the chroot. Run it over USB:
# the Wi-Fi password gate in ubuntu-enter does not apply to a USB session.

set -u

SSID=${1:-}
WIFI_PASS=${2:-}

UBUNTU_ROOT=/data/ubuntu
TARBALL=/data/local/tmp/ubuntu-base.tar.gz
PRIMARY_URL=https://cdimage.ubuntu.com/ubuntu-base/releases/22.04/release/ubuntu-base-22.04-base-arm64.tar.gz
FALLBACK_URL=https://cdimage.ubuntu.com/ubuntu-base/releases/22.04.5/release/ubuntu-base-22.04.5-base-arm64.tar.gz
CACERT_DIR=/system/etc/security/cacerts
BB=/system/bin/busybox

die() {
    echo "vps-setup: $*" >&2
    exit 1
}

[ -n "$SSID" ] || die "usage: vps-setup <SSID> <PASSWORD>"
[ -n "$WIFI_PASS" ] || die "usage: vps-setup <SSID> <PASSWORD>"

# ---------------------------------------------------------------- 1. Wi-Fi
echo "[1/7] Joining Wi-Fi: $SSID"

# `svc wifi` and `cmd wifi` both go through system_server, which is stopped at
# boot (see rootdir/init.ubuntu.sh). /system/bin/wifi drives wpa_supplicant and
# udhcpc directly, so it works with the framework down.
/system/bin/wifi connect "$SSID" "$WIFI_PASS" || die "could not join $SSID"

echo "[2/7] Waiting for an IP address"
ip_addr=""
i=0
while [ "$i" -lt 45 ]; do
    ip_addr=$(ip -4 addr show wlan0 2>/dev/null | sed -n 's/.*inet \([0-9.]*\).*/\1/p' | head -1)
    [ -n "$ip_addr" ] && break
    sleep 1
    i=$((i + 1))
done
[ -n "$ip_addr" ] || die "no IP on wlan0, check SSID/password"
echo "      wlan0 = $ip_addr"

# ------------------------------------------------------------- 2. Download
echo "[3/7] Downloading the Ubuntu rootfs"

# curl is built into the image from the in-tree external/curl module, so the
# rootfs is fetched on the device. --capath points libcurl at the platform CA
# store, which is an OpenSSL-style hashed directory.
# netd owns DNS for bionic and only learns resolvers from the framework, which
# is stopped here, so getaddrinfo() fails even with the link up. busybox
# nslookup builds its own DNS packets, so it still answers.
resolve() {
    for ns in $(cat /data/vps_dns 2>/dev/null) 8.8.8.8 223.5.5.5; do
        addr=$("$BB" nslookup "$1" "$ns" 2>/dev/null \
            | sed -n 's/^Address[ 0-9]*: *//p' | grep -v ':' | head -1)
        if [ -n "$addr" ]; then
            echo "$addr"
            return 0
        fi
    done
    return 1
}

fetch() {
    url=$1
    host=$(echo "$url" | sed -n 's|^[a-z]*://\([^/]*\).*|\1|p')
    rm -f "$TARBALL"
    if command -v curl >/dev/null 2>&1; then
        set -- -fsSL -o "$TARBALL"
        [ -d "$CACERT_DIR" ] && set -- "$@" --capath "$CACERT_DIR"
        addr=$(resolve "$host")
        [ -n "$addr" ] && set -- "$@" --resolve "$host:443:$addr"
        curl "$@" "$url"
    elif command -v wget >/dev/null 2>&1; then
        wget -q -O "$TARBALL" "$url"
    elif toybox wget --help >/dev/null 2>&1; then
        toybox wget -q -O "$TARBALL" "$url"
    else
        return 127
    fi
}

# A tarball pushed from the PC is used as-is. The failure path below tells the
# user to push one, so the download must not delete it first.
if [ -s "$TARBALL" ]; then
    echo "      using the tarball already at $TARBALL"
else
    if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1 \
            && ! toybox wget --help >/dev/null 2>&1; then
        echo "vps-setup: no downloader on the device (no curl, wget, or toybox wget)." >&2
        echo "  Push the rootfs from the PC:" >&2
        echo "    adb push ubuntu-base-22.04-base-arm64.tar.gz $TARBALL" >&2
        echo "    adb shell vps-setup $SSID <password>" >&2
        exit 1
    fi

    # An IP on wlan0 does not mean netd can resolve yet: right after DHCP the
    # network reports AVAILABLE with an empty DnsAddresses list, and curl fails
    # instantly with "Could not resolve host" if it runs inside that window.
    # Retry rather than giving up on the first attempt.
    attempt=0
    while :; do
        attempt=$((attempt + 1))
        if fetch "$PRIMARY_URL" || fetch "$FALLBACK_URL"; then
            break
        fi
        if [ "$attempt" -ge 6 ]; then
            echo
            echo "vps-setup: could not download the rootfs after $attempt attempts." >&2
            echo "  'Could not resolve host' means DNS on the device is broken, not" >&2
            echo "  the mirror. Check with: ping -c1 cdimage.ubuntu.com" >&2
            echo "  Or push the rootfs from the PC:" >&2
            echo "    adb push ubuntu-base-22.04-base-arm64.tar.gz $TARBALL" >&2
            echo "    adb shell vps-setup $SSID <password>" >&2
            exit 1
        fi
        echo "      download failed, retrying in 5s ($attempt/6)"
        sleep 5
    done
fi

[ -s "$TARBALL" ] || die "download produced an empty file"
echo "      $(du -h "$TARBALL" | cut -f1) in $TARBALL"

# -------------------------------------------------------------- 3. Extract
echo "[4/7] Extracting into $UBUNTU_ROOT"
mkdir -p "$UBUNTU_ROOT" || die "cannot create $UBUNTU_ROOT"
tar -xzf "$TARBALL" -C "$UBUNTU_ROOT" || die "tar failed"
[ -x "$UBUNTU_ROOT/bin/bash" ] || die "rootfs has no /bin/bash"

for d in dev dev/pts proc sys tmp run; do
    mkdir -p "$UBUNTU_ROOT/$d"
done

# A `wifi` command inside the chroot, so the VPS can rejoin a network without
# adb. It chroots back into Android's root because the script uses absolute
# /system and /vendor paths that do not exist inside Ubuntu.
mkdir -p "$UBUNTU_ROOT/usr/local/bin"
cat > "$UBUNTU_ROOT/usr/local/bin/wifi" <<'WRAPPER'
#!/bin/sh
# Run the Android-side Wi-Fi CLI from inside the chroot. /proc has to be
# mounted (init.ubuntu.sh does it on every boot) because /proc/1/root is how
# the Android root is reached from here.
if [ ! -d /proc/1/root/system/bin ]; then
    echo "wifi: /proc is not mounted in the chroot" >&2
    exit 1
fi
exec /usr/sbin/chroot /proc/1/root /system/bin/wifi "$@"
WRAPPER
chmod 0755 "$UBUNTU_ROOT/usr/local/bin/wifi"

# ------------------------------------------------------------- 4. Network
echo "[5/7] Writing resolv.conf and apt sources"

# Android routes unmarked traffic through the main table, which holds only the
# local subnet plus an `unreachable default`. Processes inside the chroot are
# unmarked, so without a real default route in main every outbound packet dies
# with ENETUNREACH and DNS fails no matter which resolver is configured. Copy
# the gateway netd put in the wlan0 table into main.
GW=$(ip route show table all 2>/dev/null | awk '/^default via/ && /dev wlan0/ {print $3; exit}')
if [ -n "$GW" ] && ! ip route show 2>/dev/null | grep -q '^default via'; then
    ip route add default via "$GW" dev wlan0 2>/dev/null \
        && echo "      default route -> $GW"
fi

# Android resolves through netd and has no resolv.conf to copy, so read the
# resolvers out of dumpsys first and fall back to the gateway only when that
# yields nothing.
# Keep every address netd lists, IPv6 included, in netd's order. Filtering
# down to IPv4 silently drops the IPv6 resolver, and glibc tries the entries
# in sequence, so the order netd chose is the one to keep.
# The DHCP lease is the only thing that still knows the real resolvers: dumpsys
# needs system_server, and netd never gets a network registered. udhcpc.script
# writes the lease's list to /data/vps_dns.
DNS_LIST=$(grep -v '^$' /data/vps_dns 2>/dev/null)
[ -n "$DNS_LIST" ] || DNS_LIST=$(dumpsys connectivity 2>/dev/null \
    | sed -n 's/.*DnsAddresses: \[\([^]]*\)\].*/\1/p' \
    | grep -v '^ *$' | head -1 \
    | tr ',' '\n' | tr -d ' /' | grep -v '^$')
if [ -z "$DNS_LIST" ]; then
    # Android keeps the default route in a per-network table that toybox
    # `ip route` does not print, so derive the router from the subnet.
    IP=$(ip -4 addr show wlan0 2>/dev/null | awk '/inet / {print $2; exit}' | cut -d/ -f1)
    [ -n "$IP" ] && DNS_LIST=$(echo "$IP" | awk -F. '{print $1"."$2"."$3".1"}')
fi
[ -n "$DNS_LIST" ] || DNS_LIST=223.5.5.5

{
    for ns in $DNS_LIST; do echo "nameserver $ns"; done
    echo "nameserver 8.8.8.8"
    echo "nameserver 223.5.5.5"
} > "$UBUNTU_ROOT/etc/resolv.conf"

if [ ! -s "$UBUNTU_ROOT/etc/apt/sources.list" ]; then
    cat > "$UBUNTU_ROOT/etc/apt/sources.list" <<EOF
deb http://ports.ubuntu.com/ubuntu-ports jammy main restricted universe multiverse
deb http://ports.ubuntu.com/ubuntu-ports jammy-updates main restricted universe multiverse
deb http://ports.ubuntu.com/ubuntu-ports jammy-security main restricted universe multiverse
EOF
fi

# Android's kernel is built with CONFIG_ANDROID_PARANOID_NETWORK, which lets only
# processes in group AID_INET (3003) or holding CAP_NET_RAW create an AF_INET
# socket. apt drops to _apt for its download methods, and _apt has neither, so
# every socket() returns EACCES. The resolver needs a UDP socket as well, so the
# failure surfaces as "Temporary failure resolving" and reads like broken DNS.
# Running the methods as root skips the drop entirely.
mkdir -p "$UBUNTU_ROOT/etc/apt/apt.conf.d"
echo 'APT::Sandbox::User "root";' > "$UBUNTU_ROOT/etc/apt/apt.conf.d/99sandbox"

# ------------------------------------------------------- 5. ADB password
echo "[6/7] Seeding the ADB Wi-Fi password"
PASS_FILE=/data/adb_wifi_pass
if [ ! -s "$PASS_FILE" ]; then
    echo "santoniadmin" > "$PASS_FILE" || die "cannot write $PASS_FILE"
    echo "      wrote the default password"
else
    echo "      $PASS_FILE already exists"
fi
chmod 600 "$PASS_FILE" 2>/dev/null
chown 0:0 "$PASS_FILE" 2>/dev/null
adb_pass=$(cat "$PASS_FILE" 2>/dev/null)
echo "      password: ${adb_pass:-santoniadmin}"

# ---------------------------------------------------- 6. openssh-server
echo "[7/7] Installing openssh-server in the chroot"

# apt needs /dev, /proc, /sys and a resolv.conf inside the chroot. These are
# the same mounts init.ubuntu.sh sets up on every boot; they are torn down
# again here so the first boot starts from a clean mount table.
mkdir -p "$UBUNTU_ROOT/dev" "$UBUNTU_ROOT/proc" "$UBUNTU_ROOT/sys" \
         "$UBUNTU_ROOT/tmp" "$UBUNTU_ROOT/run/sshd"

if mount -o rbind /dev "$UBUNTU_ROOT/dev" 2>/dev/null; then
    mount -o rslave "$UBUNTU_ROOT/dev" 2>/dev/null
fi
# The rbind can land as a bare tmpfs holding only null and pts, which makes
# every open of /dev/null fail with EACCES. sshd then dies with
# "cannot open /dev/null: Permission denied" and the setup reports
# "sshd failed to start" even though the overlay applied cleanly. Verify the
# node is actually usable and re-bind if it is not.
if ! ( : > "$UBUNTU_ROOT/dev/null" ) 2>/dev/null; then
    mount -o rbind /dev "$UBUNTU_ROOT/dev" 2>/dev/null
fi
# The rbind does not bring /dev/pts on this device, and without devpts
# posix_openpt fails with ENODEV: apt cannot open its log, and sshd cannot give
# a session a pty ("PTY allocation request failed on channel 0").
mkdir -p "$UBUNTU_ROOT/dev/pts"
if ! grep -q " $UBUNTU_ROOT/dev/pts " /proc/mounts 2>/dev/null; then
    mount -t devpts devpts "$UBUNTU_ROOT/dev/pts" \
        -o mode=0620,ptmxmode=0666,gid=5 2>/dev/null \
        || mount -t devpts devpts "$UBUNTU_ROOT/dev/pts" 2>/dev/null
fi
mount -t proc proc "$UBUNTU_ROOT/proc" 2>/dev/null
mount -t sysfs sysfs "$UBUNTU_ROOT/sys" 2>/dev/null
chmod 1777 "$UBUNTU_ROOT/tmp" 2>/dev/null

{
    for ns in $DNS_LIST; do echo "nameserver $ns"; done
    echo "nameserver 8.8.8.8"
    echo "nameserver 223.5.5.5"
} > "$UBUNTU_ROOT/etc/resolv.conf"

# PATH inside the chroot is inherited from Android's shell, which has no
# /usr/bin, so apt-get is not found unless PATH is set explicitly.
# adb shell exports TMPDIR=/data/local/tmp, which does not exist inside the
# chroot. Package postinst scripts call mktemp, so without overriding it
# openssh-server fails to configure with exit status 1.
CHROOT_ENV='export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin; export HOME=/root; export TMPDIR=/tmp; export DEBIAN_FRONTEND=noninteractive'

# The link was re-associated in step 1, and netd can flush the main table when
# it re-validates the network, which removes the default route step 5 added.
# apt has no retry of its own, so re-add the route and wait until the chroot
# can actually resolve before handing it over. Probe with ahostsv4: `getent
# hosts` is satisfied by an AAAA answer alone and passes while apt, which needs
# an IPv4 address, still fails.
if [ -x "$UBUNTU_ROOT/usr/bin/getent" ]; then
    _net_try=0
    while [ "$_net_try" -lt 12 ]; do
        GW=$(ip route show table all 2>/dev/null | awk '/^default via/ && /dev wlan0/ {print $3; exit}')
        if [ -n "$GW" ] && ! ip route show 2>/dev/null | grep -q '^default via'; then
            ip route add default via "$GW" dev wlan0 2>/dev/null
        fi
        if chroot "$UBUNTU_ROOT" /usr/bin/getent ahostsv4 ports.ubuntu.com >/dev/null 2>&1; then
            echo "      DNS ok"
            break
        fi
        _net_try=$((_net_try + 1))
        sleep 5
    done
fi

# ubuntu-base ships almost nothing. openssh-server alone leaves the chroot
# without sudo, an editor, curl or even ps, and apply.sh then fails its own
# verification with "sudo: command not found". Install the standard server set
# in the same pass so the overlay has something to work with.
# cron is here because boot-services.sh enables it on every boot.
VPS_PACKAGES="openssh-server sudo nano vim-tiny curl wget iputils-ping dnsutils net-tools procps htop git ca-certificates unzip less iproute2 cron"
if chroot "$UBUNTU_ROOT" /bin/sh -c "$CHROOT_ENV; apt-get update && apt-get install -y $VPS_PACKAGES"; then
    echo "      apt finished"
else
    echo "      apt failed, run it by hand later"
fi

if [ -x "$UBUNTU_ROOT/usr/sbin/sshd" ]; then
    echo "      openssh-server installed"
else
    echo "      openssh-server NOT installed"
fi

# sshd on Ubuntu 22.04 defaults to PermitRootLogin prohibit-password, and the
# base rootfs ships root with no password at all. Without both a password and
# that setting the only way in is adb, which defeats the point of a VPS.
# A fixed default keeps the first login predictable; UBUNTU_ROOT_PASS overrides
# it. The file is still written so the password is discoverable over adb.
ROOT_PASS_FILE=/data/ubuntu_root_pass
root_pass=${UBUNTU_ROOT_PASS:-santoniadmin}
echo "$root_pass" > "$ROOT_PASS_FILE" || die "cannot write $ROOT_PASS_FILE"
chmod 600 "$ROOT_PASS_FILE" 2>/dev/null
chown 0:0 "$ROOT_PASS_FILE" 2>/dev/null

if [ -n "$root_pass" ]; then
    # chpasswd exits 0 inside this chroot without touching /etc/shadow, so build
    # the hash with openssl (pulled in alongside openssh-server) and let usermod
    # write the field directly. The hash goes in as an argument, never through a
    # shell, so its $ characters survive.
    root_hash=""
    if [ -x "$UBUNTU_ROOT/usr/bin/openssl" ]; then
        root_hash=$(printf '%s\n' "$root_pass" \
            | chroot "$UBUNTU_ROOT" /usr/bin/openssl passwd -6 -stdin 2>/dev/null)
    fi
    if [ -n "$root_hash" ]; then
        if chroot "$UBUNTU_ROOT" /usr/sbin/usermod -p "$root_hash" root; then
            echo "      root password set"
        else
            echo "      could not set the root password"
        fi
    elif printf 'root:%s\n' "$root_pass" | chroot "$UBUNTU_ROOT" /usr/sbin/chpasswd; then
        echo "      root password set (chpasswd)"
    else
        echo "      could not set the root password"
    fi
    # chpasswd can exit 0 while leaving the hash untouched, so check the field.
    if chroot "$UBUNTU_ROOT" /bin/sh -c "$CHROOT_ENV; grep -q '^root:[!*]' /etc/shadow"; then
        echo "      WARNING: root has no password hash, login will fail"
    fi
    SSHD_CONF="$UBUNTU_ROOT/etc/ssh/sshd_config"
    if [ -f "$SSHD_CONF" ]; then
        if grep -q '^#*PermitRootLogin' "$SSHD_CONF" 2>/dev/null; then
            sed -i 's/^#*PermitRootLogin.*/PermitRootLogin yes/' "$SSHD_CONF"
        else
            echo 'PermitRootLogin yes' >> "$SSHD_CONF"
        fi
        echo "      PermitRootLogin yes"
    else
        echo "      no $SSHD_CONF - openssh-server did not install"
    fi
fi

# The overlay creates the `ubuntu` user (uid 1000, in sudo with NOPASSWD) and
# sets its password. Keep the value here so the summary can print it and the
# device keeps a copy next to the root one.
UBUNTU_USER_PASS_FILE=/data/ubuntu_user_pass
ubuntu_pass=${UBUNTU_USER_PASS:-ubuntu}
echo "$ubuntu_pass" > "$UBUNTU_USER_PASS_FILE" || die "cannot write $UBUNTU_USER_PASS_FILE"
chmod 600 "$UBUNTU_USER_PASS_FILE" 2>/dev/null
chown 0:0 "$UBUNTU_USER_PASS_FILE" 2>/dev/null

# ------------------------------------------------- 6b. chroot overlay (rootdir)
# apply.sh installs the ubuntu user, sudo through the suid bind mount, the
# systemctl replacement, policy-rc.d, the runlevel shim, the journalctl wrapper,
# and the boot hook. The overlay is installed to /system/etc/vps-setup through
# PRODUCT_COPY_FILES.
OVERLAY_SRC=/system/etc/vps-setup
if [ -d "$OVERLAY_SRC" ]; then
    echo "[6b/7] Applying the chroot overlay"
    rm -rf "$UBUNTU_ROOT/tmp/vps-setup"
    mkdir -p "$UBUNTU_ROOT/tmp/vps-setup"
    cp -a "$OVERLAY_SRC/." "$UBUNTU_ROOT/tmp/vps-setup/"
    if chroot "$UBUNTU_ROOT" /usr/bin/env UBUNTU_USER_PASS="$ubuntu_pass" \
            /bin/bash -c \
            "$CHROOT_ENV; /bin/bash /tmp/vps-setup/apply.sh /tmp/vps-setup/rootdir"; then
        echo "      overlay applied"
    else
        echo "      overlay FAILED, run apply.sh by hand"
    fi
else
    echo "[6b/7] no $OVERLAY_SRC, skipping the overlay"
fi

# apt does not start sshd in a chroot, and the user should not have to reboot
# to reach the box. Start it the way init.ubuntu.sh does on boot.
sshd_up=0
if netstat -tln 2>/dev/null | grep -q ':22 '; then
    sshd_up=1
    echo "      sshd already listening on :22"
elif [ -x "$UBUNTU_ROOT/usr/sbin/sshd" ]; then
    # /run lives on /data, so a stale pid file can name an unrelated process.
    rm -f "$UBUNTU_ROOT/run/sshd.pid"
    # sshd daemonizes by reopening its stdio on /dev/null, and ssh-keygen opens
    # it too. If the /dev rbind above did not come up, both print
    # "Couldn't open /dev/null: No such file or directory" and the setup log
    # reads like a failure even though sshd started fine. Make sure the node
    # exists before either runs.
    if [ ! -e "$UBUNTU_ROOT/dev/null" ]; then
        mkdir -p "$UBUNTU_ROOT/dev"
        mknod -m 666 "$UBUNTU_ROOT/dev/null" c 1 3 2>/dev/null || true
    fi
    if chroot "$UBUNTU_ROOT" /bin/sh -c \
            'export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
             export TMPDIR=/tmp
             mkdir -p /run/sshd && chmod 0755 /run/sshd
             ssh-keygen -A
             /usr/sbin/sshd'; then
        sshd_up=1
        echo "      sshd started"
    else
        echo "      sshd failed to start, it will come up on the next boot"
    fi
fi

# sshd needs /dev/pts to give each session a pty, so the mounts stay up while
# it runs. init.ubuntu.sh re-mounts them on boot either way.
if [ "$sshd_up" = 0 ]; then
    umount "$UBUNTU_ROOT/sys" 2>/dev/null
    umount "$UBUNTU_ROOT/proc" 2>/dev/null
    umount "$UBUNTU_ROOT/dev/pts" 2>/dev/null
    umount "$UBUNTU_ROOT/dev" 2>/dev/null
fi

echo
echo "Done. Ubuntu 22.04 is at $UBUNTU_ROOT"
if [ "$sshd_up" = 1 ]; then
    echo "SSH: ssh root@$ip_addr   password: $root_pass"
else
    echo "SSH: not running yet - reboot, then ssh root@$ip_addr   password: $root_pass"
fi
echo "     ssh ubuntu@$ip_addr   password: $ubuntu_pass"
echo "  Wi-Fi IP : $ip_addr"
echo "  Enter    : adb shell"
echo "  SSH root : ssh root@$ip_addr"
echo "  SSH user : ssh ubuntu@$ip_addr   (uid 1000, sudo without a password)"
echo
echo "  Passwords, also stored on the device (mode 600 root:root):"
echo "    adb over Wi-Fi : ${adb_pass:-santoniadmin}"
echo "                     /data/adb_wifi_pass"
echo "    ssh root       : ${root_pass:-not set}"
echo "                     /data/ubuntu_root_pass"
echo "    ssh ubuntu     : $ubuntu_pass"
echo "                     /data/ubuntu_user_pass"
