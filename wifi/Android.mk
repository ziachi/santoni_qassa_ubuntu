LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE       := wifi
LOCAL_MODULE_TAGS  := optional
LOCAL_MODULE_CLASS := EXECUTABLES
LOCAL_SRC_FILES    := wifi.sh
LOCAL_MODULE_PATH  := $(TARGET_OUT)/bin
# An EXECUTABLES prebuilt is installed with `chmod +x` on the source mode, and a
# checkout under umask 002 leaves the source at 0664, which installs as 0775.
# Pin the mode so the image does not depend on the umask of whoever built it.
# Recursive `=`, not `:=`: LOCAL_INSTALLED_MODULE is only defined later, in
# base_rules.mk, and a simple assignment would expand to nothing here.
LOCAL_POST_INSTALL_CMD = chmod 0755 $(LOCAL_INSTALLED_MODULE)
include $(BUILD_PREBUILT)

# udhcpc runs this on every lease change. It lives next to the CLI because the
# two are one mechanism: `wifi` starts the daemon, the hook applies the lease.
include $(CLEAR_VARS)
LOCAL_MODULE       := udhcpc.script
LOCAL_MODULE_TAGS  := optional
LOCAL_MODULE_CLASS := EXECUTABLES
LOCAL_SRC_FILES    := udhcpc.script
LOCAL_MODULE_PATH  := $(TARGET_OUT)/bin
LOCAL_POST_INSTALL_CMD = chmod 0755 $(LOCAL_INSTALLED_MODULE)
include $(BUILD_PREBUILT)
