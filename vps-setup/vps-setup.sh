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

die() {
    echo "vps-setup: $*" >&2
    exit 1
}

[ -n "$SSID" ] || die "usage: vps-setup <SSID> <WIFI_PASSWORD>"
[ -n "$WIFI_PASS" ] || die "usage: vps-setup <SSID> <WIFI_PASSWORD>"

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
    echo "vps-setup: this build's 'cmd wifi' has no connect-network command." >&2
    echo "vps-setup: apply patches/apply-wifi-connect-network.py to the source" >&2
    echo "vps-setup: tree and rebuild, then re-run vps-setup." >&2
    exit 1
fi

cmd wifi connect-network "$SSID" wpa2 "$WIFI_PASS" || die "cmd wifi connect-network failed"

echo "[2/7] Waiting for an IP address"
ip_addr=""
i=0
while [ "$i" -lt 45 ]; do
    ip_addr=$(ip -4 addr show wlan0 2>/dev/null | sed -n 's/.*inet \([0-9.]*\).*/\1/p' | head -1)
    [ -n "$ip_addr" ] && break
    ip_addr=$(getprop dhcp.wlan0.ipaddress 2>/dev/null)
    [ -n "$ip_addr" ] && break
    sleep 1
    i=$((i + 1))
done
[ -n "$ip_addr" ] || die "no IP on wlan0 after 45s — check the SSID and password"
echo "      wlan0 = $ip_addr"

# ------------------------------------------------------------- 2. Download
echo "[3/7] Downloading the Ubuntu 22.04 arm64 base rootfs"

download() {
    url=$1
    if command -v curl >/dev/null 2>&1; then
        curl -L --fail --retry 2 -o "$TARBALL" "$url"
    elif command -v wget >/dev/null 2>&1; then
        wget -O "$TARBALL" "$url"
    elif toybox wget --help >/dev/null 2>&1; then
        toybox wget -O "$TARBALL" "$url"
    else
        return 127
    fi
}

if download "$PRIMARY_URL"; then
    :
elif download "$FALLBACK_URL"; then
    :
else
    echo
    echo "vps-setup: no downloader on the device (no curl, no wget)." >&2
    echo "Push the rootfs from the host instead, then re-run vps-setup:" >&2
    echo >&2
    echo "  curl -LO $PRIMARY_URL" >&2
    echo "  adb push ubuntu-base-22.04-base-arm64.tar.gz $TARBALL" >&2
    echo "  adb shell vps-setup $SSID <password>" >&2
    exit 1
fi

[ -s "$TARBALL" ] || die "download produced an empty file"

# -------------------------------------------------------------- 3. Extract
echo "[4/7] Extracting into $UBUNTU_ROOT"
mkdir -p "$UBUNTU_ROOT" || die "cannot create $UBUNTU_ROOT"
tar -xzf "$TARBALL" -C "$UBUNTU_ROOT" || die "tar failed"
[ -x "$UBUNTU_ROOT/bin/bash" ] || die "extracted rootfs has no /bin/bash"

for d in dev dev/pts proc sys tmp run; do
    mkdir -p "$UBUNTU_ROOT/$d"
done

# ------------------------------------------------------------- 4. Network
echo "[5/7] Writing resolv.conf and apt sources"

cat > "$UBUNTU_ROOT/etc/resolv.conf" <<EOF
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
    echo "      wrote the default password to $PASS_FILE"
else
    echo "      $PASS_FILE already exists, keeping its value"
fi
chmod 600 "$PASS_FILE" 2>/dev/null
chown 0:0 "$PASS_FILE" 2>/dev/null

# ---------------------------------------------------- 6. openssh-server
echo "[7/7] Installing openssh-server inside the chroot"

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
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF

if chroot "$UBUNTU_ROOT" /usr/bin/env DEBIAN_FRONTEND=noninteractive \
        /bin/sh -c 'apt-get update && apt-get install -y openssh-server'; then
    echo "      openssh-server installed"
else
    echo "      apt failed — run 'apt update && apt install -y openssh-server'"
    echo "      inside the chroot once the device has network"
fi

umount "$UBUNTU_ROOT/sys" 2>/dev/null
umount "$UBUNTU_ROOT/proc" 2>/dev/null
umount "$UBUNTU_ROOT/dev/pts" 2>/dev/null
umount "$UBUNTU_ROOT/dev" 2>/dev/null

echo
echo "Done. Ubuntu 22.04 is at $UBUNTU_ROOT"
echo "  Wi-Fi IP : $ip_addr"
echo "  Enter    : adb shell   (or ubuntu-enter over Wi-Fi, password santoniadmin)"
echo "  SSH      : set a root password first — chroot $UBUNTU_ROOT passwd root"
echo "  Next     : apt update && apt install -y openssh-server"
