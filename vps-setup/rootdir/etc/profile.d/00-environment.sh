# Apply /etc/environment to every login shell.
#
# sshd in this chroot runs on the Android side, outside the chroot, so the PAM
# stack in /etc/pam.d/sshd never runs for an SSH login and pam_env never reads
# /etc/environment. su(1) and sudo(1) do run inside the chroot and do apply it,
# which is why the same account has EDITOR set under `sudo -i` but empty over
# SSH. Sourcing the file here gives every login shell the same PATH, EDITOR,
# VISUAL and PAGER a stock Ubuntu Server session has, without depending on PAM.
if [ -r /etc/environment ] && sh -n /etc/environment 2>/dev/null; then
    set -a
    . /etc/environment
    set +a
fi
