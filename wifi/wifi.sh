#!/system/bin/sh
# Wi-Fi control for the headless VPS.
#
# Zygote is stopped at boot, so `cmd wifi` and `svc wifi` are gone: both talk to
# system_server. wpa_supplicant is a native init service and keeps running, so
# this drives it directly through wpa_cli, and busybox udhcpc replaces the
# framework's DHCP client.

WPA_CLI=/vendor/bin/wpa_cli
WPA_SOCK=/data/vendor/wifi/wpa/sockets
IFACE=wlan0
BB=/system/bin/busybox
CONF=/data/vps_wifi.conf
PIDFILE=/data/udhcpc.$IFACE.pid

usage() {
    echo "usage: wifi <command>"
    echo
    echo "  scan                 list nearby networks"
    echo "  connect <ssid> [pw]  join a network, print the IP"
    echo "  reconnect            join the network saved in $CONF"
    echo "  disconnect           drop the current network"
    echo "  status               show ssid, signal and IP"
    echo "  dhcp                 start the udhcpc lease daemon"
    echo "  help                 this text"
}

wpa() {
    "$WPA_CLI" -p "$WPA_SOCK" -i "$IFACE" "$@" 2>/dev/null
}

ip_of() {
    ip -4 addr show "$IFACE" 2>/dev/null \
        | sed -n 's/.*inet \([0-9.]*\).*/\1/p' | head -1
}

# wpa_supplicant is `disabled` in init.qcom.rc: the framework starts it, and the
# framework is gone. Start it here and wait for the control socket.
ensure_supplicant() {
    [ "$(getprop init.svc.wpa_supplicant)" = "running" ] && return 0
    start wpa_supplicant
    i=0
    while [ "$i" -lt 20 ]; do
        [ -S "$WPA_SOCK/$IFACE" ] && return 0
        sleep 1
        i=$((i + 1))
    done
    echo "wifi: wpa_supplicant did not come up" >&2
    return 1
}

# udhcpc runs as a daemon so the lease is renewed before it expires. The hook
# never flushes the address, so a failed renewal leaves the old one in place
# instead of taking the device off the network.
start_dhcp() {
    if [ -s "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
        return 0
    fi
    "$BB" udhcpc -i "$IFACE" -b -p "$PIDFILE" \
        -s /system/bin/udhcpc.script >/dev/null 2>&1
}

wait_ip() {
    i=0
    while [ "$i" -lt 45 ]; do
        addr=$(ip_of)
        if [ -n "$addr" ]; then
            echo "$addr"
            return 0
        fi
        sleep 1
        i=$((i + 1))
    done
    return 1
}

associate() {
    ssid=$1
    psk=$2

    # wificond sets wlan0 down when its client (system_server) dies, so the
    # link has to be brought back up before the supplicant can use it.
    ip link set "$IFACE" up 2>/dev/null
    ensure_supplicant || return 1

    # wpa_supplicant runs without -c, so it has no config file and save_config
    # has nowhere to write. Networks added here live only until the daemon
    # restarts, which is why the credentials are also kept in $CONF.
    id=$(wpa add_network | tail -1)
    case "$id" in
        ''|*[!0-9]*)
            echo "wifi: add_network failed" >&2
            return 1
            ;;
    esac
    wpa set_network "$id" ssid "\"$ssid\"" >/dev/null
    if [ -n "$psk" ]; then
        wpa set_network "$id" psk "\"$psk\"" >/dev/null
    else
        wpa set_network "$id" key_mgmt NONE >/dev/null
    fi
    wpa enable_network "$id" >/dev/null
    wpa select_network "$id" >/dev/null

    i=0
    while [ "$i" -lt 30 ]; do
        if [ "$(wpa status | sed -n 's/^wpa_state=//p')" = "COMPLETED" ]; then
            return 0
        fi
        sleep 1
        i=$((i + 1))
    done
    echo "wifi: could not associate with $ssid" >&2
    return 1
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
        ensure_supplicant || exit 1
        wpa scan >/dev/null
        sleep 6
        wpa scan_results
        ;;
    connect)
        if [ -z "$2" ]; then
            echo "wifi: need an SSID" >&2
            exit 1
        fi
        associate "$2" "$3" || exit 1
        umask 077
        printf '%s\n%s\n' "$2" "${3:-}" > "$CONF"
        start_dhcp
        addr=$(wait_ip) || {
            echo "wifi: no IP, check the password" >&2
            exit 1
        }
        echo "connected to $2"
        echo "ip $addr"
        ;;
    reconnect)
        if [ ! -s "$CONF" ]; then
            echo "wifi: no $CONF, run 'wifi connect'" >&2
            exit 1
        fi
        ssid=$(sed -n 1p "$CONF")
        psk=$(sed -n 2p "$CONF")
        associate "$ssid" "$psk" || exit 1
        start_dhcp
        addr=$(wait_ip) || {
            echo "wifi: no IP on $IFACE" >&2
            exit 1
        }
        echo "reconnected to $ssid"
        echo "ip $addr"
        ;;
    disconnect)
        wpa disconnect
        ip addr flush dev "$IFACE" 2>/dev/null
        ;;
    status)
        wpa status
        addr=$(ip_of)
        if [ -n "$addr" ]; then
            echo "ip    $addr"
        fi
        ;;
    dhcp)
        start_dhcp
        ;;
    *)
        echo "wifi: unknown command '$1'" >&2
        usage >&2
        exit 1
        ;;
esac
