#!/bin/bash
# Copyright (c) 2026 ziachi - https://github.com/ziachi/santoni_qassa_ubuntu
# Run automatically by the /usr/sbin/sshd wrapper 5 seconds after sshd comes up,
# so it needs no change in init.ubuntu.sh. Idempotent, safe to run by hand at
# any time.
exec >>/var/log/boot-services.log 2>&1
echo "[$(date -Is)] boot-services: start"
/root/suid-mount.sh

# Third-party installers check [ -d /run/systemd/system ] or sd_booted() to
# decide whether this host is systemd. Without that directory many installers
# fall back to the non-systemd path (sysvinit/openrc) and skip systemctl
# entirely.
mkdir -p /run/systemd/system 2>/dev/null
chmod 755 /run/systemd/system 2>/dev/null

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

# cron is in packages.list, so `crontab` and /etc/init.d/cron are both present,
# but nothing ever enabled the daemon: the unit sat at inactive (dead) and
# disabled, and a job written with `crontab -e` was accepted and never ran.
# Enable and start it here, after sshd is settled, so a slow or failing cron
# cannot delay the login path. Both calls are idempotent.
start_cron() {
    if [ -f /lib/systemd/system/cron.service ] || [ -f /etc/init.d/cron ]; then
        /usr/bin/systemctl enable cron >/dev/null 2>&1
        /usr/bin/systemctl start cron >/dev/null 2>&1
    fi
}
start_cron

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
