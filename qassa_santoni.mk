#
# Copyright (C) 2019 The Lineage-OS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

$(call inherit-product, device/xiaomi/santoni/full_santoni.mk)

# Inherit some common Qassa stuff.
$(call inherit-product, vendor/qassa/config/common_full_phone.mk)

PRODUCT_DEVICE := santoni
PRODUCT_BRAND := Xiaomi
PRODUCT_MODEL := Redmi 4X
PRODUCT_NAME := qassa_santoni
BOARD_VENDOR := Xiaomi
PRODUCT_MANUFACTURER := Xiaomi

TARGET_FACE_UNLOCK_SUPPORTED := true
USE_PIXEL_CHARGER := true

# Boot animation
TARGET_BOOT_ANIMATION_RES := 720

PRODUCT_GMS_CLIENTID_BASE := android-xiaomi

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="santoni-user 7.1.2 N2G47H V9.5.10.0.NAMMIFD release-keys"

# Set BUILD_FINGERPRINT variable to be picked up by both system and vendor build.prop
BUILD_FINGERPRINT := "Xiaomi/santoni/santoni:7.1.2/N2G47H/V9.5.10.0.NAMMIFD:user/release-keys"

# ========================================
# Customizations by ziachi (Unofficial)
# ========================================

# Build type: Unofficial
QASSA_BUILD_TYPE := UNOFFICIAL

# ========================================
# Headless VPS mode
# ========================================
# The device is driven over ADB only, so the Android UI is dead weight.
#
# Do NOT strip the UI with `PRODUCT_PACKAGES := $(filter-out ...)` here.
# inherit-product is deferred in this tree (build/make/core/product.mk:378):
# it appends a $(INHERIT_TAG)<path> marker instead of including the makefile,
# so at this point PRODUCT_PACKAGES holds only those markers and the filter
# matches nothing. `get_build_var PRODUCT_PACKAGES` still lists SystemUI,
# Launcher3, Launcher3QuickStep and XiaomiAddon because of it.
#
# The mechanism that actually works is LOCAL_OVERRIDES_PACKAGES on the
# RemovePackages stub in prebuilts/Android.mk. main.mk:1110-1112 filters the
# overridden names out of PRODUCTS.<mk>.PRODUCT_PACKAGES before install, so
# the APKs never reach the image even though they stay in the requested list.
# Keep both lists in sync when adding a package here.
#
# The list there now covers every UI APK that was still installed: the 16 that
# survived the first pass (Settings, SettingsIntelligence, DocumentsUI, FMRadio,
# MatLog, Calendar, DeskClock, ExactCalculator, Gallery2, LatinIME, messaging,
# Contacts, Dialer, WallpaperCropper, WallpaperPicker2, LiveWallpapersPicker)
# plus the rest of the UI found by scanning out/target/product/santoni. Core
# system packages, providers and the telephony/modem stack are left alone.

# Maintainer
PRODUCT_PROPERTY_OVERRIDES += \
    ro.qassa.maintainer=ziachi \
    ro.qassa.maintainer.github=https://github.com/ziachi \
    ro.qassa.maintainer.telegram=https://t.me/kalomakan

# ADB: USB without the RSA signature prompt, plus ADB over Wi-Fi on 5555.
# ro.secure / ro.debuggable / ro.adb.secure are already implied by the
# userdebug variant, but they are pinned here so a "user" variant build
# behaves the same way.
PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.usb.config=adb \
    persist.service.adb.enable=1 \
    ro.adb.secure=0 \
    ro.secure=0 \
    ro.debuggable=1 \
    service.adb.tcp.port=5555 \
    persist.sys.adb.shell=/system/bin/ubuntu-enter

# No boot animation is drawn, but the bootanim service stays enabled so init
# still gets its service.bootanim.exit handshake. Disabling the service
# outright risks a boot stall (see CHANGELOG v22).
PRODUCT_PROPERTY_OVERRIDES += \
    debug.sf.nobootanimation=1

# Dual-auth login shell. adbd only honours persist.sys.adb.shell after the
# patch in patches/README.md is applied to system/core/adb.
PRODUCT_PACKAGES += \
    ubuntu-enter \
    vps-setup \
    wifi \
    udhcpc.script \
    busybox \
    wpa_cli \
    init.ubuntu.sh \
    init.ubuntu.rc \
    webcam_bridge \
    sensor_bridge \
    pulse-default.pa

# wpa_cli is the only way to join a network once Zygote is stopped: `cmd wifi`
# and `svc wifi` both need system_server. The module lives in
# external/wpa_supplicant_8 and installs to /vendor/bin because it is marked
# proprietary.
#
# busybox supplies udhcpc, which replaces the framework's DHCP client, and wget
# as a second downloader next to curl.
#
# busybox wget and nslookup read /etc/resolv.conf, which Android does not have
# because bionic asks netd instead. Ship a static one with public resolvers so
# those applets can resolve names; curl keeps using netd.
PRODUCT_COPY_FILES += \
    device/xiaomi/santoni/wifi/resolv.conf:system/etc/resolv.conf

# curl: vps-setup downloads the Ubuntu rootfs on the device. The in-tree
# external/curl module is used instead of a prebuilt static blob, so the
# binary is built from source and links the system libssl/libcrypto/libz.
PRODUCT_PACKAGES += \
    curl

# Signing with releasekey
PRODUCT_DEFAULT_DEV_CERTIFICATE := vendor/ziachi-keys/releasekey

# vps-setup/rootdir is the chroot overlay applied by vps-setup/apply.sh: the
# systemctl replacement, the sshd wrapper that re-establishes the suid bind
# mounts on every boot, policy-rc.d, the runlevel shim, the journalctl
# wrapper, and the sudoers/locale/editor defaults. Installed under
# /system/etc/vps-setup so vps-setup.sh can copy it into the chroot without a
# network round trip.
PRODUCT_COPY_FILES += \
    device/xiaomi/santoni/vps-setup/apply.sh:system/etc/vps-setup/apply.sh \
    device/xiaomi/santoni/vps-setup/packages.list:system/etc/vps-setup/packages.list \
    device/xiaomi/santoni/vps-setup/rootdir/usr/sbin/policy-rc.d:system/etc/vps-setup/rootdir/usr/sbin/policy-rc.d \
    device/xiaomi/santoni/vps-setup/rootdir/usr/sbin/runlevel:system/etc/vps-setup/rootdir/usr/sbin/runlevel \
    device/xiaomi/santoni/vps-setup/rootdir/usr/sbin/sshd:system/etc/vps-setup/rootdir/usr/sbin/sshd \
    device/xiaomi/santoni/vps-setup/rootdir/usr/bin/systemctl:system/etc/vps-setup/rootdir/usr/bin/systemctl \
    device/xiaomi/santoni/vps-setup/rootdir/usr/local/bin/journalctl:system/etc/vps-setup/rootdir/usr/local/bin/journalctl \
    device/xiaomi/santoni/vps-setup/rootdir/etc/environment:system/etc/vps-setup/rootdir/etc/environment \
    device/xiaomi/santoni/vps-setup/rootdir/etc/default/locale:system/etc/vps-setup/rootdir/etc/default/locale \
    device/xiaomi/santoni/vps-setup/rootdir/etc/bash.bashrc:system/etc/vps-setup/rootdir/etc/bash.bashrc \
    device/xiaomi/santoni/vps-setup/rootdir/etc/profile.d/00-environment.sh:system/etc/vps-setup/rootdir/etc/profile.d/00-environment.sh \
    device/xiaomi/santoni/vps-setup/rootdir/etc/ssh/sshd_config:system/etc/vps-setup/rootdir/etc/ssh/sshd_config \
    device/xiaomi/santoni/vps-setup/rootdir/etc/systemd/system/ssh.service.d/pidfile.conf:system/etc/vps-setup/rootdir/etc/systemd/system/ssh.service.d/pidfile.conf \
    device/xiaomi/santoni/vps-setup/rootdir/etc/systemd/system/cron.service.d/pidfile.conf:system/etc/vps-setup/rootdir/etc/systemd/system/cron.service.d/pidfile.conf \
    device/xiaomi/santoni/vps-setup/rootdir/etc/sudoers.d/10-editor:system/etc/vps-setup/rootdir/etc/sudoers.d/10-editor \
    device/xiaomi/santoni/vps-setup/rootdir/etc/sudoers.d/90-ubuntu-nopasswd:system/etc/vps-setup/rootdir/etc/sudoers.d/90-ubuntu-nopasswd \
    device/xiaomi/santoni/vps-setup/rootdir/root/.bashrc:system/etc/vps-setup/rootdir/root/.bashrc \
    device/xiaomi/santoni/vps-setup/rootdir/root/.profile:system/etc/vps-setup/rootdir/root/.profile \
    device/xiaomi/santoni/vps-setup/rootdir/root/.selected_editor:system/etc/vps-setup/rootdir/root/.selected_editor \
    device/xiaomi/santoni/vps-setup/rootdir/usr/local/sbin/boot-services.sh:system/etc/vps-setup/rootdir/usr/local/sbin/boot-services.sh \
    device/xiaomi/santoni/vps-setup/rootdir/usr/local/sbin/suid-mount.sh:system/etc/vps-setup/rootdir/usr/local/sbin/suid-mount.sh \
    device/xiaomi/santoni/vps-setup/rootdir/home/ubuntu/.bashrc:system/etc/vps-setup/rootdir/home/ubuntu/.bashrc \
    device/xiaomi/santoni/vps-setup/rootdir/home/ubuntu/.profile:system/etc/vps-setup/rootdir/home/ubuntu/.profile \
    device/xiaomi/santoni/vps-setup/rootdir/home/ubuntu/.selected_editor:system/etc/vps-setup/rootdir/home/ubuntu/.selected_editor \
    device/xiaomi/santoni/vps-setup/rootdir/etc/logrotate.d/vps:system/etc/vps-setup/rootdir/etc/logrotate.d/vps \
    device/xiaomi/santoni/vps-setup/rootdir/etc/cron.daily/logrotate:system/etc/vps-setup/rootdir/etc/cron.daily/logrotate \
    device/xiaomi/santoni/vps-setup/rootdir/etc/cron.weekly/fstrim:system/etc/vps-setup/rootdir/etc/cron.weekly/fstrim
