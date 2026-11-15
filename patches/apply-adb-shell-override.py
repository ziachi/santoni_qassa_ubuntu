#!/usr/bin/env python3
"""Let adbd take its shell from persist.sys.adb.shell.

AOSP hard-codes the device-side shell in system/core/adb/daemon/services.cpp:

    #if ADB_HOST
    #define SHELL_COMMAND "/bin/sh"
    #else
    #define SHELL_COMMAND "/system/bin/sh"
    #endif

The headless santoni build needs that to be /system/bin/ubuntu-enter so the
Wi-Fi password gate runs before anyone gets a shell. This script rewrites the
define to read a persistent property, falling back to /system/bin/sh.

Usage:
    patches/apply-adb-shell-override.py [SOURCE_ROOT]

SOURCE_ROOT defaults to the current directory and must contain
system/core/adb/daemon/services.cpp. The script is idempotent: running it twice
is a no-op.
"""

import os
import sys

MARKER = "adb_shell_command"

OLD_DEFINE = '#define SHELL_COMMAND "/system/bin/sh"'

NEW_BLOCK = """// Allow the shell to be redirected with a persistent property so a device can
// install a login wrapper (device/xiaomi/santoni/ubuntu-enter).
static const char* adb_shell_command() {
    static char shell[PROP_VALUE_MAX] = {0};
    if (shell[0] == '\\0') {
        if (__system_property_get("persist.sys.adb.shell", shell) <= 0) {
            strlcpy(shell, "/system/bin/sh", sizeof(shell));
        }
    }
    return shell;
}
#define SHELL_COMMAND adb_shell_command()"""

INCLUDE = "#include <sys/system_properties.h>"


def main():
    root = sys.argv[1] if len(sys.argv) > 1 else os.getcwd()
    path = os.path.join(root, "system", "core", "adb", "daemon", "services.cpp")

    if not os.path.isfile(path):
        sys.exit("error: not found: %s\n"
                 "Run this from the root of the synced source tree." % path)

    with open(path, "r", encoding="utf-8") as fh:
        text = fh.read()

    if MARKER in text:
        print("already patched: %s" % path)
        return 0

    if OLD_DEFINE not in text:
        sys.exit("error: could not find %r in %s\n"
                 "The adb sources differ from the expected AOSP layout; apply "
                 "the change by hand (see patches/README.md)."
                 % (OLD_DEFINE, path))

    text = text.replace(OLD_DEFINE, NEW_BLOCK, 1)

    if INCLUDE not in text:
        anchor = "#include <string.h>"
        if anchor in text:
            text = text.replace(anchor, anchor + "\n" + INCLUDE, 1)
        else:
            anchor = "#include <unistd.h>"
            if anchor not in text:
                sys.exit("error: no include anchor found in %s" % path)
            text = text.replace(anchor, INCLUDE + "\n" + anchor, 1)

    with open(path, "w", encoding="utf-8") as fh:
        fh.write(text)

    print("patched: %s" % path)
    print("adbd now reads persist.sys.adb.shell (default /system/bin/sh)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
