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

if fetch "$PRIMARY_URL"; then
    :
elif fetch "$FALLBACK_URL"; then
    :
else
    echo
    echo "vps-setup: no downloader on the device." >&2
    echo "Push the rootfs from the PC instead:" >&2
    echo "  adb push ubuntu-base.tar.gz /data/local/tmp/" >&2
    echo "  adb shell vps-setup $SSID <password>" >&2
    exit 1
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

# Android resolves through netd and has no resolv.conf to copy, so the
# chroot needs its own. The router is the only DNS server guaranteed to be
# reachable; the public ones are a fallback because many networks drop them.
DNS=$(getprop net.dns1 2>/dev/null)
[ -n "$DNS" ] || DNS=$(ip route show table all 2>/dev/null | awk '/^default/ {print $3; exit}')
if [ -z "$DNS" ]; then
    # Android keeps the default route in a per-network table that toybox
    # `ip route` does not print, so derive the router from the subnet.
    IP=$(ip -4 addr show wlan0 2>/dev/null | awk '/inet / {print $2; exit}' | cut -d/ -f1)
    [ -n "$IP" ] && DNS=$(echo "$IP" | awk -F. '{print $1"."$2"."$3".1"}')
fi
[ -n "$DNS" ] || DNS=192.168.1.1

cat > "$UBUNTU_ROOT/etc/resolv.conf" <<EOF
nameserver $DNS
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF

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

cat > "$UBUNTU_ROOT/etc/resolv.conf" <<EOF
nameserver $DNS
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF

# PATH inside the chroot is inherited from Android's shell, which has no
# /usr/bin, so apt-get is not found unless PATH is set explicitly.
CHROOT_ENV='export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin; export HOME=/root; export DEBIAN_FRONTEND=noninteractive'

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
ROOT_PASS_FILE=/data/ubuntu_root_pass
if [ -s "$ROOT_PASS_FILE" ]; then
    root_pass=$(cat "$ROOT_PASS_FILE" 2>/dev/null)
else
    root_pass=$(cat /proc/sys/kernel/random/uuid | tr -d '-' | head -c 16)
    echo "$root_pass" > "$ROOT_PASS_FILE" || die "cannot write $ROOT_PASS_FILE"
    chmod 600 "$ROOT_PASS_FILE" 2>/dev/null
    chown 0:0 "$ROOT_PASS_FILE" 2>/dev/null
fi

if [ -n "$root_pass" ]; then
    if printf 'root:%s\n' "$root_pass" | chroot "$UBUNTU_ROOT" /usr/sbin/chpasswd 2>/dev/null; then
        echo "      root password set"
    else
        echo "      could not set the root password"
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
echo "  Wi-Fi IP : $ip_addr"
echo "  Enter    : adb shell"
echo "  SSH      : ssh root@$ip_addr"
echo
echo "  Passwords, also stored on the device (mode 600 root:root):"
echo "    adb over Wi-Fi : ${adb_pass:-santoniadmin}"
echo "                     /data/adb_wifi_pass"
echo "    ssh root       : ${root_pass:-not set}"
echo "                     /data/ubuntu_root_pass"
