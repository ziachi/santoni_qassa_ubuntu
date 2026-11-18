#!/bin/bash
# Copyright (c) 2026 ziachi - https://github.com/ziachi/santoni_qassa_ubuntu
# Android mounts /data with nosuid, so every setuid bit inside the chroot is
# inert: sudo/su/passwd die with "effective uid is not 0". A bind mount carries
# its own flags, so re-binding the directory with suid enabled fixes it without
# touching the underlying filesystem.
for d in /usr/bin /usr/sbin; do
    [ -d "$d" ] || continue
    if grep -q " $d " /proc/mounts; then
        mount -o remount,bind,suid "$d" 2>/dev/null
    else
        mount --bind "$d" "$d" 2>/dev/null && mount -o remount,bind,suid "$d" 2>/dev/null
    fi
done

# Java NIO (Files.getFileStore) walks up to the nearest mount point and throws
# "Mount point not found" when the chroot's / is absent from the mount table.
# Geyser's NetherNet listener hits exactly that, so its Bedrock port never
# opens. Binding / onto itself adds the entry without changing what the path
# resolves to. Idempotent: skipped when / is already a mount point.
#
# It has to be --rbind, not --bind. A plain bind hides the submounts, so /proc,
# /sys and /dev disappear: /dev falls back to the bare directory on the rootfs,
# /dev/null stops being writable, and sshd dies with "cannot open /dev/null:
# Permission denied". --rbind carries the submounts across.
if ! grep -qE "^[^ ]+ / " /proc/mounts; then
    mount --rbind / / 2>/dev/null
fi

# /dev/shm is a tmpfs on a normal Linux box. The Android /dev rbind does not
# bring one, and anything that uses shared memory (Python multiprocessing,
# Chromium, PostgreSQL) fails without it. Idempotent: skipped when the mount
# is already there.
mkdir -p /dev/shm 2>/dev/null
chmod 1777 /dev/shm 2>/dev/null
if ! grep -q " /dev/shm " /proc/mounts; then
    mount -t tmpfs -o mode=1777,nosuid,nodev tmpfs /dev/shm 2>/dev/null
fi
