#!/system/bin/sh
#
# ubuntu-enter — adbd login shell for the headless santoni VPS.
#
#   USB attached (gadget CONFIGURED)  -> straight in, no password
#   Wi-Fi only (gadget DISCONNECTED)  -> hidden password prompt, 3 tries, exit 1
#
# DEBUG_NO_PASSWORD=0 below keeps the Wi-Fi prompt active. Setting it to 1
# disables the prompt on every transport; read the note there before doing so.
#
# The Wi-Fi password lives in /data/adb_wifi_pass and defaults to
# "santoniadmin". Change it with:
#     echo 'newpassword' > /data/adb_wifi_pass
#     chmod 600 /data/adb_wifi_pass
#
# After authentication the session is chrooted into /data/ubuntu as root. If
# Ubuntu is not installed yet, it drops to /system/bin/sh with a hint.

PASS_FILE=/data/adb_wifi_pass
DEFAULT_PASS=santoniadmin
UBUNTU_ROOT=/data/ubuntu
MAX_TRIES=3

# --- DEBUG MODE ----------------------------------------------------------
# 1 = no password prompt on any transport. A USB cable and ADB over Wi-Fi on
# port 5555 both land straight in the root Ubuntu shell.
#
# This is a debug-phase setting. Together with ro.adb.secure=0 and ro.secure=0
# it means anyone who can reach port 5555 is root, so it is only acceptable
# while the device sits on a trusted LAN. It is 0 here, so the gate below is
# active: USB lands straight in, Wi-Fi asks for the password.
DEBUG_NO_PASSWORD=0

usb_configured() {
    state=""
    if [ -r /sys/class/android_usb/android0/state ]; then
        state=$(cat /sys/class/android_usb/android0/state 2>/dev/null)
    fi
    if [ -z "$state" ]; then
        state=$(getprop sys.usb.state 2>/dev/null)
    fi
    [ "$state" = "CONFIGURED" ]
}

expected_password() {
    if [ -r "$PASS_FILE" ]; then
        cat "$PASS_FILE" 2>/dev/null
    else
        echo "$DEFAULT_PASS"
    fi
}

prompt_password() {
    want=$(expected_password)
    tries=0
    while [ "$tries" -lt "$MAX_TRIES" ]; do
        printf 'Password: '
        # mksh's "read -s" means "save to history", not "silent", so echo has
        # to be turned off with stty instead.
        stty -echo 2>/dev/null
        read -r given
        stty echo 2>/dev/null
        printf '\n'
        if [ "$given" = "$want" ]; then
            return 0
        fi
        tries=$((tries + 1))
        printf 'Wrong password (%d/%d)\n' "$tries" "$MAX_TRIES"
    done
    return 1
}

bind_mount() {
    src=$1
    dst=$2
    [ -d "$dst" ] || return 0
    grep -q " $dst " /proc/mounts 2>/dev/null && return 0
    mount --bind "$src" "$dst" 2>/dev/null
}

enter_ubuntu() {
    for d in dev dev/pts proc sys; do
        bind_mount "/$d" "$UBUNTU_ROOT/$d"
    done
    # /etc/profile in ubuntu-base sets PS1 but never PATH, so a plain
    # `bash -l` keeps Android's PATH and loses /usr/bin. Build the
    # environment here instead of relying on the rootfs.
    #
    # chroot keeps the caller's credentials, so the shell also inherits
    # Android's supplementary groups. /etc/bash.bashrc runs $(groups) for its
    # sudo hint on every interactive login, and Ubuntu's /etc/group has no
    # names for those gids, so each one prints "groups: cannot find name for
    # group ID". setpriv --clear-groups drops them; skip it if util-linux is
    # missing.
    if [ -x "$UBUNTU_ROOT/usr/bin/setpriv" ]; then
        exec chroot "$UBUNTU_ROOT" /usr/bin/env -i \
            PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
            HOME=/root USER=root LOGNAME=root SHELL=/bin/bash \
            TERM="${TERM:-xterm}" \
            /usr/bin/setpriv --clear-groups /bin/bash -l
    fi
    exec chroot "$UBUNTU_ROOT" /usr/bin/env -i \
        PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
        HOME=/root USER=root LOGNAME=root SHELL=/bin/bash \
        TERM="${TERM:-xterm}" \
        /bin/bash -l
}

# adbd runs "<shell> -c <command>" for "adb shell <command>". Authenticate
# first, then hand the command to the real shell.
if [ "$1" = "-c" ]; then
    shift
    if [ "$DEBUG_NO_PASSWORD" != "1" ] && ! usb_configured && ! prompt_password; then
        echo "Too many wrong passwords."
        exit 1
    fi
    exec /system/bin/sh -c "$*"
fi

if [ "$DEBUG_NO_PASSWORD" != "1" ] && ! usb_configured && ! prompt_password; then
    echo "Too many wrong passwords."
    exit 1
fi

if [ -x "$UBUNTU_ROOT/bin/bash" ]; then
    enter_ubuntu
fi

echo "Ubuntu is not installed yet."
echo "Run this over USB first:"
echo "    vps-setup <SSID> <WIFI_PASSWORD>"
exec /system/bin/sh
