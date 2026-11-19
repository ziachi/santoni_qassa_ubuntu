#!/bin/bash
# Copyright (c) 2026 ziachi - https://github.com/ziachi/santoni_qassa_ubuntu
# Run automatically by the /usr/sbin/sshd wrapper 5 seconds after sshd comes up,
# so it needs no change in init.ubuntu.sh. Idempotent, safe to run by hand at
# any time.
#
# Lives in /usr/local/sbin, not /root: root's home is the first thing an
# operator sees after `ssh root@...`, and clearing it out used to take the boot
# path with it.
exec >>/var/log/boot-services.log 2>&1
echo "[$(date -Is)] boot-services: start"
/usr/local/sbin/suid-mount.sh

# Third-party installers check [ -d /run/systemd/system ] or sd_booted() to
# decide whether this host is systemd. Without that directory many installers
# fall back to the non-systemd path (sysvinit/openrc) and skip systemctl
# entirely.
mkdir -p /run/systemd/system 2>/dev/null
chmod 755 /run/systemd/system 2>/dev/null

# Nothing here runs logind, so /run/user/<uid> and the per-user session bus
# never appear. Installers that manage user services check for
# /run/user/<uid>/bus before they will use `systemctl --user` at all.
/usr/local/sbin/user-session-bus.sh

# systemctl3.py derives ssh.service status from PIDFile. sshd writes that file
# when it daemonizes, but early in boot it can be truncated to 0 bytes (a second
# sshd that failed to bind :22). Rewrite it from the listener that is actually
# alive, before and after `systemctl default`, so the status is not
# "inactive (dead)" and systemctl does not try to start a second sshd.
assert_sshd_pid() {
    pid=$(pgrep -f 'sshd.*\[listener\]' | head -1)
    if [ -n "$pid" ]; then
        echo "$pid" > /run/sshd.pid
        # 0600 here makes `systemctl status ssh` report inactive for every
        # non-root user: the shim reads the pid from this file and ubuntu
        # cannot open it. The pid is not a secret, and sshd writes the file
        # world-readable itself.
        chmod 644 /run/sshd.pid
    fi
}
assert_sshd_pid
/usr/bin/systemctl default
assert_sshd_pid

# cron is in VPS_PACKAGES in vps-setup.sh, so `crontab` and /etc/init.d/cron
# are both present, but nothing ever enabled the daemon: the unit sat at
# inactive (dead) and disabled, and a job written with `crontab -e` was
# accepted and never ran. Enable and start it here, after sshd is settled, so a
# slow or failing cron cannot delay the login path. Both calls are idempotent.
start_cron() {
    if [ -f /lib/systemd/system/cron.service ] || [ -f /etc/init.d/cron ]; then
        # /run is a plain directory on /data here, not a tmpfs, so
        # /run/crond.pid survives a reboot. The shim treats a pidfile whose pid
        # is alive as "already running", and Android reuses pids fast: after the
        # second boot the stale pid belonged to an unrelated process, so cron was
        # never started while is-active still read the same file and said
        # "active". Drop a pidfile that does not name cron before starting it.
        if [ -f /run/crond.pid ]; then
            old=$(cat /run/crond.pid 2>/dev/null)
            if [ -n "$old" ] && [ "$(cat /proc/$old/comm 2>/dev/null)" != "cron" ]; then
                rm -f /run/crond.pid
            fi
        fi
        /usr/bin/systemctl enable cron >/dev/null 2>&1
        /usr/bin/systemctl start cron >/dev/null 2>&1
        # cron writes /run/crond.pid 0600, so `systemctl is-active cron`
        # reports inactive for every non-root user: the shim reads the pid from
        # that file and ubuntu cannot open it. Same fix as sshd.pid above.
        for _ in 1 2 3 4 5; do
            [ -f /run/crond.pid ] && break
            sleep 1
        done
        [ -f /run/crond.pid ] && chmod 644 /run/crond.pid 2>/dev/null
    fi
}
start_cron

# Nothing here runs logind, so no user manager starts the units a user enabled
# in ~/.config/systemd/user. `systemctl default` only walks the system target,
# so an enabled user unit stayed inactive (dead) after every reboot and had to
# be started by hand. Start them here, the way systemd's user@<uid>.service
# does for a user with linger.
as_user() {
    user=$1
    shift
    uid=$(id -u "$user" 2>/dev/null) || return 1
    home=$(getent passwd "$user" | cut -d: -f6)
    [ -n "$home" ] && [ -d "$home" ] || return 1
    runuser -u "$user" -- env -i \
        HOME="$home" USER="$user" LOGNAME="$user" SHELL=/bin/bash \
        PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
        XDG_RUNTIME_DIR="/run/user/$uid" \
        DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$uid/bus" \
        "$@"
}

# /run is a plain directory on /data here, not a tmpfs, so the status files a
# unit wrote before the reboot are still there. Android reuses pids fast, so a
# recorded MainPID can name an unrelated process that is alive right now, and
# the shim would then believe the unit is already running and skip the start.
# Drop every record that did not come from this boot.
clean_stale_user_state() {
    user=$1
    uid=$(id -u "$user" 2>/dev/null) || return 0
    dir=/run/user/$uid/run
    [ -d "$dir" ] || return 0
    boot_id=$(cat /proc/sys/kernel/random/boot_id 2>/dev/null)
    for f in "$dir"/*.status; do
        [ -e "$f" ] || continue
        recorded=$(sed -n 's/^BootID=//p' "$f" 2>/dev/null | head -1)
        if [ -n "$boot_id" ] && [ -n "$recorded" ] && [ "$recorded" != "$boot_id" ]; then
            rm -f "$f"
            continue
        fi
        pid=$(sed -n 's/^MainPID=//p' "$f" 2>/dev/null | head -1)
        if [ -n "$pid" ] && [ ! -d "/proc/$pid" ]; then
            rm -f "$f"
        fi
    done
}

start_user_units() {
    for user in $(getent passwd | awk -F: '$3 >= 1000 && $3 < 60000 {print $1}'); do
        home=$(getent passwd "$user" | cut -d: -f6)
        [ -n "$home" ] && [ -d "$home" ] || continue
        [ -d "$home/.config/systemd/user" ] || continue
        clean_stale_user_state "$user"
        seen=" "
        for wants in "$home"/.config/systemd/user/*.wants; do
            [ -d "$wants" ] || continue
            for link in "$wants"/*.service "$wants"/*.socket; do
                [ -e "$link" ] || continue
                unit=$(basename "$link")
                case "$seen" in *" $unit "*) continue ;; esac
                seen="$seen$unit "
                as_user "$user" /usr/bin/systemctl --user start "$unit" >/dev/null 2>&1
                state=$(as_user "$user" /usr/bin/systemctl --user is-active "$unit" 2>/dev/null)
                echo "  user unit $user/$unit -> ${state:-unknown}"
            done
        done
    done
}
start_user_units

# Adaptive governor, not performance. This device runs without a heatsink, and
# `performance` pins every core at its maximum frequency even at idle. schedutil
# scales with load and drops back when the box is quiet, while the kernel's own
# thermal throttling (apc1-cpu*-step, cpuss0-step) stays in charge. All eight
# cores are left online; nothing here parks them.
set_cpu_governor() {
    gov=""
    for g in schedutil interactive ondemand; do
        if grep -qw "$g" /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors 2>/dev/null; then
            gov=$g
            break
        fi
    done
    [ -n "$gov" ] || return 0
    for c in /sys/devices/system/cpu/cpu[0-9]*/cpufreq/scaling_governor; do
        [ -w "$c" ] && echo "$gov" > "$c" 2>/dev/null
    done
}
set_cpu_governor
echo "[$(date -Is)] boot-services: done"
