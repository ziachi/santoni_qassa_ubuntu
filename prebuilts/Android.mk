#
# Copyright 2020 The Android Open Source Project
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

LOCAL_PATH := $(call my-dir)

# Every APK that only exists to draw something for a human. The device is a
# headless VPS: Zygote is stopped at boot, so none of these ever run, and
# leaving them in the image only costs space.
#
# The stub has to be installed for the override to apply, so it is listed in
# PRODUCT_PACKAGES in qassa_santoni.mk. Keep the two lists in sync.
#
# Deliberately absent: framework-res, telephony-common, WcnssService, the
# providers (SettingsProvider, MediaProvider, TelephonyProvider, ...), the
# telephony/modem stack (TeleService, Telecom, ims, qcrilmsgtunnel, Stk,
# MmsService, CellBroadcastReceiver) and the network services (InProcessNetworkStack,
# SoftAPManager, WfdService, OsuLogin, PlatformCaptivePortalLogin).
include $(CLEAR_VARS)
LOCAL_MODULE := RemovePackages
LOCAL_MODULE_CLASS := APPS
LOCAL_MODULE_TAGS := optional
LOCAL_OVERRIDES_PACKAGES := \
    Aperture \
    AudioFX \
    Calendar \
    Contacts \
    DeskClock \
    Dialer \
    DocumentsUI \
    DownloadProviderUi \
    EasterEgg \
    EmergencyInfo \
    ExactCalculator \
    FMRadio \
    Gallery2 \
    GamingMode \
    GCam \
    Launcher3 \
    Launcher3QuickStep \
    LatinIME \
    LiveWallpapersPicker \
    MatLog \
    messaging \
    MusicFX \
    OneTimeInitializer \
    PowerOffAlarm \
    Provision \
    Settings \
    SettingsIntelligence \
    ShadyQuickStep \
    SoundPickerPrebuilt \
    StorageManager \
    SystemUI \
    VpnDialogs \
    WallpaperBackup \
    WallpaperCropper \
    WallpaperPicker2 \
    XiaomiAddon \
    XiaomiParts
LOCAL_UNINSTALLABLE_MODULE := true
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_SRC_FILES := /dev/null
include $(BUILD_PREBUILT)
