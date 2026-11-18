#!/bin/bash
# Copyright (c) 2026 ziachi - https://github.com/ziachi/santoni_qassa_ubuntu
#
# apply.sh — apply the chroot overlay to a running Ubuntu chroot.
#
#   apply.sh [OVERLAY_DIR]
#
# Run as root INSIDE the chroot. Idempotent: re-running converges to the same
# state, and a backup that already exists is never overwritten.
#
# OVERLAY_DIR defaults to ./rootdir next to this script. It mirrors the chroot
# layout, so rootdir/usr/sbin/sshd lands at /usr/sbin/sshd.
#
# Why the pieces exist:
#   suid-mount.sh + the sshd wrapper  Android mounts /data nosuid, so every
#                                     setuid bit in the chroot is inert and sudo
#                                     dies with "effective uid is not 0". A bind
#                                     mount carries its own flags, so re-binding
#                                     /usr/bin and /usr/sbin with suid fixes it.
#                                     init.ubuntu.sh runs /usr/sbin/sshd with no
#                                     arguments, so that wrapper is the only hook
#                                     guaranteed to run on every boot.
#   policy-rc.d + runlevel shim       apt postinst must not try to start services
#                                     in a chroot, and systemd ships runlevel as a
#                                     symlink to systemctl, whose unit table breaks
#                                     invoke-rc.d's runlevel parsing.
#   systemctl replacement             docker-systemctl-replacement, patched so
#                                     get_boottime_from_old_proc skips the
#                                     non-numeric entries in /proc.
#   pidfile drop-in                   lets `systemctl status ssh` report the sshd
#                                     that init.ubuntu.sh started, not "inactive".

set -euo pipefail

HERE=$(cd -- "$(dirname -- "$0")" && pwd)
OVERLAY=${1:-$HERE/rootdir}

[ "$(id -u)" = 0 ] || { echo "apply.sh: must run as root" >&2; exit 1; }
[ -d "$OVERLAY" ] || { echo "apply.sh: overlay not found: $OVERLAY" >&2; exit 1; }

say() { printf '\n=== %s ===\n' "$*"; }

# ELF magic, so a re-run never copies a wrapper over the real binary backup.
is_elf() {
    [ "$(dd if="$1" bs=4 count=1 2>/dev/null | od -An -tx1 | tr -d ' \n')" = "7f454c46" ]
}

# install(1) writes in place and fails with ETXTBSY on a running binary, so
# stage next to the target and rename over it.
put_file() {
    src=$1 dst=$2 mode=$3 owner=$4
    dir=$(dirname -- "$dst")
    mkdir -p "$dir"
    tmp="$dir/.$(basename -- "$dst").vps-new"
    install -m "$mode" -o "${owner%%:*}" -g "${owner##*:}" "$src" "$tmp"
    mv -f "$tmp" "$dst"
}

# -------------------------------------------------------------------- 1. groups
say "1. Android network groups"
add_group() { getent group "$1" >/dev/null 2>&1 || groupadd -g "$2" "$1"; }
add_group aid_inet 3003
add_group aid_net_raw 3004
add_group aid_sdcard_rw 1015
getent group aid_inet aid_net_raw aid_sdcard_rw

# Android's paranoid network check gates socket() on the caller's GID, not on
# capabilities, so root needs the same groups as ubuntu: without aid_inet even
# getaddrinfo fails, and without aid_net_raw ping dies with "socket: Permission
# denied" even though /bin/ping carries cap_net_raw.
usermod -aG aid_inet,aid_net_raw root
id root

# ---------------------------------------------------------------------- 2. user
say "2. user ubuntu"
id ubuntu >/dev/null 2>&1 || useradd -m -u 1000 -s /bin/bash -U ubuntu
usermod -aG sudo,aid_inet,aid_net_raw,aid_sdcard_rw ubuntu
id ubuntu

# `passwd -S` field 2 is the state flag, not the password: P=set, L=locked,
# NP=none. Printing it raw reads like the password is literally "P".
passwd_state() {
    case "$(passwd -S "$1" 2>/dev/null | awk '{print $2}')" in
        P)  echo "set" ;;
        L)  echo "locked" ;;
        NP) echo "none" ;;
        *)  echo "unknown" ;;
    esac
}

# Default password. chpasswd in this chroot can exit 0 without writing
# /etc/shadow, so the field is checked and openssl is the fallback.
# vps-setup passes UBUNTU_USER_PASS so the value it prints in its summary is
# the one that was actually set here.
UBUNTU_USER_PASS=${UBUNTU_USER_PASS:-ubuntu}
set_ubuntu_password() {
    printf 'ubuntu:%s\n' "$1" | chpasswd 2>/dev/null || true
    if grep -q '^ubuntu:[!*]' /etc/shadow 2>/dev/null && [ -x /usr/bin/openssl ]; then
        hash=$(printf '%s\n' "$1" | /usr/bin/openssl passwd -6 -stdin 2>/dev/null)
        [ -n "$hash" ] && usermod -p "$hash" ubuntu 2>/dev/null || true
    fi
}
set_ubuntu_password "$UBUNTU_USER_PASS"
printf '  password -> %s\n' "$UBUNTU_USER_PASS"
printf '  passwd   -> %s\n' "$(passwd_state ubuntu)"

# ------------------------------------------------------------------- 3. backups
say "3. back up the original binaries before the wrappers replace them"
# systemctl.orig and sshd.real are package binaries, so they are not committed.
# They are captured here, once, before the overlay replaces them.
if [ ! -e /usr/bin/systemctl.orig ] && is_elf /usr/bin/systemctl; then
    cp -a /usr/bin/systemctl /usr/bin/systemctl.orig
    echo "  systemctl.orig created"
elif [ -e /usr/bin/systemctl.orig ]; then
    echo "  systemctl.orig already present"
else
    echo "  systemctl is not an ELF, systemctl.orig skipped"
fi
if [ ! -e /usr/sbin/sshd.real ] && is_elf /usr/sbin/sshd; then
    cp -a /usr/sbin/sshd /usr/sbin/sshd.real
    echo "  sshd.real created"
elif [ -e /usr/sbin/sshd.real ]; then
    echo "  sshd.real already present"
else
    echo "  sshd is not an ELF, sshd.real skipped"
fi

# ------------------------------------------------------------------- 4. overlay
say "4. copy the overlay"
while IFS= read -r rel; do
    case "$rel" in
        home/ubuntu/*)          mode=644; owner=ubuntu:ubuntu ;;
        etc/sudoers.d/*)        mode=440; owner=root:root ;;
        usr/bin/systemctl|usr/sbin/sshd|usr/sbin/policy-rc.d|usr/sbin/runlevel|usr/local/bin/journalctl|usr/local/sbin/*.sh)
                                mode=755; owner=root:root ;;
        *)                      mode=644; owner=root:root ;;
    esac
    put_file "$OVERLAY/$rel" "/$rel" "$mode" "$owner"
    printf '  %-52s %s %s\n' "/$rel" "$mode" "$owner"
done < <(cd "$OVERLAY" && find . -type f | sed 's|^\./||' | sort)

# The boot scripts used to live in /root, where an operator tidying up the home
# directory could delete them. They are installed from usr/local/sbin now, so
# drop the old copies: a device that ran an older apply.sh converges instead of
# keeping a stale duplicate next to the dotfiles.
for legacy in /root/boot-services.sh /root/suid-mount.sh; do
    if [ -e "$legacy" ]; then
        rm -f "$legacy"
        echo "  removed legacy $legacy"
    fi
done

# sudo refuses to run at all when /etc/sudoers.d is group- or world-writable,
# and `mkdir -p` creates a missing directory with the ambient umask. Pin the
# directories the overlay writes into so a fresh chroot cannot end up with
# "sudo: /etc/sudoers.d is world writable".
for d in /etc/sudoers.d /etc/systemd/system/ssh.service.d; do
    [ -d "$d" ] || continue
    chmod 755 "$d"
    chown root:root "$d"
done

# ----------------------------------------------------------- 5. editor + locale
say "5. editor default + locale"
if [ -x /usr/bin/nano ]; then
    update-alternatives --set editor /usr/bin/nano >/dev/null 2>&1 || true
fi
if [ -f /etc/locale.gen ]; then
    sed -i 's/^# *en_US\.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
fi
if command -v locale-gen >/dev/null 2>&1; then
    locale-gen en_US.UTF-8 >/dev/null 2>&1 || true
fi
printf '  editor -> %s\n' "$(readlink -f /usr/bin/editor 2>/dev/null || echo '?')"
printf '  LANG   -> %s\n' "$(sed -n 's/^LANG=//p' /etc/default/locale 2>/dev/null | head -1)"

# -------------------------------------------------------------- 6. unit disable
say "6. disable unused units"
for u in e2scrub_reap.service networkd-dispatcher.service systemd-resolved.service; do
    if [ -e "/etc/systemd/system/$u" ] || [ -e "/lib/systemd/system/$u" ] || [ -e "/usr/lib/systemd/system/$u" ]; then
        systemctl disable "$u" >/dev/null 2>&1 || true
        printf '  %-32s %s\n' "$u" "$(systemctl is-enabled "$u" 2>&1 | tail -1)"
    fi
done

# ---------------------------------------------------------------- 7. suid mount
say "7. install the suid bind mounts"
[ -x /usr/local/sbin/suid-mount.sh ] && /usr/local/sbin/suid-mount.sh
# Print the mount point, its source and its options. The old
# `sed 's/ .*ext4/ ext4/'` was greedy: it ate the mount point and every option,
# so the check printed the userdata line four times and never showed whether
# the suid bind mounts were actually in place.
awk '$2 == "/usr/bin" || $2 == "/usr/sbin" { printf "  %-10s %s  %s\n", $2, $1, $4 }' /proc/mounts
grep -qE ' /usr/(bin|sbin) ' /proc/mounts || echo "  (not mounted yet)"

# systemctl3.py reads PIDFile for status; a stale or empty file reports the
# running sshd as inactive and makes `systemctl default` try a second one.
pid=$(pgrep -f 'sshd.*\[listener\]' | head -1 || true)
[ -n "${pid:-}" ] && echo "$pid" > /run/sshd.pid

# -------------------------------------------------------------------- 8. verify
say "8. verify"
# sshd is started by init.ubuntu.sh on boot and by vps-setup right after this
# script on a fresh install, so the unit can legitimately still be inactive
# here. Report the daemon itself: `systemctl status ssh` printed
# "Active: inactive (dead)" on a first-time setup and read like a failure.
systemctl start ssh >/dev/null 2>&1 || true
# Every check below is informational. A missing tool must not abort the script:
# `set -e` plus `pipefail` used to turn a failed `systemctl status` into
# "overlay FAILED" even though the overlay itself had applied cleanly.
printf '  sudo   -> %s\n' "$(su - ubuntu -c 'sudo -n whoami' 2>&1 | head -1 || true)"
printf '  editor -> %s\n' "$(su - ubuntu -c 'editor --version 2>/dev/null | head -1' 2>&1 || true)"
printf '  passwd -> %s\n' "$(passwd_state ubuntu)"
if pgrep -f 'sshd.*\[listener\]' >/dev/null 2>&1; then
    printf '  sshd   -> running (pid %s)\n' "$(pgrep -f 'sshd.*\[listener\]' | head -1)"
else
    printf '  sshd   -> not started yet (vps-setup starts it after this script)\n'
fi

echo
echo "apply.sh: done"
