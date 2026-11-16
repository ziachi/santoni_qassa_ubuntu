#!/system/bin/sh
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

die() {
    echo "vps-setup: $*" >&2
    exit 1
}

[ -n "$SSID" ] || die "usage: vps-setup <SSID> <PASSWORD>"
[ -n "$WIFI_PASS" ] || die "usage: vps-setup <SSID> <PASSWORD>"

# ---------------------------------------------------------------- 1. Wi-Fi
echo "[1/7] Joining Wi-Fi: $SSID"
svc wifi enable

i=0
while [ "$i" -lt 20 ]; do
    [ "$(getprop init.svc.wpa_supplicant)" = "running" ] && break
    sleep 1
    i=$((i + 1))
done

# `cmd wifi connect-network` is an Android 11 command. Android 10 has no shell
# command that can join a network, so this build carries a backport from
# patches/apply-wifi-connect-network.py. Say so instead of dying on the bare
# "Unknown command" the shell prints.
if ! cmd wifi help 2>&1 | grep -q "connect-network"; then
    echo "vps-setup: no connect-network in cmd wifi" >&2
    echo "vps-setup: apply patches/apply-wifi-connect-network.py" >&2
    echo "vps-setup: to the source tree, rebuild, re-run." >&2
    exit 1
fi

cmd wifi connect-network "$SSID" wpa2 "$WIFI_PASS" \
    || die "cmd wifi connect-network failed"

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
fetch() {
    rm -f "$TARBALL"
    if command -v curl >/dev/null 2>&1; then
        if [ -d "$CACERT_DIR" ]; then
            curl -fsSL --capath "$CACERT_DIR" -o "$TARBALL" "$1"
        else
            curl -fsSL -o "$TARBALL" "$1"
        fi
    elif command -v wget >/dev/null 2>&1; then
        wget -q -O "$TARBALL" "$1"
    elif toybox wget --help >/dev/null 2>&1; then
        toybox wget -q -O "$TARBALL" "$1"
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

# Android resolves through netd and has no resolv.conf to copy. The resolver
# the framework actually uses is the only one known to work on this network,
# so read it out of dumpsys first. The gateway is not a reliable fallback: on
# the santoni test network it routes but does not answer DNS.
# Keep every address netd lists, IPv6 included. Filtering down to IPv4 drops
# the resolver that actually answers here: netd lists the IPv6 resolver first
# and the IPv4 gateway second, and the gateway routes but does not answer DNS.
DNS_LIST=$(dumpsys connectivity 2>/dev/null \
    | sed -n 's/.*DnsAddresses: \[\([^]]*\)\].*/\1/p' \
    | grep -v '^ *$' | head -1 \
    | tr ',' '\n' | tr -d ' /' | grep -v '^$')
[ -n "$DNS_LIST" ] || DNS_LIST=$(getprop net.dns1 2>/dev/null)
[ -n "$DNS_LIST" ] || DNS_LIST=$(ip route show table all 2>/dev/null | awk '/^default/ {print $3; exit}')
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

if chroot "$UBUNTU_ROOT" /bin/sh -c "$CHROOT_ENV; apt-get update && apt-get install -y openssh-server"; then
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
    if printf 'root:%s\n' "$root_pass" | chroot "$UBUNTU_ROOT" /usr/sbin/chpasswd; then
        echo "      root password set"
    else
        echo "      could not set the root password"
    fi
    # chpasswd can exit 0 while leaving the hash untouched, so check the field.
    if chroot "$UBUNTU_ROOT" /bin/sh -c 'grep -q "^root:[!*]" /etc/shadow'; then
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
    fi
fi

umount "$UBUNTU_ROOT/sys" 2>/dev/null
umount "$UBUNTU_ROOT/proc" 2>/dev/null
umount "$UBUNTU_ROOT/dev/pts" 2>/dev/null
umount "$UBUNTU_ROOT/dev" 2>/dev/null

echo
echo "Done. Ubuntu 22.04 is at $UBUNTU_ROOT"
echo "SSH: ssh root@<phone-ip>   password: $root_pass"
echo "  Wi-Fi IP : $ip_addr"
echo "  Enter    : adb shell"
echo "  SSH      : ssh root@$ip_addr"
echo
echo "  Passwords, also stored on the device (mode 600 root:root):"
echo "    adb over Wi-Fi : ${adb_pass:-santoniadmin}"
echo "                     /data/adb_wifi_pass"
echo "    ssh root       : ${root_pass:-not set}"
echo "                     /data/ubuntu_root_pass"
