LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE       := vps-setup
LOCAL_MODULE_TAGS  := optional
LOCAL_MODULE_CLASS := EXECUTABLES
LOCAL_SRC_FILES    := vps-setup.sh
LOCAL_MODULE_PATH  := $(TARGET_OUT)/bin
include $(BUILD_PREBUILT)
