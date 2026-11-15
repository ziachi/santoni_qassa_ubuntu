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
| 29 | v21 | - | [v21] santoni: ADB over USB without signature + Wi-Fi 5555 (#29) |

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
