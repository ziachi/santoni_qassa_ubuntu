#!/bin/bash
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

# ---------------------------------------------------------------- 1. groups
say "1. Android network groups"
add_group() { getent group "$1" >/dev/null 2>&1 || groupadd -g "$2" "$1"; }
add_group aid_inet 3003
add_group aid_net_raw 3004
add_group aid_sdcard_rw 1015
getent group aid_inet aid_net_raw aid_sdcard_rw

# ------------------------------------------------------------------ 2. user
say "2. user ubuntu"
id ubuntu >/dev/null 2>&1 || useradd -m -u 1000 -s /bin/bash -U ubuntu
usermod -aG sudo,aid_inet,aid_net_raw,aid_sdcard_rw ubuntu
id ubuntu

# --------------------------------------------------------------- 3. backups
say "3. backup binary asli sebelum ditimpa wrapper"
# systemctl.orig and sshd.real are package binaries, so they are not committed.
# They are captured here, once, before the overlay replaces them.
if [ ! -e /usr/bin/systemctl.orig ] && is_elf /usr/bin/systemctl; then
    cp -a /usr/bin/systemctl /usr/bin/systemctl.orig
    echo "  systemctl.orig dibuat"
elif [ -e /usr/bin/systemctl.orig ]; then
    echo "  systemctl.orig sudah ada"
else
    echo "  systemctl bukan ELF, systemctl.orig dilewati"
fi
if [ ! -e /usr/sbin/sshd.real ] && is_elf /usr/sbin/sshd; then
    cp -a /usr/sbin/sshd /usr/sbin/sshd.real
    echo "  sshd.real dibuat"
elif [ -e /usr/sbin/sshd.real ]; then
    echo "  sshd.real sudah ada"
else
    echo "  sshd bukan ELF, sshd.real dilewati"
fi

# ---------------------------------------------------------------- 4. overlay
say "4. salin overlay"
while IFS= read -r rel; do
    case "$rel" in
        home/ubuntu/*)          mode=644; owner=ubuntu:ubuntu ;;
        etc/sudoers.d/*)        mode=440; owner=root:root ;;
        usr/bin/systemctl|usr/sbin/sshd|usr/sbin/policy-rc.d|usr/sbin/runlevel|usr/local/bin/journalctl|root/*.sh)
                                mode=755; owner=root:root ;;
        *)                      mode=644; owner=root:root ;;
    esac
    put_file "$OVERLAY/$rel" "/$rel" "$mode" "$owner"
    printf '  %-52s %s %s\n' "/$rel" "$mode" "$owner"
done < <(cd "$OVERLAY" && find . -type f | sed 's|^\./||' | sort)

# ------------------------------------------------------- 5. editor + locale
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

# ------------------------------------------------------------ 6. unit disable
say "6. disable unit yang tidak dipakai"
for u in e2scrub_reap.service networkd-dispatcher.service systemd-resolved.service; do
    if [ -e "/etc/systemd/system/$u" ] || [ -e "/lib/systemd/system/$u" ] || [ -e "/usr/lib/systemd/system/$u" ]; then
        systemctl disable "$u" >/dev/null 2>&1 || true
        printf '  %-32s %s\n' "$u" "$(systemctl is-enabled "$u" 2>&1 | tail -1)"
    fi
done

# --------------------------------------------------------------- 7. suid mount
say "7. pasang suid bind mount"
[ -x /root/suid-mount.sh ] && /root/suid-mount.sh
grep -E ' /usr/bin | /usr/sbin ' /proc/mounts | sed 's/ .*ext4/ ext4/' || echo "  (belum terpasang)"

# systemctl3.py reads PIDFile for status; a stale or empty file reports the
# running sshd as inactive and makes `systemctl default` try a second one.
pid=$(pgrep -f 'sshd.*\[listener\]' | head -1 || true)
[ -n "${pid:-}" ] && echo "$pid" > /run/sshd.pid

# ---------------------------------------------------------------- 8. verifikasi
say "8. verifikasi"
printf '  sudo   -> %s\n' "$(su - ubuntu -c 'sudo -n whoami' 2>&1 | head -1)"
printf '  editor -> %s\n' "$(su - ubuntu -c 'editor --version 2>/dev/null | head -1' 2>&1)"
systemctl status ssh 2>&1 | head -4

echo
echo "apply.sh: selesai"
