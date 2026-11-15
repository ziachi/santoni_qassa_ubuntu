# Source patches

The device tree cannot do everything on its own. These are the changes that
have to land in the synced source tree, applied once after `repo sync`.

## adb shell override

**Why:** AOSP hard-codes the device-side adb shell in
`system/core/adb/daemon/services.cpp`:

```c
#if ADB_HOST
#define SHELL_COMMAND "/bin/sh"
#else
#define SHELL_COMMAND "/system/bin/sh"
#endif
```

There is no property for it upstream. Without this patch
`persist.sys.adb.shell` is ignored and `adb shell` always lands in
`/system/bin/sh`, so the `ubuntu-enter` password gate never runs.

**Apply:**

```bash
cd ~/qassa
device/xiaomi/santoni/patches/apply-adb-shell-override.py .
```

The script is idempotent and prints `already patched` on a second run.

**What it changes:** the `#define SHELL_COMMAND "/system/bin/sh"` line becomes a
small function that reads `persist.sys.adb.shell` once and falls back to
`/system/bin/sh`, plus the `#include <sys/system_properties.h>` it needs.

**Manual fallback** if the script cannot find the expected line:

```c
// in system/core/adb/daemon/services.cpp, replacing the #define
static const char* adb_shell_command() {
    static char shell[PROP_VALUE_MAX] = {0};
    if (shell[0] == '\0') {
        if (__system_property_get("persist.sys.adb.shell", shell) <= 0) {
            strlcpy(shell, "/system/bin/sh", sizeof(shell));
        }
    }
    return shell;
}
#define SHELL_COMMAND adb_shell_command()
```

**Verify after building:**

```bash
adb shell getprop persist.sys.adb.shell   # /system/bin/ubuntu-enter
adb shell                                  # should prompt over Wi-Fi
```

> This patch is not upstream. Re-apply it after every `repo sync` that touches
> `system/core`.
