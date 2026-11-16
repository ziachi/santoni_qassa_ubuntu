#
# BusyBox: static aarch64 build, for the applets Android's toybox does not have.
#
# udhcpc is the reason this exists. Zygote is stopped at boot (see
# rootdir/init.ubuntu.sh), so nothing in the framework renews the wlan0 lease
# any more and udhcpc does it instead. wget is the fallback downloader for
# vps-setup when curl is unavailable.
#
# Source: Alpine Linux v3.22 main/aarch64 busybox-static-1.37.0-r20.apk
#   https://dl-cdn.alpinelinux.org/alpine/v3.22/main/aarch64/busybox-static-1.37.0-r20.apk
#   bin/busybox.static, musl, statically linked, stripped
#   sha256 a6bb1e6e349cbdfa690a78cd0017413c5446bdae02ee003ceb682d4ae1a004ff
#
# A static musl build is used instead of an in-tree one because this tree has no
# external/busybox, and because musl's resolver is built in: a glibc static
# binary would need libnss_dns.so at runtime, which Android does not ship.
#
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE       := busybox
LOCAL_MODULE_TAGS  := optional
LOCAL_MODULE_CLASS := EXECUTABLES
LOCAL_SRC_FILES    := busybox
LOCAL_MODULE_PATH  := $(TARGET_OUT)/bin
include $(BUILD_PREBUILT)
