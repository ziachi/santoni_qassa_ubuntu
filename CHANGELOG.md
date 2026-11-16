# CHANGELOG — santoni_qassa_ubuntu

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
| 32 | v21 | 7beb938 | [v21] santoni: Auto-start Ubuntu, wake lock, ZRAM 2 GB (#32) |
| 33 | v21 | c2a13e3 | [v21] santoni: Operational guide — quick start, password, troubleshooting (#33) |
| 34 | v21 | 79bf7e9 | [v21] santoni: Point docs at the working repo (#34) |
| 35 | v21 | cdc76d5 | [v21] santoni: Create /data/adb_wifi_pass on first boot (#35) |
| 36 | v22 | 37e5a28 | [v22] santoni: restore surfaceflinger and verify minimal headless packages (#36) |
| 37 | v22 | 01bf948 | [v22] santoni: rbind /dev into the chroot, install sshd, open debug access (#37) |
| 38 | v22 | b77a14f | [v22] santoni: webcam-bridge skeleton — Camera2 NDK to MJPEG (#38) |
| 39 | v22 | e20515e | [v22] santoni: audio-bridge skeleton — PulseAudio over OpenSL ES (#39) |
| 40 | v22 | de32ed6 | [v22] santoni: sensor-bridge skeleton — ASensorManager to /data/ubuntu/tmp (#40) |
| 41 | v22 | e4e1218 | [v22] santoni: Re-enable the ADB over Wi-Fi password gate (#41) |
| 42 | v22 | - | [v22] santoni: Fix 5 documentation bugs and script step labels (#42) |
| 43 | v22 | - | [v22] santoni: Add qassa-ubuntu branches + kernel headers requirement (#43) |
| 44 | v22 | - | [v22] santoni: Wire init.ubuntu.sh + init.ubuntu.rc into the build (#44) |
| 45 | v22 | - | [v22] santoni: Enable webcam/audio/sensor bridges (#45) |
| 46 | v22 | - | [v22] santoni: Install init.ubuntu.sh to system/bin 0755 and its rc to system/etc/init (#46) |
| 47 | v22 | - | [v22] santoni: Fix const ASensor* in sensor_bridge (#47) |
| 48 | v22 | - | [v22] santoni: Backport cmd wifi connect-network for Android 10 (#48) |
| 49 | v22 | - | [v22] santoni: In-tree curl, 60-column output (#49) |
| 50 | v22 | - | [v22] santoni: wifi helper and scan backport (#50) |
| 51 | v22 | - | [v22] santoni: set and print both passwords (#51) |
| 52 | v22 | - | [v22] santoni: fix apt-get PATH inside the chroot (#52) |

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

### #33 — Operational guide: quick start, password, troubleshooting

**Problem**
The pieces were documented one at a time, in the order they were built. Someone
holding a freshly flashed device had to read five sections and work out the
order themselves, and the two things that actually go wrong on first boot —
a wrong Wi-Fi password and a missing `openssh-server` — were not written down
anywhere.

**Trial-Error**
- The password section only showed how to *set* the file. It did not say that
  `ubuntu-enter` re-reads `/data/adb_wifi_pass` on every session, so a reboot
  is not needed, and it did not say how to recover a forgotten password.
  Deleting the file restores the `santoniadmin` default, which is the only
  recovery path that does not need the password.
- `ssh root@<ip>` fails on a stock `ubuntu-base` rootfs because root has no
  password and `sshd` refuses an empty one. `passwd root` has to be part of the
  documented flow, not an afterthought.
- The `adb connect` example used a hardcoded IP with no way to find it. The
  address is printed by `vps-setup`, and `ip -4 addr show wlan0` is the
  fallback.
- santoni has no 5 GHz radio, so a 5 GHz-only SSID fails at the connect step
  with a generic "no IP" message. That is now the first troubleshooting row.

**Fix**
`README.md` gained three sections under Headless VPS Mode:

- **Quick start** — the five commands from `adb devices` to `ssh root@<ip>`,
  with a note on which steps need the cable.
- **Changing the ADB Wi-Fi password** — set, verify (new value accepted, old
  value rejected), and recover a forgotten one by deleting the file.
- **Troubleshooting** — a symptom/cause/fix table covering the Wi-Fi join, the
  missing downloader, `adb connect` refused, an unknown Wi-Fi password, a
  missing Ubuntu, a missing `openssh-server`, a failed bind mount, and the
  `system_server` crash-loop from the SurfaceFlinger override.

**Files**
`README.md`, `CHANGELOG.md`

**Impact**
Documentation only — no build output changes. Tahap 2 is complete; the next
step is `gas build`.

### #34 — Point docs at the working repo

**Problem**
The device tree moved from `ziachi/device_xiaomi_santoni_qassa` — the upstream
reference, kept pristine at `6be065b` — to `ziachi/santoni_qassa_ubuntu`. The
README still told a fresh VPS to clone the reference repo on branch `qassa-dev`,
so a new build would have pulled the unmodified upstream tree with none of the
v21 headless work.

**Trial-Error**
- `grep -rn device_xiaomi_santoni_qassa` found three stale references: the
  Repository Map table, the Step 2 clone command, and the CHANGELOG title.
- The reference repo is public and read-only by policy. Committing there was a
  mistake made earlier in the session; it has been reverted and the eight v21
  commits were moved here with their signatures intact.

**Fix**
- Repository Map: device tree now points at `santoni_qassa_ubuntu`, branch `main`.
- Step 2: `git clone .../santoni_qassa_ubuntu.git device/xiaomi/santoni -b main`.
- CHANGELOG title renamed to match the working repo.

**Files**
`README.md`, `CHANGELOG.md`

**Impact**
Documentation only — no build output changes. A fresh checkout now gets the v21
headless tree instead of the pristine upstream one.

### #35 — Create `/data/adb_wifi_pass` on first boot

**Problem**
`ubuntu-enter` reads the ADB-over-Wi-Fi password from `/data/adb_wifi_pass` and
falls back to `santoniadmin` when the file is missing. Nothing ever created the
file, so on a fresh device the fallback was the only thing in play: the password
existed as a string inside a shell script, not as a `0600 root:root` file. Task 5
(`vps-setup`) and Task 6 (`init.ubuntu.sh`) both specified creating it; neither
did.

**Trial-Error**
- `grep -rn adb_wifi_pass` found the path only in `ubuntu-enter.sh` (a read with
  a fallback) and in the docs. There was no writer anywhere in the tree.
- The chroot section of `init.ubuntu.sh` exits early when `/data/ubuntu` is
  missing, so the password step has to sit *before* that check — otherwise a
  device that never ran `vps-setup` would never get the file.
- `chown root:root` is not reliable on Android: there is no `/etc/passwd` to
  resolve the names against. `chown 0:0` is the same ownership and always works.

**Fix**
- `vps-setup.sh` gained a sixth step: write `santoniadmin` to
  `/data/adb_wifi_pass` when the file is absent or empty, then `chmod 600` and
  `chown 0:0`. An existing file keeps its value.
- `init.ubuntu.sh` gained section 3, which does the same on every boot before
  the chroot check, so the file exists even on a device that never ran
  `vps-setup`. The chroot section is now section 4.
- Both scripts re-apply `0600 root:root` to an existing file, so a file left
  world-readable by an older flow is tightened on the next boot.

**Files**
`vps-setup/vps-setup.sh`, `rootdir/init.ubuntu.sh`, `README.md`, `CHANGELOG.md`

**Impact**
The default password is now a real `0600 root:root` file from the first boot
instead of an implicit fallback. No build output changes. The kernel stays
Luuvy C.4.0 — the chroot VPS does not need the container namespaces, so
`CONFIG_PID_NS` / `CONFIG_SYSVIPC` remain unset by design.

### #36 — Restore surfaceflinger, keep bootanim, document the package override

**Problem**
`init.target.rc` overrode both `surfaceflinger` and `bootanim` with `disabled`.
SurfaceFlinger is not optional on this platform: `system_server` binds to it
through the display/gralloc path, and the camera HAL allocates graphic buffers
through the same path. With the display server never started, the framework
retries the connection and the camera stack has no buffer allocator, which is a
bootloop risk rather than a RAM saving. The `bootanim` override had the same
shape but a different consequence: with the service disabled, init never gets
the `service.bootanim.exit` handshake.

Separately, the headless package trim in `qassa_santoni.mk` looked correct but
did nothing. `get_build_var PRODUCT_PACKAGES` still listed `SystemUI`,
`Launcher3`, `Launcher3QuickStep` and `XiaomiAddon`.

**Trial-Error**
- `grep -rn "service surfaceflinger\|service bootanim" --include="*.rc" .` in
  `device/xiaomi/santoni` found exactly one definition of each, both in
  `rootdir/init.target.rc`, both carrying `disabled` plus `override`. The same
  grep over `vendor/` returned nothing, so there is no second definition to
  fight with.
- `get_build_var PRODUCT_PACKAGES | tr ' ' '\n' | sort` returned 1027 entries
  including `Launcher3` (99), `Launcher3QuickStep` (100), `SystemUI` (418) and
  `XiaomiAddon` (439). `GCam` and `AudioFX` were already absent.
- The cause is `build/make/core/product.mk:378`. `inherit-product` is deferred
  in this tree: it appends a `$(INHERIT_TAG)<path>` marker to every product
  variable instead of including the makefile. When `qassa_santoni.mk` reached
  its `PRODUCT_PACKAGES := $(filter-out ...)`, the variable held only those
  markers, so the filter matched nothing and the assignment was a no-op.
- `grep -rn PRODUCT_PACKAGES_REMOVE build/make/` returned nothing. That
  variable does not exist in this tree, so it is not an option.
- `RemovePackages` *is* in `PRODUCT_PACKAGES` (entry 361), and
  `prebuilts/Android.mk` gives it
  `LOCAL_OVERRIDES_PACKAGES := AudioFX Launcher3 Launcher3QuickStep SystemUI GCam XiaomiAddon`.
  `build/make/core/main.mk:1110-1112` expands that into `_pif_overrides` and
  filters it out of `PRODUCTS.<mk>.PRODUCT_PACKAGES` before install. That is
  the mechanism that actually removes the APKs, which is why the image was
  already correct while the requested list was not.

**Fix**
- `rootdir/init.target.rc`: dropped `disabled` from the `surfaceflinger` and
  `bootanim` overrides. Both keep `override`, so they still replace the AOSP
  definitions, and both now start normally.
- `qassa_santoni.mk`: replaced the no-op `filter-out` with a comment that
  records why it cannot work and points at `RemovePackages` as the real
  mechanism, so the next person does not re-add it.
- `qassa_santoni.mk`: added `debug.sf.nobootanimation=1`. The boot animation is
  not drawn, but the service still runs and exits, so init gets its handshake
  and there is no boot stall.

**Files**
`rootdir/init.target.rc`, `qassa_santoni.mk`, `README.md`, `CHANGELOG.md`

**Impact**
SurfaceFlinger and the camera buffer path are back, removing the bootloop risk
that the `disabled` override introduced. The boot animation still does not
render, so the RAM cost is unchanged in practice. The UI APKs were already
being stripped by `RemovePackages`; the tree now documents that instead of
carrying dead code. No change to the HAL services: `vendor.sensors.qti`,
`vendor-sensor-sh`, `vendor.audio-hal-2-0`, `qcamerasvr`, `cameraserver`,
`audioserver`, `media` and `netd` were verified to have no `disabled` line.
`wpa_supplicant` does carry `disabled`, which is the upstream AOSP design —
`WifiService` starts it on demand.

### #37 — rbind /dev into the chroot, install sshd, open debug access

**Problem**
`init.ubuntu.sh` bind-mounted `/dev` with a plain `mount --bind`. ueventd keeps
creating device nodes after boot (`/dev/video*`, `/dev/snd/*`, `/dev/input/*`),
and a plain bind freezes the chroot's view at the moment of the mount, so the
camera, audio and sensor nodes the HAL bridges need were simply not there.
`/dev/pts` was then bind-mounted on top of that, which produced two devpts
instances and broke pty allocation. `sshd` also never started on a fresh
install: `vps-setup` did not install `openssh-server`, and `/run/sshd` did not
exist.

**Trial-Error**
- `mount --help` on this tree's toybox does not list `--rbind`; toybox takes the
  `-o rbind` / `-o rslave` forms, util-linux takes `--rbind` / `--make-rslave`.
  One hard-coded syntax cannot work on both, so the script probes once.
- Mounting devpts unconditionally after an rbind of `/dev` gave the chroot two
  devpts instances; `ssh` sessions then failed to allocate a pty.
- `service ssh start` exits non-zero when `/run/sshd` is missing, which is the
  state of a freshly unpacked rootfs.

**Fix**
- `rootdir/init.ubuntu.sh`: probe the mount syntax once (`long` / `short` /
  `busybox`) and route `rbind` and `make_rslave` through it.
- `rootdir/init.ubuntu.sh`: `rbind` `/dev` and `make-rslave` it, so nodes
  created after boot appear in the chroot and an unmount inside the chroot does
  not propagate back into Android's `/dev`.
- `rootdir/init.ubuntu.sh`: mount devpts only when the rbind did not already
  bring `/dev/pts` along, checked against `/proc/mounts`.
- `rootdir/init.ubuntu.sh`: mount `/proc` and `/sys`, create `/data/ubuntu/tmp`
  (1777) and `/data/ubuntu/run/sshd` (0755) before `service ssh start`.
- `vps-setup/vps-setup.sh`: new step 7 mounts `/dev`, `/proc` and `/sys`, writes
  a `resolv.conf`, runs `apt update && apt install -y openssh-server` inside the
  chroot, then tears the mounts down again.
- `ubuntu-enter/ubuntu-enter.sh`: `DEBUG_NO_PASSWORD=1` skips the Wi-Fi password
  gate on both the interactive path and the `-c` path.

**Files**
`rootdir/init.ubuntu.sh`, `vps-setup/vps-setup.sh`,
`ubuntu-enter/ubuntu-enter.sh`, `README.md`, `CHANGELOG.md`

**Impact**
The chroot now sees device nodes created after boot, so the camera, audio and
sensor bridges have something to open. `sshd` starts on the first boot after
`vps-setup` instead of needing a manual `apt install`. `DEBUG_NO_PASSWORD=1`
means a USB cable and ADB over Wi-Fi on 5555 both land in a root Ubuntu shell
with no prompt; together with `ro.adb.secure=0` and `ro.secure=0` that is a
debug-phase posture only, and `README.md` now says so. Set it back to `0` before
the device leaves the bench — the gate is intact and takes over immediately.

### #38 — webcam-bridge: Camera2 NDK to MJPEG, disabled

**Problem**
The chroot has no camera. `/dev/video0..3` on santoni are the legacy msm vidc
nodes used by the old camera daemon, not V4L2 capture devices, so
`ffmpeg -f v4l2` and `v4l2loopback` cannot open them and reading them yields
nothing useful. The only supported entry point is the Camera2 NDK, which talks
to `cameraserver` over binder.

**Trial-Error**
- Treating `/dev/video*` as UVC was the first assumption and it is wrong on this
  SoC. There is no V4L2 capture node to hand to the chroot.
- The NDK has no JPEG encoder, so `onImage()` can only log the `YUV_420_888`
  frame size. Encoding needs a prebuilt `libjpeg-turbo` or a baseline encoder
  written by hand; stubbing it out would have produced a bridge that silently
  emits nothing.
- `cameraserver` rejects clients that are not in the `camera` group. A root
  process started from the chroot gets `ACAMERA_ERROR_CAMERA_DISCONNECTED` with
  no useful message, which is a permission failure, not a camera failure.

**Fix**
- New `webcam-bridge/` with `webcam_bridge.cpp`: opens the first
  backward-compatible camera through `ACameraManager`, creates a capture
  session, and logs each `YUV_420_888` frame.
- `webcam-bridge/Android.bp.disabled`: `cc_binary` with `enabled: false`. Soong
  only reads files named `Android.bp`, so the directory is inert twice over.
- `webcam-bridge/README.md`: records the three missing pieces (JPEG encode, the
  repeating request, the MJPEG server on `127.0.0.1:8080`) and the UID caveat.

**Files**
`webcam-bridge/webcam_bridge.cpp`, `webcam-bridge/Android.bp.disabled`,
`webcam-bridge/README.md`, `README.md`, `CHANGELOG.md`

**Impact**
No build change: Soong never parses the directory. The skeleton compiles only
after the file is renamed to `Android.bp` and `enabled` is flipped, and it is
not a working stream until the three documented gaps are filled. The UID note
saves the next person from debugging a permission failure as a camera failure.

### #39 — audio-bridge: PulseAudio over OpenSL ES, config only

**Problem**
The chroot has no audio. `/dev/snd/*` is owned by `audio:audio` and the Android
audio HAL holds the PCM devices open, so a chroot process opening them directly
gets `EBUSY` or silence, and it bypasses the HAL's routing even when it works.

**Trial-Error**
- Bind-mounting `/dev/snd` into the chroot was the obvious shortcut and it does
  not work for the reason above.
- `module-sles-sink` and `module-sles-source` are not upstream PulseAudio
  modules. They have to be built or obtained separately, so a config that
  references them fails to load on a stock PulseAudio install.
- Nothing in this tree can fabricate the arm64 PulseAudio binary. Writing a
  placeholder would have produced a config that looks complete and is not.

**Fix**
- New `audio-bridge/pulse-default.pa`: unix socket at
  `/data/ubuntu/tmp/pulse.sock` so both sides reach it without a `/run` bind
  mount, plus `module-sles-sink` and `module-sles-source` for output and
  capture through OpenSL ES.
- `audio-bridge/Android.bp.disabled`: `prebuilt_etc` with `enabled: false`, so
  the config is not installed until the file is renamed.
- `audio-bridge/README.md`: states plainly that the binary and the OpenSL ES
  modules are not in the tree, and gives the command to check what is actually
  installed inside the chroot.

**Files**
`audio-bridge/pulse-default.pa`, `audio-bridge/Android.bp.disabled`,
`audio-bridge/README.md`, `README.md`, `CHANGELOG.md`

**Impact**
No build change: Soong never parses the directory. The config will fail to load
until the arm64 PulseAudio binary and the OpenSL ES modules exist in
`/data/ubuntu/usr/lib/pulse-*/modules/`. Going through OpenSL ES keeps the HAL
in charge of the mixer and the output path instead of racing it for the PCM
device.

### #40 — sensor-bridge: ASensorManager to /data/ubuntu/tmp, disabled

**Problem**
The chroot has no sensor data. `/dev/input/event*` is owned by `system:input`
and the Android input stack already has those devices open, so a chroot reader
competes with `system_server` for the same evdev queue: events are split
between the two readers instead of duplicated.

**Trial-Error**
- Reading `/dev/input` directly loses events rather than sharing them, which is
  worse than no data because it looks like a flaky sensor.
- A unix socket would be the better transport, but the file is simpler to
  inspect while the bridge is still a skeleton, so the file came first and the
  socket is recorded as the follow-up.

**Fix**
- New `sensor-bridge/sensor_bridge.cpp`: opens `ASensorManager`, enables the
  accelerometer, gyroscope, magnetometer and proximity sensors the device
  reports, and appends one line per sample to `/data/ubuntu/tmp/sensors.log`.
- `sensor-bridge/Android.bp.disabled`: `cc_binary` with `enabled: false`.
- `sensor-bridge/README.md`: documents the log format, the `/dev/input` reason,
  and the two known gaps.

**Files**
`sensor-bridge/sensor_bridge.cpp`, `sensor-bridge/Android.bp.disabled`,
`sensor-bridge/README.md`, `README.md`, `CHANGELOG.md`

**Impact**
No build change: Soong never parses the directory. The log is append-only and
never rotated, so a device left running for days grows it without bound; that
is recorded as a known gap rather than left to be discovered. Only the four
sensor types above are handled.

### #41 — Re-enable the ADB over Wi-Fi password gate

**Problem**
`ubuntu-enter` shipped with `DEBUG_NO_PASSWORD=1`, which skipped the password
prompt on every transport. Combined with `ro.adb.secure=0` and port 5555 open,
anyone on the LAN had a root shell with no credential at all. The gate code was
intact but unreachable.

**Trial-Error**
- Flipping the flag alone is not enough: the header comment and the README both
  documented `=1` as the current state, so the next reader would have "fixed"
  it back.
- The README table listed `DEBUG_NO_PASSWORD=1` as a connection mode next to
  USB and Wi-Fi, which reads as if it were a transport rather than a switch.

**Fix**
- `ubuntu-enter/ubuntu-enter.sh`: `DEBUG_NO_PASSWORD=0`. USB (`CONFIGURED`)
  still lands straight in; Wi-Fi now prompts for `/data/adb_wifi_pass`
  (default `santoniadmin`), 3 tries, then the session is closed.
- Header comment and the DEBUG MODE block now describe `=0` as the shipped
  state and `=1` as the bench-only escape hatch.
- `README.md`: the debug-phase note and the login-shell table match the new
  default, and `=1` is documented as a switch rather than a transport.

**Files**
`ubuntu-enter/ubuntu-enter.sh`, `README.md`, `CHANGELOG.md`

**Impact**
ADB over Wi-Fi requires the password again. USB access is unchanged, so
`vps-setup` and recovery over the cable still need no credential. Anyone who
relied on passwordless Wi-Fi access must now feed the password on stdin.

### #42 — Fix 5 documentation bugs and script step labels

**Problem**
Five documentation defects made the guide actively misleading:
1. `vps-setup/vps-setup.sh` printed `[1/6]`..`[5/6]` then `[6/7]`..`[7/7]`, so
   the progress counter contradicted itself mid-run.
2. README Step 2 cloned the vendor repo into `vendor/xiaomi/santoni`, but that
   repo has a `santoni/` wrapper at its root, so the checkout landed at
   `vendor/xiaomi/santoni/santoni/` and `lunch` died with
   `"vendor/xiaomi/santoni/santoni-vendor.mk" does not exist`.
3. The "For AI Agents" table still said "Fix SELinux denial — NEVER set
   permissive", contradicting Hard Rule #2, which makes permissive the shipped
   state for the headless VPS build.
4. The README Commit History table stopped at #23 and had off-by-one numbers
   for #7, #9 and #10 relative to CHANGELOG.md.
5. CHANGELOG.md still had `-` in the Hash column for #33–#40.

**Trial-Error**
- The vendor path cannot be fixed by moving files after the clone: the wrapper
  directory is part of the repo, so the clone target itself has to be
  `vendor/xiaomi`. Documenting a post-clone `mv` would have been a second
  thing to get wrong.
- The Commit History table could not simply be extended from #23: three of its
  existing rows disagreed with CHANGELOG.md, so the whole table was rebuilt
  from `git log` rather than appended to.
- #42's own hash cannot appear in the table it is committed with, so that row
  stays `-` until the next commit touches the file.

**Fix**
- `vps-setup/vps-setup.sh`: all seven steps now print `[N/7]`.
- `README.md` Step 2: clone target is `vendor/xiaomi`, with a comment naming
  the exact `lunch` error the old path produced.
- `README.md` "For AI Agents": the SELinux row now matches Hard Rule #2 —
  permissive is the shipped state, denials are logged rather than fatal, and
  the rule still has to be fixed for a phone build.
- `README.md` Commit History: rebuilt from `git log`, #42 down to #1, with the
  #7/#9/#10 numbering corrected.
- `CHANGELOG.md`: hashes filled in for #33–#41.

**Files**
`vps-setup/vps-setup.sh`, `README.md`, `CHANGELOG.md`

**Impact**
No build change. A fresh clone following Step 2 now produces a tree `lunch`
accepts, the installer's progress counter is consistent, and the agent-facing
rules no longer contradict the SELinux policy the build actually ships.

### #43 — qassa-ubuntu branches, kernel headers requirement, vendor clone path

**Problem**
The build stopped at 1% because `kernel/xiaomi/msm8937` did not exist. Soong's
`generated_kernel_includes` module runs
`make -C kernel/xiaomi/msm8937 headers_install`, and its output is consumed by
`external/tinycompress` and `hardware/qassa/interfaces/cryptfshw/1.0`, so the
module cannot be stubbed out. The README still described the kernel checkout as
OPTIONAL and pointed at branch `13`, which does not exist on the kernel repo
(the branches are `10` and now `qassa-ubuntu`).

**Fix**
- Kernel repo: new branch `qassa-ubuntu` based on `10`, with a README note that
  the branch exists to supply `headers_install` output for the headless Ubuntu
  project and that the boot image still comes from the prebuilt Luuvy C.4.0
  `Image.gz-dtb`.
- Vendor repo: new branch `qassa-ubuntu` based on `10.0`, plus a root README
  documenting the branch and the clone path.
- README: Repository Map and Step 2 now list all three repos with their
  `qassa-ubuntu` branches. The kernel clone is no longer commented out and is
  no longer described as optional. The vendor clone target is `vendor/xiaomi`,
  because the vendor repo root holds a single `santoni/` directory.
- README: the "Update kernel config" common task no longer implies that editing
  a defconfig changes the shipped kernel.

**Files**
`README.md`, `CHANGELOG.md`

**Impact**
No build-system change. A fresh clone following Step 2 now produces a tree that
gets past the 1% `generated_kernel_includes` failure. The boot image is
unchanged — it is still the prebuilt Luuvy C.4.0 kernel.

### #49 — curl in the image, 60-column output

**Problem**
The first field test on a Redmi 4X (santoni) surfaced two problems.

1. Step `[3/7]` failed with `no downloader on the device (no curl, no wget)`.
   Android 10 ships neither, and toybox in this build has no `wget` applet, so
   the rootfs had to be pushed from a PC by hand.
2. The step banners and the `adb push` recipe were wider than a Windows CMD
   window, so the output wrapped and piled up on top of itself.

The Wi-Fi join itself was fine: `cmd wifi connect-network` from the Android 10
backport connected on the first try and `ip -4 addr show wlan0` reported
`192.168.110.171`. The join mechanism is unchanged.

**Fix**
- `curl` is added to `PRODUCT_PACKAGES`. The in-tree `external/curl` module
  builds a platform binary in about a minute and links the system
  `libssl`/`libcrypto`/`libz`, so no prebuilt static blob is vendored. It
  installs to `/system/bin/curl`. The downloader passes
  `--capath /system/etc/security/cacerts`, which is an OpenSSL-style hashed
  directory.
- `vps-setup` tries the primary URL, then the 22.04.5 fallback, and prints the
  size of the tarball it got.
- Every line `vps-setup` and `ubuntu-enter` print is now under 60 columns.
- `getprop dhcp.wlan0.ipaddress` is dropped from the IP wait loop: the
  framework's DHCP client does not populate it, and `ip -4 addr show wlan0`
  already returns the address.

**Files**
`vps-setup/vps-setup.sh`, `ubuntu-enter/ubuntu-enter.sh`, `qassa_santoni.mk`,
`README.md`, `CHANGELOG.md`

**Impact**
`vps-setup` no longer needs a PC after the ROM is flashed: it joins Wi-Fi and
downloads the rootfs on the device. The image grows by the `curl` binary. The
Wi-Fi join path is unchanged.

### #50 — `wifi` helper and the scan backport

**Problem**
Android 10's `cmd wifi` has no `scan`, `disconnect` or `status`, and
`dumpsys wifi` does not print scan results on Q: `WifiServiceImpl.dump()` never
reaches `WifiConnectivityManager`, and `ClientModeImpl.dump()` only prints the
current `WifiInfo`. So there was no way to list nearby networks from a shell.
The commands that did exist were also long enough to wrap in a CMD window.

**Fix**
- `patches/apply-wifi-scan.py` adds `scan`, `list-scan-results`, `disconnect`
  and `status` to `WifiShellCommand`, following the same shape as the
  `connect-network` backport. `scan` drives `WifiScanner` from
  `WifiInjector.getWifiScanner()`, waits up to 15s for the result batch, and
  prints one line per network sorted by signal.
- `wifi/wifi.sh` installs to `/system/bin/wifi` and gives the short form:
  `wifi scan`, `wifi connect <ssid> [password]`, `wifi disconnect`,
  `wifi status`, `wifi help`. Every line stays under 60 columns.

**Files**
`patches/apply-wifi-scan.py`, `wifi/wifi.sh`, `wifi/Android.mk`,
`qassa_santoni.mk`, `README.md`, `CHANGELOG.md`

**Impact**
Nearby networks can be listed from the device. The Wi-Fi join path is
unchanged: `wifi connect` calls the same `cmd wifi connect-network` that
`vps-setup` uses.

### #51 — Passwords are set and printed

**Problem**
`vps-setup` created `/data/adb_wifi_pass` but only said "wrote the default
password", so the value was never shown. Worse, it never set a root password at
all: the base rootfs ships root locked, and the README told you to run
`passwd root` by hand. Even after doing that, SSH still refused root because
Ubuntu 22.04 defaults to `PermitRootLogin prohibit-password`. The result was a
"VPS" reachable only over adb.

**Fix**
- Step 6 now prints the ADB Wi-Fi password it seeded.
- Step 8 generates a 16-character root password from
  `/proc/sys/kernel/random/uuid`, `chpasswd`s it into the chroot, saves it to
  `/data/ubuntu_root_pass` (0600 root:root) and sets `PermitRootLogin yes`.
- The closing summary prints both passwords and where they live.

**Files**
`vps-setup/vps-setup.sh`, `README.md`, `CHANGELOG.md`

**Impact**
`ssh root@<ip>` works right after setup, with no manual step. The trade-off is
that root password login is enabled on the LAN; use a key and revert
`PermitRootLogin` if that is not acceptable.

### #52 — Fix `apt-get: not found` inside the chroot

**Problem**
`vps-setup` step 7 ran `chroot /data/ubuntu /usr/bin/env DEBIAN_FRONTEND=... /bin/sh -c 'apt-get update && ...'`.
`env` does not reset `PATH`, so the shell inside the chroot inherited Android's
`PATH` (`/sbin:/system/bin:/system/xbin:...`), which has no `/usr/bin`. dash
then reported `/bin/sh: 1: apt-get: not found` and `openssh-server` was never
installed, leaving the device reachable only over adb.

**Fix**
- Step 7 sets `PATH`, `HOME` and `DEBIAN_FRONTEND` inside the chroot before
  calling `apt-get`, and checks for `/usr/sbin/sshd` afterwards instead of
  trusting apt's exit code.
- `chpasswd` is now called by absolute path (`/usr/sbin/chpasswd`).
- `init.ubuntu.sh` sets the same `PATH` before `service ssh start`, because the
  init.d script behind `service` needs `/usr/bin`.

**Files**
`vps-setup/vps-setup.sh`, `rootdir/init.ubuntu.sh`, `README.md`, `CHANGELOG.md`

**Impact**
`openssh-server` installs on the first run. Devices already set up can be
repaired without reflashing by running the chroot `apt-get` command by hand.

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
