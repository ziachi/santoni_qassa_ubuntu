#!/bin/bash
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
echo "[$(date -Is)] boot-services: done"
