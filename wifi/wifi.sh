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
WPA_CONF=/data/vendor/wifi/wpa/wpa_supplicant.conf
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

# The WLAN driver is built into the kernel and only registers wlan0 once the
# firmware path is written. Stock Android does that from libwifi_hal when the
# framework starts; with the framework stopped nothing does, so do it here.
ensure_driver() {
    [ -d "/sys/class/net/$IFACE" ] && return 0
    printf 'sta' > /sys/module/wlan/parameters/fwpath 2>/dev/null
    i=0
    while [ "$i" -lt 20 ]; do
        [ -d "/sys/class/net/$IFACE" ] && return 0
        sleep 1
        i=$((i + 1))
    done
    echo "wifi: $IFACE did not appear, check the firmware" >&2
    return 1
}

# wpa_supplicant is `disabled` in init.qcom.rc: the framework starts it, and the
# framework is gone. Start it here and wait for the control socket. `init.svc`
# alone is not enough: it can read `running` while the daemon has no interface.
ensure_supplicant() {
    # init.qcom.rc creates this directory as `0770 wifi wifi` from its own
    # `on boot`, which runs after ours. Never create it here: a root-owned
    # directory makes wpa_supplicant fail to bind its control socket once it
    # drops to the wifi user, and init's own `mkdir` then fails because the
    # path already exists, so the wrong owner sticks.
    i=0
    while [ "$i" -lt 20 ] && [ ! -d "$WPA_SOCK" ]; do
        sleep 1
        i=$((i + 1))
    done
    [ -d "$WPA_SOCK" ] || { echo "wifi: $WPA_SOCK is missing" >&2; return 1; }

    # wpa_supplicant only adds the interface named on the command line when it
    # also has a config file. With -g set and -c missing, main.c breaks out of
    # the add_iface loop, the daemon runs with no interface, and no
    # per-interface control socket is ever created.
    if [ ! -s "$WPA_CONF" ]; then
        printf 'ctrl_interface=%s\n' "$WPA_SOCK" > "$WPA_CONF"
        chown wifi:wifi "$WPA_CONF" 2>/dev/null
        chmod 0660 "$WPA_CONF" 2>/dev/null
    fi

    [ -S "$WPA_SOCK/$IFACE" ] && return 0
    # Restart unconditionally: a daemon left over from a start without the
    # config file has no interface and will never create the socket.
    stop wpa_supplicant 2>/dev/null
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
#
# /data survives a reboot, so the pidfile can name a PID that now belongs to an
# unrelated process. Check the command line, not just that the PID is alive.
start_dhcp() {
    if [ -s "$PIDFILE" ]; then
        pid=$(cat "$PIDFILE")
        if [ -r "/proc/$pid/cmdline" ] \
                && tr '\0' ' ' < "/proc/$pid/cmdline" | grep -q udhcpc; then
            return 0
        fi
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

# Nothing sets the clock once the framework is stopped: NetworkTimeUpdateService
# lives in system_server. A device with no battery-backed RTC boots in 1970, and
# every HTTPS request then fails with "certificate is not yet valid" -- which is
# what the rootfs download and apt both do. Read the Date header over plain HTTP,
# which needs no clock, and set the system time from it.
set_clock() {
    [ "$(date +%Y)" -ge 2020 ] && return 0
    i=0
    while [ "$i" -lt 5 ]; do
        hdr=$(curl -sI --max-time 10 \
              http://connectivitycheck.gstatic.com/generate_204 2>/dev/null \
              | tr -d '\r' | sed -n 's/^[Dd]ate: *//p' | head -1)
        [ -n "$hdr" ] && break
        sleep 2
        i=$((i + 1))
    done
    [ -n "$hdr" ] || { echo "wifi: could not read the time" >&2; return 1; }
    set -- $hdr
    case "$3" in
        Jan) m=01 ;; Feb) m=02 ;; Mar) m=03 ;; Apr) m=04 ;;
        May) m=05 ;; Jun) m=06 ;; Jul) m=07 ;; Aug) m=08 ;;
        Sep) m=09 ;; Oct) m=10 ;; Nov) m=11 ;; Dec) m=12 ;;
        *) echo "wifi: unparsable date '$hdr'" >&2; return 1 ;;
    esac
    # toybox date's default SET format is MMDDhhmmCCYY.ss, which needs no
    # strptime support. -D is the fallback for builds that parse it.
    hm=${5%:*}
    date -u "$m$2${hm%:*}${hm#*:}$4.00" 2>/dev/null \
        || date -u -D '%Y-%m-%d %H:%M:%S' "$4-$m-$2 $5" 2>/dev/null
    [ "$(date +%Y)" -ge 2020 ] || echo "wifi: could not set the clock" >&2
}

associate() {
    ssid=$1
    psk=$2

    ensure_driver || return 1
    # wificond sets wlan0 down when its client (system_server) dies, so the
    # link has to be brought back up before the supplicant can use it.
    ip link set "$IFACE" up 2>/dev/null
    ensure_supplicant || return 1

    # The config file only carries ctrl_interface, so save_config has nowhere
    # useful to write. Networks added here live only until the daemon restarts,
    # which is why the credentials are also kept in $CONF.
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
        ensure_driver || exit 1
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
        set_clock
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
        set_clock
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
