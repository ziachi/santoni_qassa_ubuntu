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
WPA_SOCKETS=/data/vendor/wifi/wpa/sockets
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
[ "$(getprop init.svc.wpa_supplicant)" = "running" ] \
    || die "wpa_supplicant did not start"

# wpa_cli talks to wpa_supplicant directly, so the network is joined without
# going through the framework. init.qcom.rc starts the daemon with
# -O/data/vendor/wifi/wpa/sockets, so the control socket is not in the default
# /data/misc/wifi/sockets and -p has to be passed explicitly.
WPA_CLI=wpa_cli
command -v wpa_cli >/dev/null 2>&1 || WPA_CLI=/vendor/bin/wpa_cli

wpa() {
    "$WPA_CLI" -p "$WPA_SOCKETS" -i wlan0 "$@" 2>/dev/null
}

net_id=$(wpa add_network | tail -1)
case "$net_id" in
    ''|*[!0-9]*) net_id="" ;;
esac

if [ -n "$net_id" ]; then
    wpa set_network "$net_id" ssid "\"$SSID\"" >/dev/null
    wpa set_network "$net_id" psk "\"$WIFI_PASS\"" >/dev/null
    wpa enable_network "$net_id" >/dev/null
    wpa save_config >/dev/null
    wpa reassociate >/dev/null
    echo "      wpa_cli network id $net_id"
else
    echo "      wpa_cli not usable"
fi

echo "[2/7] Waiting for an IP address"
ip_addr=""
i=0
while [ "$i" -lt 20 ]; do
    ip_addr=$(ip -4 addr show wlan0 2>/dev/null | sed -n 's/.*inet \([0-9.]*\).*/\1/p' | head -1)
    [ -n "$ip_addr" ] && break
    sleep 1
    i=$((i + 1))
done

# ClientModeImpl tears down a connection it did not create ("Connected to
# unknown networkId, disconnecting"), so a wpa_cli-only join can come up and
# then be dropped. The framework path registers the network in
# WifiConfigManager first, so it is kept as the fallback rather than the
# primary mechanism.
if [ -z "$ip_addr" ] && cmd wifi help 2>&1 | grep -q "connect-network"; then
    echo "      retrying via framework"
    cmd wifi connect-network "$SSID" wpa2 "$WIFI_PASS" >/dev/null 2>&1
    i=0
    while [ "$i" -lt 25 ]; do
        ip_addr=$(ip -4 addr show wlan0 2>/dev/null | sed -n 's/.*inet \([0-9.]*\).*/\1/p' | head -1)
        [ -n "$ip_addr" ] && break
        sleep 1
        i=$((i + 1))
    done
fi

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
    echo "      wrote the default password"
else
    echo "      $PASS_FILE already exists"
fi
chmod 600 "$PASS_FILE" 2>/dev/null
chown 0:0 "$PASS_FILE" 2>/dev/null

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
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF

if chroot "$UBUNTU_ROOT" /usr/bin/env DEBIAN_FRONTEND=noninteractive \
        /bin/sh -c 'apt-get update && apt-get install -y openssh-server'; then
    echo "      openssh-server installed"
else
    echo "      apt failed, run it by hand later"
fi

umount "$UBUNTU_ROOT/sys" 2>/dev/null
umount "$UBUNTU_ROOT/proc" 2>/dev/null
umount "$UBUNTU_ROOT/dev/pts" 2>/dev/null
umount "$UBUNTU_ROOT/dev" 2>/dev/null

echo
echo "Done. Ubuntu 22.04 is at $UBUNTU_ROOT"
echo "  Wi-Fi IP : $ip_addr"
echo "  Enter    : adb shell"
echo "  SSH      : chroot $UBUNTU_ROOT passwd root"
