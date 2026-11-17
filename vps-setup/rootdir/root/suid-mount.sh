#!/bin/bash
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
