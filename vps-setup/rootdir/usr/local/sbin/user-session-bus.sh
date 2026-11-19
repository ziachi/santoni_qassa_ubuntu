#!/bin/bash
# Copyright (c) 2026 ziachi - https://github.com/ziachi/santoni_qassa_ubuntu
#
# Give every human user the runtime directory and session bus that a stock
# Ubuntu login session has.
#
# There is no logind here, so nothing creates /run/user/<uid> and nothing starts
# a session bus. Installers that manage user services probe for
# /run/user/<uid>/bus before they will touch `systemctl --user`, and without it
# they refuse to install or start anything even though the shim itself needs no
# D-Bus at all. Idempotent, safe to run by hand at any time.
set -u

start_bus() {
    user=$1
    uid=$(id -u "$user" 2>/dev/null) || return 0
    home=$(getent passwd "$user" | cut -d: -f6)
    [ -n "$home" ] && [ -d "$home" ] || return 0
    runtime=/run/user/$uid
    mkdir -p "$runtime" 2>/dev/null || return 0
    chown "$user:$user" "$runtime" 2>/dev/null
    chmod 700 "$runtime" 2>/dev/null
    if [ -S "$runtime/bus" ] && pgrep -u "$uid" -f 'dbus-daemon --session' >/dev/null 2>&1; then
        return 0
    fi
    command -v dbus-daemon >/dev/null 2>&1 || return 0
    # /run is a plain directory on /data here, not a tmpfs, so a socket from the
    # previous boot survives and would make every client fail to connect.
    rm -f "$runtime/bus" 2>/dev/null
    runuser -u "$user" -- dbus-daemon --session --nopidfile \
        --address="unix:path=$runtime/bus" --fork --print-pid \
        > "$runtime/bus.pid" 2>/dev/null
    if [ -S "$runtime/bus" ]; then
        chown "$user:$user" "$runtime/bus.pid" 2>/dev/null
        chmod 600 "$runtime/bus.pid" 2>/dev/null
        echo "  session bus for $user -> $runtime/bus"
    else
        rm -f "$runtime/bus.pid" 2>/dev/null
        echo "  session bus for $user failed" >&2
    fi
}

for user in $(getent passwd | awk -F: '$3 >= 1000 && $3 < 60000 {print $1}'); do
    start_bus "$user"
done
