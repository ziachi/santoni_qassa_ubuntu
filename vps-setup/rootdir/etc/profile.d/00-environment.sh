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

# There is no logind, so nothing exports the per-user runtime directory or the
# session bus address that a stock Ubuntu login session gets. user-session-bus.sh
# creates both at boot; point the shell at them so `systemctl --user` and D-Bus
# clients find the same paths they would on a normal server.
if [ -z "${XDG_RUNTIME_DIR:-}" ] && [ -d "/run/user/$(id -u)" ]; then
    XDG_RUNTIME_DIR="/run/user/$(id -u)"
    export XDG_RUNTIME_DIR
fi
if [ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ] && [ -S "/run/user/$(id -u)/bus" ]; then
    DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
    export DBUS_SESSION_BUS_ADDRESS
fi
