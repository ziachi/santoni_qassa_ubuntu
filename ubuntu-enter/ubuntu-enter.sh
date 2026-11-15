#!/system/bin/sh
#
# ubuntu-enter — adbd login shell for the headless santoni VPS.
#
#   USB attached (gadget CONFIGURED)  -> straight in, no password
#   Wi-Fi only (gadget DISCONNECTED)  -> hidden password prompt, 3 tries, exit 1
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
        printf 'ADB Wi-Fi Password: '
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
    exec chroot "$UBUNTU_ROOT" /bin/bash -l
}

# adbd runs "<shell> -c <command>" for "adb shell <command>". Authenticate
# first, then hand the command to the real shell.
if [ "$1" = "-c" ]; then
    shift
    if ! usb_configured && ! prompt_password; then
        echo "Too many wrong passwords. Closing session."
        exit 1
    fi
    exec /system/bin/sh -c "$*"
fi

if ! usb_configured && ! prompt_password; then
    echo "Too many wrong passwords. Closing session."
    exit 1
fi

if [ -x "$UBUNTU_ROOT/bin/bash" ]; then
    enter_ubuntu
fi

echo "Ubuntu is not installed yet."
echo "Run this over USB first:"
echo "    vps-setup <SSID> <WIFI_PASSWORD>"
exec /system/bin/sh
