# CHANGELOG — device_xiaomi_santoni_qassa

## Commits

| # | Version | Hash | Change |
|---|---------|------|--------|
| 1 | - | db62dda | santoni: Update defconfig |
| 2 | - | e187228 | Fix dex2oat duplicate compiler filter crash |
| 3 | - | cbca51a | Add custom releasetools with credit injection |
| 4 | - | 172d3f8 | Add ziachi maintainer customizations |
| 5 | - | 392348c | Adapt session rules: add CHANGELOG.md + update README |
| 6 | - | 1a9ad2c | santoni: Revamp README.md to match Matrixx quality |
| 7 | - | 03332ae | Fix allocator@3.0 bootloop + update docs (#6) |
| 8 | - | 34e7353 | Fix credits description (#7) |
| 9 | - | 4032e6f | Fix privapp-permissions bootloop (#8) |
| 10 | - | d3098f2 | Add bug analysis docs + update README (#9) |
| 11 | - | 0a1ca39 | Fix 6 bugs from V14 logcat analysis (#10-#15) |
| 12 | v15 | 60526f3 | SEPolicy cleanup — remove non-existent types (#16) |
| 13 | v15 | aa0fc5d | Remove Dolby from device tree (#17) |
| 14 | v15 | ac19f79 | Add Spectrum kernel manager + OverrideSettings SEPolicy (#18) |
| 15 | v15 | ae7f47a | Build deps fix + device info overlay (#19) |
| 16 | v15 | fc1ceaa | Update README + CHANGELOG (#20) |
| 17 | v15 | df886c1 | Fix README — separate device tree vs override bugs (#21) |
| 18 | v16 | 32160a3 | Remove Android Override integration (#22) |
| 19 | v16 | 3f69e6d | Update README — comprehensive setup guide (#23) |
| 20 | v17 | cfbf6ba | Complete Dolby removal from device tree (#20) |
| 21 | v18 | c687798 | Fix PinnerService APEX path for Android 10 (#21) |
| 22 | v19 | 727c886 | Fix PinnerService path for flattened APEX (#22) |
| 23 | v20 | 2e0ceda | Add Spectrum kernel profile to XiaomiAddon (#23) |
| 24 | v20 | d14747c | Update README + CHANGELOG for release (#24) |
| 25 | v20 | 28593f0 | Remove incorrect credit from README (#25) |
| 26 | v21 | 8f96ca1 | [v21] santoni: Use prebuilt Luuvy kernel (#26) |
| 27 | v21 | e5f8c85 | [v21] santoni: Verify kernel config for chroot VPS (#27) |
| 28 | v21 | 4d8f288 | [v21] santoni: Headless mode + SELinux permissive (#28) |
| 29 | v21 | 0acc93c | [v21] santoni: ADB over USB without signature + Wi-Fi 5555 (#29) |
| 30 | v21 | 9d13e81 | [v21] santoni: Dual-auth login shell ubuntu-enter (#30) |
| 31 | v21 | 552ab0c | [v21] santoni: vps-setup first-run installer (#31) |
| 32 | v21 | - | [v21] santoni: Auto-start Ubuntu, wake lock, ZRAM 2 GB (#32) |

## Releases

| Version | Date | Build | Notes |
|---------|------|-------|-------|
| v20 | 2026-06-19 | qassa_Sisu-v2.4_0.s-UNOFFICIAL-santoni-20260619-0327-Vanilla-signed.zip | Clean build: Override removed, Dolby removed, PinnerService fixed, Spectrum added |

## Headless VPS Migration (v21)

The ROM is being repurposed from a daily-driver phone build into a headless
Ubuntu 22.04 LTS (arm64) VPS server. Each task below is one commit.

### #26 — Use prebuilt Luuvy kernel

**Problem**
The build required a full `kernel/xiaomi/msm8937` checkout, which is a separate
multi-GB repo and a long compile. The target kernel is already published as a
ready-made AnyKernel3 zip.

**Trial-Error**
- `curl` on the release asset URL returned a 9-byte `Not Found` body. The
  `ziachi/v0backup` repo is private, so the anonymous download URL does not
  work. Fixed by downloading through the authenticated CLI:
  `gh release download v1.4.5 --repo ziachi/v0backup --pattern 'Luuvy-*.zip'`.
- `gzip -t Image.gz-dtb` reports `trailing garbage ignored`. That is expected:
  the file is a gzip kernel payload with the device tree blob appended, which
  is exactly what `BOARD_KERNEL_IMAGE_NAME := Image.gz-dtb` expects.

**Fix**
- Added `prebuilts/kernel/Image.gz-dtb` (Luuvy C.4.0.eol202601, Linux 4.9.228
  arm64, sha256 `0aefe162…e86b9`) plus a `kernel.config` snapshot and a
  provenance README.
- `BoardConfig.mk` now sets `TARGET_PREBUILT_KERNEL` by default. Setting
  `SANTONI_BUILD_KERNEL=1` restores the from-source kernel build.
- A `$(warning)` fires at config time if the prebuilt image is missing, so the
  failure is obvious instead of surfacing as a missing boot image.

**Files**
`BoardConfig.mk`, `prebuilts/kernel/Image.gz-dtb`, `prebuilts/kernel/kernel.config`,
`prebuilts/kernel/README.md`, `CHANGELOG.md`, `README.md`

**Impact**
`kernel/xiaomi/msm8937` is no longer required to build the ROM. The boot image
is byte-identical to the published Luuvy kernel.

### #27 — Verify kernel config for the chroot VPS

**Problem**
The Ubuntu VPS runs as a `chroot` inside Android, so the kernel must expose
the namespace, IPC, cgroup and filesystem features that userspace expects.
Nothing verified that the prebuilt Luuvy kernel actually has them.

**Trial-Error**
- `extract-ikconfig` from the kernel tree needs a source checkout, which we
  deliberately no longer have. Replaced with a self-contained `python3`
  extractor that scans the decompressed `Image` for the `IKCFG_ST` marker and
  gunzips the blob that follows it. Works on `Image.gz-dtb` directly.
- The `IKCFG_ED` end marker is not present in this image, so the extractor
  falls back to "everything after the gzip stream" and trims to the last
  `CONFIG_` line. Result: 4969 lines, `Linux/arm64 4.9.228`.
- First run of the checker reported 3 required options missing. Verified by
  hand against `kernel.config` — the report is correct, not a parser bug.

**Result — 46/49 required options present**

Present and important: `CONFIG_NAMESPACES`, `CONFIG_NET_NS`, `CONFIG_CGROUPS`,
`CONFIG_CGROUP_FREEZER`, `CONFIG_CPUSETS`, `CONFIG_OVERLAY_FS`, `CONFIG_FUSE_FS`,
`CONFIG_TUN`, `CONFIG_BRIDGE`, `CONFIG_NETFILTER`, `CONFIG_NF_CONNTRACK`,
`CONFIG_IP_NF_NAT`, `CONFIG_IP_NF_TARGET_MASQUERADE`, `CONFIG_EXT4_FS`,
`CONFIG_TMPFS`, `CONFIG_ZRAM`, `CONFIG_SWAP`, `CONFIG_SECCOMP`, `CONFIG_KEYS`,
`CONFIG_IKCONFIG_PROC` (so `/proc/config.gz` works on device),
`CONFIG_MODULES`, `CONFIG_DM_CRYPT`, `CONFIG_BLK_DEV_LOOP`,
`CONFIG_ANDROID_BINDER_IPC`, `CONFIG_ASHMEM`, `CONFIG_ION`, `CONFIG_SDCARD_FS`,
`CONFIG_SECURITY_SELINUX`, `CONFIG_USB_CONFIGFS`, `CONFIG_ARM64_4K_PAGES`.

Missing, required:

| Option | Consequence |
|---|---|
| `CONFIG_SYSVIPC` | No SysV IPC. PostgreSQL, Redis and several daemons refuse to start. |
| `CONFIG_POSIX_MQUEUE` | No POSIX message queues. |
| `CONFIG_DEVTMPFS` | `/dev` cannot be auto-populated; the chroot must bind-mount Android's `/dev`. |

Missing, optional (container-only): `CONFIG_PID_NS`, `CONFIG_UTS_NS`,
`CONFIG_IPC_NS`, `CONFIG_USER_NS`, `CONFIG_MEMCG`, `CONFIG_VETH`,
`CONFIG_SQUASHFS`, `CONFIG_BINFMT_MISC`, `CONFIG_DEVPTS_MULTIPLE_INSTANCES`.

**Fix**
- `tools/verify-ikconfig.sh` (landed with #26) reads the config straight out of
  a kernel image or a `.config`, checks 49 required and 9 optional options,
  prints a table and exits non-zero when a required option is missing.
- Recorded the full result here and in `README.md`.

**Files**
`tools/verify-ikconfig.sh`, `CHANGELOG.md`, `README.md`

**Impact**
- Plain `chroot` into Ubuntu 22.04 works: namespaces for networking, cgroups,
  overlayfs, tmpfs, ZRAM swap and SELinux are all available.
- **Container runtimes (Docker/LXC/podman) will not work** on this kernel —
  no PID/UTS/IPC/user namespaces and no veth.
- **SysV-IPC services will not work** — PostgreSQL and Redis need
  `CONFIG_SYSVIPC`. Use SQLite, or rebuild the kernel with the three missing
  required options if those services are needed.
- The chroot must bind-mount Android's `/dev` because `CONFIG_DEVTMPFS` is off.

### #28 — Headless mode + SELinux permissive

**Problem**
The ROM boots a full Android UI that nobody can reach: the device is a VPS
driven over ADB. The UI costs RAM, boot time and a display server, and SELinux
enforcing blocks the Ubuntu chroot from doing its job.

**Trial-Error**
- `BOARD_KERNEL_CMDLINE` had a latent bug: the `ifeq ($(TARGET_KERNEL_VERSION), 4.9)`
  block used `:=` (overwrite) instead of `+=`, and `TARGET_KERNEL_VERSION` was
  only defined ~10 lines *below* it. The block therefore never fired, and if it
  ever had, it would have wiped the entire cmdline down to
  `androidboot.usbconfigfs=true`. Fixed by moving `TARGET_KERNEL_VERSION := 4.9`
  above the block and switching to `+=`.
- `device.mk` listed `GCam` in `PRODUCT_PACKAGES` while `GCam/Android.mk` is a
  prebuilt that needs `GCam/Camera.apk`. Removing the package entry also removes
  a build-time dependency on that APK.
- A plain `PRODUCT_PACKAGES -= SystemUI` does not work in product config, and
  `filter-out` alone misses packages added by later inherits. Used both:
  `filter-out` in `qassa_santoni.mk` (after the inherits) plus the existing
  `RemovePackages` module's `LOCAL_OVERRIDES_PACKAGES` as the safety net.
- `service surfaceflinger` cannot simply be re-declared — init rejects duplicate
  service names. Used the init `override` keyword, which is supported from
  Android 9 and replaces the AOSP definition.

**Fix**
- `BOARD_KERNEL_CMDLINE += androidboot.selinux=permissive`.
- Dropped `SystemUI`, `Launcher3`, `Launcher3QuickStep`, `GCam`, `XiaomiAddon`
  from the product.
- `surfaceflinger` and `bootanim` redefined as `disabled` in `init.target.rc`.
- README Hard Rule #2 rewritten: permissive is now the policy for this build.

**Files**
`BoardConfig.mk`, `device.mk`, `qassa_santoni.mk`, `prebuilts/Android.mk`,
`rootdir/init.target.rc`, `CHANGELOG.md`, `README.md`

**Impact**
- SELinux runs permissive; the chroot is no longer blocked by denials.
- No launcher, no status bar, no boot animation, no camera app, no XiaomiAddon.
- **Needs boot verification.** Disabling SurfaceFlinger is the risky part:
  `system_server` may fail to acquire a display and crash-loop. If it does,
  remove the `surfaceflinger` override and keep only `bootanim` disabled.

### #29 — ADB over USB without signature + ADB over Wi-Fi on 5555

**Problem**
With the UI gone there is no screen to tap "Allow USB debugging" on, so the
RSA authorisation prompt makes the device unreachable. ADB also has to be
reachable over Wi-Fi, because the whole point is a headless box on a shelf.

**Trial-Error**
- `persist.sys.usb.config=mtp,adb` keeps MTP in the gadget composition. MTP
  needs a UI to be useful and it delays adbd coming up. Switched to `adb` only.
- `ro.secure`, `ro.debuggable` and `ro.adb.secure` are already set by the
  build variant (`userdebug` gives `0 / 1 / 0`). They are pinned in
  `PRODUCT_PROPERTY_OVERRIDES` anyway so a `user` variant build behaves the
  same. This is safe: the values land in `/system/build.prop`, which is read
  after `default.prop`, and there is no duplicate key inside the override list
  itself (a duplicate there is a hard build error).
- `service.adb.tcp.port` is read by adbd at start, so it must be a build prop
  and not something set later by a script.

**Fix**

```makefile
PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.usb.config=adb \
    persist.service.adb.enable=1 \
    ro.adb.secure=0 \
    ro.secure=0 \
    ro.debuggable=1 \
    service.adb.tcp.port=5555
```

**Files**
`qassa_santoni.mk`, `CHANGELOG.md`, `README.md`

**Impact**
- Plugging in USB gives an authorised `adb shell` immediately, no on-screen
  confirmation.
- adbd also listens on TCP 5555 from boot, so `adb connect <ip>:5555` works
  once Wi-Fi is up.
- No MTP: the device no longer shows up as a file-transfer device.
- **Security:** anyone on the same network who can reach port 5555 gets a root
  shell. The password gate in #30 is what protects it.

### #30 — Dual-auth login shell `ubuntu-enter`

**Problem**
`ro.adb.secure=0` plus `service.adb.tcp.port=5555` means anyone who can reach
port 5555 gets a root shell. USB is physically trusted; Wi-Fi is not. The two
paths need different treatment, and the session should land in Ubuntu, not in
Android's shell.

**Trial-Error**
- `read -s` does **not** hide input in mksh. In mksh `-s` means "save the line
  in the history file". The prompt has to use `stty -echo` / `stty echo`
  around a plain `read -r`.
- AOSP hard-codes the device-side adb shell in
  `system/core/adb/daemon/services.cpp` (`#define SHELL_COMMAND "/system/bin/sh"`).
  There is no upstream property for it, so `persist.sys.adb.shell` alone does
  nothing. Added `patches/apply-adb-shell-override.py`, an idempotent script
  that rewrites the define to read the property. This is the one change that
  cannot live in the device tree.
- adbd runs `<shell> -c <command>` for `adb shell <command>`. Without handling
  `-c` the wrapper would swallow the command and drop into an interactive
  session. The script authenticates first, then `exec`s
  `/system/bin/sh -c "$*"`, so `echo 'santoniadmin' | adb shell getprop` still
  works and is still gated.
- `/sys/class/android_usb/android0/state` is the reliable USB signal; it reads
  `CONFIGURED` only when a host is actually attached. `sys.usb.state` is the
  fallback when the sysfs node is missing.

**Fix**
- `ubuntu-enter/ubuntu-enter.sh` installed to `/system/bin/ubuntu-enter`:
  - USB `CONFIGURED` → straight in, no password.
  - Otherwise → `ADB Wi-Fi Password:` prompt, 3 tries, then `exit 1`.
  - Password read from `/data/adb_wifi_pass`, default `santoniadmin`.
  - On success: bind-mount `/dev`, `/dev/pts`, `/proc`, `/sys` into
    `/data/ubuntu` and `exec chroot /data/ubuntu /bin/bash -l`. If
    `/data/ubuntu/bin/bash` is missing, drop to `/system/bin/sh` with a hint to
    run `vps-setup`.
- `persist.sys.adb.shell=/system/bin/ubuntu-enter` in
  `PRODUCT_PROPERTY_OVERRIDES`.
- `patches/README.md` documents the adb patch and the manual fallback.

**Files**
`ubuntu-enter/ubuntu-enter.sh`, `ubuntu-enter/Android.mk`,
`patches/apply-adb-shell-override.py`, `patches/README.md`,
`qassa_santoni.mk`, `CHANGELOG.md`, `README.md`

**Impact**
- Interactive `adb shell` over Wi-Fi requires the password; over USB it does
  not.
- The session lands in Ubuntu 22.04 as root once it is installed.
- **Requires the adb patch.** Without it `persist.sys.adb.shell` is ignored and
  `adb shell` goes straight to `/system/bin/sh` — the gate never runs.
- The gate covers `adb shell <command>` too, so scripted access over Wi-Fi
  needs `echo '<password>' | adb shell <command>`.

### #31 — `vps-setup` first-run installer

**Problem**
A freshly flashed device has no Wi-Fi, no Ubuntu and no way to get either
without a screen. The first setup has to be a single command over USB.

**Trial-Error**
- Android 10 has no `curl`. Toybox `wget` is not guaranteed to be enabled
  either. The script probes `curl`, then `wget`, then `toybox wget`, and if all
  three are missing it prints the exact `adb push` recipe for the host instead
  of failing silently.
- `cmd wifi connect-network` needs the security type as a positional argument
  in Android 10: `connect-network <ssid> wpa2 <passphrase>`. Passing only the
  passphrase fails.
- `svc wifi enable` returns before `wpa_supplicant` is up, so the connect call
  races it. The script polls `init.svc.wpa_supplicant` for up to 20s first.
- `ip -4 addr show wlan0` is not always present; `getprop dhcp.wlan0.ipaddress`
  is the fallback for reading the address.
- The 22.04 release tarball name is `ubuntu-base-22.04-base-arm64.tar.gz`, but
  point releases live under `22.04.5/release/`. Both URLs are tried.

**Fix**
`vps-setup/vps-setup.sh` installed to `/system/bin/vps-setup`:

1. `svc wifi enable`, wait for `wpa_supplicant`, then
   `cmd wifi connect-network <SSID> wpa2 <PASSWORD>`.
2. Poll for an IPv4 address on `wlan0` (30s).
3. Download the Ubuntu 22.04 arm64 base rootfs to
   `/data/local/tmp/ubuntu-base.tar.gz`.
4. `tar -xzf` into `/data/ubuntu`, create `dev`, `dev/pts`, `proc`, `sys`,
   `tmp`, `run`.
5. Write `/etc/resolv.conf` (8.8.8.8, 1.1.1.1) and, when missing, an
   `apt` `sources.list` for `ports.ubuntu.com` — without it `apt update` fails
   and the VPS is unusable.

**Files**
`vps-setup/vps-setup.sh`, `vps-setup/Android.mk`, `qassa_santoni.mk`,
`CHANGELOG.md`, `README.md`

**Impact**
`adb shell vps-setup <SSID> <PASSWORD>` over USB takes a blank device to a
bootable Ubuntu 22.04 chroot. Re-running it re-extracts the rootfs over the
existing one.

### #32 — Auto-start Ubuntu, wake lock, ZRAM 2 GB

**Problem**
The chroot only came up when someone ran `ubuntu-enter`. A VPS has to come up
on its own after a power cut, stay awake, and have enough swap for a 3 GB
device running a full userspace.

**Trial-Error**
- `fstab.qcom` already declares zram0 as swap with `zramsize=1073741824`, and
  `init.target.rc` runs `swapon_all` on it. Re-configuring zram0 from a boot
  script without `swapoff` first fails, because the device is busy. The script
  therefore does `swapoff` → `reset` → `disksize` → `mkswap` → `swapon`, and
  only when the running size differs from 2 GB.
- The right place for the size is the fstab, not the script: `swapon_all` runs
  long before `sys.boot_completed`. Both are changed — the fstab sets 2 GB at
  boot, the script is the safety net for a device that booted with the old
  fstab.
- `sys.boot_completed=1` is the only safe trigger: before that `/data` may not
  be decrypted, so `/data/ubuntu` would not exist yet.
- `service ssh start` needs `/proc` and `/run` inside the chroot, so the bind
  mounts have to happen first. `/run` was missing from the original list.

**Fix**
- `rootdir/fstab.qcom`: `zramsize=2147483648` (2 GB).
- `rootdir/init.ubuntu.sh` installed to `/vendor/bin/init.ubuntu.sh`:
  - `echo vps_server_lock > /sys/power/wake_lock` — no deep sleep.
  - zram0 check/resize to 2147483648 bytes, `mkswap` + `swapon`.
  - bind-mount `/dev`, `/dev/pts`, `/proc`, `/sys`, `/run` into `/data/ubuntu`.
  - `chroot /data/ubuntu /usr/sbin/service ssh start`, with a clear log line
    when `openssh-server` is not installed.
- `rootdir/init.ubuntu.rc` defines `service vps-boot` (`oneshot`, `disabled`)
  and starts it `on property:sys.boot_completed=1`. Imported from
  `init.qcom.rc`.

**Files**
`rootdir/init.ubuntu.sh`, `rootdir/init.ubuntu.rc`, `rootdir/Android.mk`,
`rootdir/init.qcom.rc`, `rootdir/fstab.qcom`, `CHANGELOG.md`, `README.md`

**Impact**
- Ubuntu comes up by itself after every boot, with sshd running if installed.
- The device never suspends, so it stays reachable.
- Swap grows from 1 GB to 2 GB, which matters on a 3 GB device.
- Everything is logged under the `vps-boot:` tag in logcat.

## Key Changes by Version

### v20
- **Spectrum kernel profiles** added to XiaomiAddon (QS tile + Settings dropdown)
- Profiles: Balance, Performance, Battery, Gaming
- README cleanup

### v19
- **PinnerService fix** for flattened APEX — correct path `/system/apex/com.android.runtime.release/javalib/`

### v17–v18
- **Complete Dolby removal** — all references purged from device tree + vendor
- **PinnerService** initial APEX path fix

### v16
- **Android Override removed** — cleaned from device tree, frameworks, vendor
- OverrideSettings app deleted, SEPolicy cleaned

### v15
- SEPolicy cleanup, Dolby initial removal, build deps fix
- 6 bug fixes from V14 logcat analysis
