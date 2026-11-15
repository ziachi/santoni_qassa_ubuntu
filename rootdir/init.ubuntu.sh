#!/system/bin/sh
#
# init.ubuntu.sh — bring up the Ubuntu chroot as a 24/7 VPS.
#
# Started by init.ubuntu.rc once sys.boot_completed=1, so Android has already
# finished booting and /data is decrypted and mounted.

UBUNTU_ROOT=/data/ubuntu
ZRAM_DEV=/dev/block/zram0
ZRAM_BYTES=2147483648
WAKE_LOCK=vps_server_lock

log() {
    echo "vps-boot: $*"
}

# --- 1. Anti deep-sleep --------------------------------------------------
# A held wake lock keeps the SoC out of suspend so sshd stays reachable.
if [ -w /sys/power/wake_lock ]; then
    if echo "$WAKE_LOCK" > /sys/power/wake_lock 2>/dev/null; then
        log "wake lock '$WAKE_LOCK' held"
    else
        log "could not take wake lock '$WAKE_LOCK'"
    fi
else
    log "no /sys/power/wake_lock, skipping"
fi

# --- 2. ZRAM 2 GB --------------------------------------------------------
# fstab.qcom already asks for zramsize=2147483648, so normally this is only a
# check. It reconfigures when the running size differs, which is what happens
# on a device that booted with the old 1 GB fstab.
if [ -e "$ZRAM_DEV" ]; then
    current=$(cat /sys/block/zram0/disksize 2>/dev/null)
    if [ "$current" != "$ZRAM_BYTES" ]; then
        log "zram0 is ${current:-unknown} bytes, resizing to $ZRAM_BYTES"
        swapoff "$ZRAM_DEV" 2>/dev/null
        echo 1 > /sys/block/zram0/reset 2>/dev/null
        echo "$ZRAM_BYTES" > /sys/block/zram0/disksize 2>/dev/null
        mkswap "$ZRAM_DEV" >/dev/null 2>&1
    fi
    if grep -q "^$ZRAM_DEV " /proc/swaps 2>/dev/null; then
        log "zram0 swap already active"
    elif swapon "$ZRAM_DEV" 2>/dev/null; then
        log "zram0 swap active"
    else
        log "could not swapon $ZRAM_DEV"
    fi
else
    log "no $ZRAM_DEV, skipping swap"
fi

# --- 3. Ubuntu chroot ----------------------------------------------------
if [ ! -x "$UBUNTU_ROOT/bin/bash" ]; then
    log "no Ubuntu at $UBUNTU_ROOT — run vps-setup over USB"
    exit 0
fi

for d in dev dev/pts proc sys run; do
    mkdir -p "$UBUNTU_ROOT/$d"
    if grep -q " $UBUNTU_ROOT/$d " /proc/mounts 2>/dev/null; then
        continue
    fi
    if mount --bind "/$d" "$UBUNTU_ROOT/$d" 2>/dev/null; then
        log "bind-mounted /$d"
    else
        log "could not bind-mount /$d"
    fi
done

if [ -x "$UBUNTU_ROOT/usr/sbin/sshd" ]; then
    if chroot "$UBUNTU_ROOT" /usr/sbin/service ssh start >/dev/null 2>&1; then
        log "sshd started"
    else
        log "sshd failed to start"
    fi
else
    log "openssh-server not installed — apt install -y openssh-server"
fi
