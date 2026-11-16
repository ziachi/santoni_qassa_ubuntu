#!/system/bin/sh
# Short front-end for the Wi-Fi shell commands.
#
# Android 10's `cmd wifi` has no scan, disconnect or status, so this wraps the
# backports in patches/apply-wifi-scan.py. Every line stays under 60 columns.

usage() {
    echo "usage: wifi <command>"
    echo
    echo "  scan                 list nearby networks"
    echo "  connect <ssid> [pw]  join a network, print the IP"
    echo "  disconnect           drop the current network"
    echo "  status               show ssid, signal and IP"
    echo "  help                 this text"
}

ip_of() {
    ip -4 addr show wlan0 2>/dev/null \
        | sed -n 's/.*inet \([0-9.]*\).*/\1/p' | head -1
}

case "$1" in
    help|-h|--help|"")
        usage
        exit 0
        ;;
esac

if [ "$(id -u)" != "0" ]; then
    echo "wifi: needs root, run 'adb root' first" >&2
    exit 1
fi

case "$1" in
    scan)
        cmd wifi scan
        ;;
    connect)
        if [ -z "$2" ]; then
            echo "wifi: need an SSID" >&2
            exit 1
        fi
        svc wifi enable
        i=0
        while [ "$i" -lt 20 ]; do
            [ "$(getprop init.svc.wpa_supplicant)" = "running" ] && break
            sleep 1
            i=$((i + 1))
        done
        if [ -n "$3" ]; then
            cmd wifi connect-network "$2" wpa2 "$3" || exit 1
        else
            cmd wifi connect-network "$2" open || exit 1
        fi
        addr=""
        i=0
        while [ "$i" -lt 45 ]; do
            addr=$(ip_of)
            [ -n "$addr" ] && break
            sleep 1
            i=$((i + 1))
        done
        if [ -z "$addr" ]; then
            echo "wifi: no IP, check the password" >&2
            exit 1
        fi
        echo "connected to $2"
        echo "ip $addr"
        ;;
    disconnect)
        cmd wifi disconnect
        ;;
    status)
        cmd wifi status
        addr=$(ip_of)
        if [ -n "$addr" ]; then
            echo "ip    $addr"
        fi
        ;;
    *)
        echo "wifi: unknown command '$1'" >&2
        usage >&2
        exit 1
        ;;
esac
