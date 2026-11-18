#!/bin/bash
# Copyright (c) 2026 ziachi - https://github.com/ziachi/santoni_qassa_ubuntu
# Dijalankan otomatis oleh wrapper /usr/sbin/sshd 5 detik setelah sshd hidup,
# jadi tidak butuh perubahan di init.ubuntu.sh. Idempoten, aman dijalankan
# manual kapan saja.
exec >>/var/log/boot-services.log 2>&1
echo "[$(date -Is)] boot-services: start"
/root/suid-mount.sh

# systemctl3.py menentukan status ssh.service dari PIDFile. sshd menulis file itu
# saat daemonize, tapi di awal boot bisa ter-truncate jadi 0 byte (sshd kedua yang
# gagal bind :22). Tulis ulang dari listener yang benar-benar hidup, sebelum dan
# sesudah `systemctl default`, supaya status tidak "inactive (dead)" dan systemctl
# tidak mencoba menyalakan sshd kedua.
assert_sshd_pid() {
    pid=$(pgrep -f 'sshd.*\[listener\]' | head -1)
    [ -n "$pid" ] && echo "$pid" > /run/sshd.pid
}
assert_sshd_pid
/usr/bin/systemctl default
assert_sshd_pid

# Governor adaptif, bukan performance. This device runs without a heatsink, and
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
