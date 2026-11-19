# CHANGELOG: santoni_qassa_ubuntu

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
| 53 | v22 | - | [v22] santoni: give the chroot a working PATH and DNS (#53) |
| 54 | v22 | c82969e | [v22] santoni: Log the boot script and clear the stale sshd pidfile (#54) |
| 55 | v22 | 2f67f1d | [v22] santoni: use a pushed rootfs in vps-setup instead of deleting it (#55) |
| 56 | v22 | 35b67c0 | [v22] santoni: retry the rootfs download while netd has no DNS yet (#56) |
| 57 | v22 | 34fe3d1 | [v22] santoni: use the IPv6 resolver netd actually uses in the chroot (#57) |
| 58 | v22 | 7c7f3d6 | [v22] santoni: wait for the chroot to resolve before apt runs (#58) |
| 59 | v22 | 7a2be04 | [v22] santoni: run apt download methods as root in the chroot (#59) |
| 60 | v22 | - | [v22] santoni: stop the chroot login from printing unknown group IDs (#60) |
| 61 | v23 | bf851d2 | [v23] santoni: strip every remaining UI APK from the image (#61) |
| 62 | v23 | b10ec8d | [v23] santoni: busybox udhcpc replaces the framework Wi-Fi path (#62) |
| 63 | v23 | 07903cf | [v23] santoni: stop the graphics stack and Zygote at boot (#63) |
| 64 | v23 | 027fe83 | [v23] santoni: bring Wi-Fi up in the background after sshd (#64) |
| 65 | v24 | fd4c91c | [v24] santoni: rebrand to qassa_ubuntu22-ziachi-santoni (#65) |
| 66 | v25 | 59ca5c7 | Start the chroot from `on boot` and drop the unused HALs (#66) |
| 67 | v26 | b24d68a | Fix wpa_supplicant socket dir + set clock after DHCP (#67) |
| 68 | v27 | 7dcebea | Give wpa_supplicant a config file so it adds wlan0 (#68) |
| 69 | v28 | 08b3c16 | Add the main-table rule before the default route, resolve DNS without netd |
| 70 | v29 | 9243aa2 | Resolve the clock-check host without netd |
| 71 | v30 | 6de6fb4 | Start sshd from vps-setup instead of waiting for a reboot |
| 72 | v31 | 2aba1f1 | Mount devpts in the chroot so sshd can allocate a pty |
| 73 | v32 | 86f58bd | Do not trust a stale wpa_supplicant socket at boot |
| 74 | - | 66b2197 | Stop filtering multicast/broadcast and install the 224.0.0.0/4 route |
| 75 | - | f76cc2d | Start the Minecraft server and NetherNet responder at boot |
| 76 | - | 4704dcb | Tune kernel network limits and chroot net groups for game servers |
| 77 | - | 86e92b5 | vps-setup: make reboot actually reboot the device |
| 78 | - | 9c3e48e | vps-setup: make every message and comment English |
| 79 | - | 9c30a45 | vps-setup: give root the Android network groups and quiet the ssh condition |
| 80 | - | 589b939 | vps-setup: start cron at boot so crontab jobs actually run |
| 81 | - | 28c0686 | vps-setup: give cron.service a PIDFile so is-active reports it |
| 82 | - | - | vps-setup: move the boot scripts out of /root |
| 83 | - | - | vps-setup: ship cron.service.d/pidfile.conf in the image |
| 84 | - | - | vps-setup: install cron, it was never in VPS_PACKAGES |
| 85 | - | - | vps-setup: install iproute2, it was never in VPS_PACKAGES |
| 86 | - | - | vps-setup: start cron even when a stale pidfile survives reboot |
| 87 | - | - | vps-setup: make crond.pid readable so is-active works for non-root |
| 88 | - | - | docs: add index README inside docs directory |
| 89 | - | - | docs: refresh the v1.2 proof screenshot and trim em dashes |
| 90 | - | - | docs: document the TUI raw-mode freeze and the missing terminal size |
| 91 | - | - | docs: correct the TUI freeze entry, empty $EDITOR falls back to vi |
| 92 | - | - | vps-setup: standardise the CLI environment for every session type |
| 93 | - | - | vps-setup: rotate the logs and TRIM weekly from cron |
| 94 | - | - | vps-setup: ship the six overlay files #92 added but never copied |
| 95 | - | - | vps-setup: quiet the systemctl scan, add loginctl and a user session bus |

## Releases

| Version | Date | Build | Size (B) | SHA-256 | Notes |
|---------|------|-------|----------|---------|-------|
| v1.3.1 | 2026-11-20 | qassa_ubuntu22-ziachi-santoni.zip | 547148409 | `e9d7e60b8871e2a65bba4a673b4bef92b49dbd2942e6ef7bae97f99b8b2a9795` | v1.3.1 (`7bf47c6`): enabled user services start at boot; 3/3 reboot rounds passed |
| v1.2 | 2026-11-18 | qassa_ubuntu22-ziachi-santoni.zip | 547173448 | `24509786f13528d7ac1d51ea9ca7a90c04bcdfc16f356c785ed40247602a59f0` | v1.2 (`fdf4598`): cron, iproute2, systemctl and reboot fixed; 88/88 checks passed |
| v1.1 | 2026-11-16 | qassa_ubuntu22-ziachi-santoni.zip | 545707833 | `199a1eafc5eec73948a8bd4d04c1839496e89e213a11e20e7f52a4eb1219cccc` | v32 (`86f58bd`) — devpts and the stale wpa_supplicant socket fixed; flashed and verified on the device |
| v1 | 2026-11-16 | qassa_Sisu-v2.4_0.s-UNOFFICIAL-santoni-20261116-0554-Vanilla-signed.zip | 640482400 | `bead5e737f20426f21f98a31c14d533d7a3cbf6f1b06d84819176de5c4f1dfe9` | v22 (`b2da746`) — first headless build published |
| v20 | 2026-06-19 | qassa_Sisu-v2.4_0.s-UNOFFICIAL-santoni-20260619-0327-Vanilla-signed.zip | - | - | Clean build: Override removed, Dolby removed, PinnerService fixed, Spectrum added |

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

### #53 — Give the chroot a working PATH and DNS

**Problem**
Two follow-on failures from #52, both seen on the first real device run:

1. `bash: groups: command not found` after `adb shell`. `/etc/profile` in
   `ubuntu-base` sets `PS1` and sources `profile.d`, but never sets `PATH`, so
   `bash -l` kept Android's `PATH` and lost `/usr/bin`.
2. `apt-get update` reached the network but every index failed with
   `Temporary failure resolving 'ports.ubuntu.com'`. `resolv.conf` was written
   with `8.8.8.8` and `1.1.1.1`, which this network drops.

**Fix**
- `ubuntu-enter` builds the chroot environment with `env -i` and an explicit
  `PATH`, `HOME`, `USER`, `LOGNAME`, `SHELL` and `TERM` instead of trusting
  `/etc/profile`.
- `vps-setup` now sets the root password to a fixed `santoniadmin` by default
  (`UBUNTU_ROOT_PASS` overrides it) instead of a random 16-character string,
  and verifies the hash actually landed in `/etc/shadow`. The old code hid
  `chpasswd` errors behind `2>/dev/null`, so `/data/ubuntu_root_pass` could
  hold a password that was never applied and every SSH login was rejected.
- `vps-setup` and `init.ubuntu.sh` export `TMPDIR=/tmp` inside the chroot.
  `adb shell` exports `TMPDIR=/data/local/tmp`, which does not exist there, so
  `mktemp` failed and the `openssh-server` postinst aborted with exit status 1
  — the package unpacked but never configured, leaving no `/usr/sbin/sshd`.
- `init.ubuntu.sh` starts sshd by running `/usr/sbin/sshd` directly after
  `ssh-keygen -A`, instead of `service ssh start`. The Debian init script
  expects systemd and failed silently in the chroot, so a freshly installed
  sshd never listened and the port answered `Connection refused`.
- `vps-setup/offline-debs.txt` lists the ten arm64 packages `openssh-server`
  needs on top of the base rootfs, resolved against the exact package set of
  `ubuntu-base-22.04-base-arm64.tar.gz` with `--no-install-recommends`. It is
  the fallback for a device whose chroot cannot reach the network at all.
- `vps-setup` and `init.ubuntu.sh` copy the `wlan0` gateway into the main
  routing table. Android keeps the real default route in a per-network table
  and leaves an `unreachable default` in main; chroot processes are unmarked,
  so they hit that unreachable route and every outbound packet fails with
  `ENETUNREACH` — which surfaces as `Temporary failure resolving` no matter
  which resolver `resolv.conf` names.
- `vps-setup` writes `resolv.conf` from the resolver `dumpsys connectivity`
  reports, which is the one the framework actually uses. `net.dns1`, the
  default route's gateway and the `wlan0` subnet are only fallbacks, because
  on the santoni test network the gateway routes but does not answer DNS.
  `1.1.1.1` is replaced by `223.5.5.5`, which is reachable on networks that
  drop the public resolvers.
- `init.ubuntu.sh` refreshes `resolv.conf` on every boot so a network change
  does not leave the chroot with a dead resolver.

**Files**
`ubuntu-enter/ubuntu-enter.sh`, `vps-setup/vps-setup.sh`,
`rootdir/init.ubuntu.sh`, `README.md`, `CHANGELOG.md`

**Impact**
`adb shell` lands in a usable shell and `apt-get install` works on the first
run. Devices already set up can be repaired without reflashing by exporting
`PATH` and pointing `/etc/resolv.conf` at the router.

### #54 — Log the boot script and clear the stale sshd pidfile

**Problem**
After a reboot, SSH answered `Connection refused` and the only way back was to
run a repair script over USB. Nothing in the boot path left a trace:
`adb logcat -s vps-boot` and `dmesg | grep vps-boot` both came back empty,
because init sends a service's stdout to `/dev/null`. The README documented the
logcat command as if it worked, which sent the investigation after the wrong
cause for a while.

`/run` inside the chroot lives on `/data`, so `/run/sshd.pid` survives a
reboot. On builds that still used `service ssh start`, `start-stop-daemon`
treated a live PID in that file as "sshd already running", and `--oknodo` made
the init script exit 0 — so the boot log said `sshd started` while port 22 was
empty.

**Fix**
- `init.ubuntu.sh` writes its output to `/data/ubuntu-boot.log`, capped at
  64 KB, so a failed bring-up can be read after the fact.
- `init.ubuntu.sh` removes `/run/sshd.pid` before starting sshd.
- sshd's own stderr is no longer discarded, and the script checks afterwards
  whether port 22 is listening, logging `sshd listening on :22` or
  `sshd is NOT listening on :22`.
- `README.md` replaces the `adb logcat -s vps-boot` instruction with
  `adb shell cat /data/ubuntu-boot.log`, and gains a troubleshooting row for
  `Connection refused` after a reboot.

**Files**
`rootdir/init.ubuntu.sh`, `README.md`, `CHANGELOG.md`

**Impact**
A device that fails to bring sshd up now says why, in a file that survives the
boot. Devices on builds before `c82969e` can be repaired without reflashing by
removing the pidfile and starting sshd by hand.

### #55 — Make the pushed-rootfs fallback actually work

**Problem**
On a clean flash the device has no Ubuntu rootfs, so `vps-setup` is the first
thing to run. Its download step failed with `curl: (6) Could not resolve host:
cdimage.ubuntu.com` — DNS on the device, not the mirror — and the script then
told the user to push the rootfs from the PC. That advice could not work:
`fetch()` starts with `rm -f "$TARBALL"`, so a pushed tarball was deleted before
curl ran and the script failed the same way again. The message also said "no
downloader on the device" when curl was present and only the lookup had failed,
which points at the wrong cause.

**Fix**
- `vps-setup` uses a tarball already present at
  `/data/local/tmp/ubuntu-base.tar.gz` instead of downloading, so the documented
  fallback works.
- The failure message names the real cause and prints the exact push command
  with the full destination path.

**Files**
`vps-setup/vps-setup.sh`, `CHANGELOG.md`

**Impact**
A device whose DNS is broken can still be set up: download the rootfs on the
PC, `adb push` it, re-run `vps-setup`. Step 7 is unaffected because apt inside
the chroot resolves through the `resolv.conf` the script writes, not through
netd.

### #56 — Retry the rootfs download while netd has no DNS yet

**Problem**
On a clean flash, `vps-setup` failed at step 3 with `curl: (6) Could not resolve
host: cdimage.ubuntu.com` on both the primary and the fallback URL, while
`ping 8.8.8.8` worked. Minutes later the same `curl` command returned
`HTTP/1.1 200 OK` and `ping cdimage.ubuntu.com` resolved. The network was fine;
the script was too early. `dumpsys connectivity` shows the window: right after
DHCP the network reports `state=AVAILABLE` with `DnsAddresses: [ ]`, and only
later gets `[ /240e:37a:4ab:1::1,/192.168.110.1 ]`. `vps-setup` waited for an IP
on wlan0 and then downloaded immediately, so curl ran inside that window and
failed instantly.

**Fix**
- The download is retried up to six times, five seconds apart, before the
  script gives up.
- A missing downloader is detected once, up front, and reported as such instead
  of being retried.

**Files**
`vps-setup/vps-setup.sh`, `CHANGELOG.md`

**Impact**
A clean-flash setup no longer fails because it raced the network's DNS
configuration. The retry also covers a flaky link during the 27 MB download.

### #57 — Use the IPv6 resolver netd actually uses

**Problem**
`vps-setup` reached step 7 and `apt-get update` failed with `Temporary failure
resolving 'ports.ubuntu.com'` on all four suites, so `openssh-server` was never
installed. The chroot had a working default route and a resolv.conf, but the
resolver in it was `192.168.110.1` — the gateway, which routes but does not
answer DNS. The extraction filtered `DnsAddresses` down to IPv4 with
`grep -o '[0-9]\{1,3\}\(\.[0-9]\{1,3\}\)\{3\}'`, which discarded
`240e:37a:4ab:1::1`: the IPv6 resolver netd lists first, and the one that
actually answers on this network.

**Fix**
- `vps-setup.sh` and `init.ubuntu.sh` now keep every address from
  `DnsAddresses`, IPv6 included, in netd's order, and write all of them to
  `resolv.conf` ahead of the public fallbacks.

**Files**
`vps-setup/vps-setup.sh`, `rootdir/init.ubuntu.sh`, `CHANGELOG.md`

**Impact**
`apt` inside the chroot resolves again, so `openssh-server` installs and sshd
can start on boot.

### #58 — Wait for the chroot to resolve before apt runs

**Problem**
`vps-setup` reached step 7 and `apt-get update` failed with `Temporary failure
resolving 'ports.ubuntu.com'` on all four suites, so `openssh-server` was never
installed. Testing each resolver from inside the chroot afterwards showed
`192.168.110.1`, `8.8.8.8`, `223.5.5.5` and `240e:37a:4ab:1::1` all resolving,
so the resolver list was not the problem: the chroot had no working network at
the moment apt ran. The link is re-associated in step 1 and netd can flush the
main table when it re-validates the network, which removes the default route
step 5 added. apt has no retry of its own, so it failed once and the script
moved on.

**Fix**
- Before apt runs, the default route is re-added if it is missing and the
  chroot is polled with `getent hosts` until it resolves, up to 60 seconds.
- The comments claiming the gateway does not answer DNS are gone; it does.

**Files**
`vps-setup/vps-setup.sh`, `rootdir/init.ubuntu.sh`, `CHANGELOG.md`

**Impact**
`openssh-server` installs on the first run instead of needing a manual
`apt-get install` afterwards.

### #59 — Run apt's download methods as root in the chroot

**Problem**
`apt-get update` inside the chroot failed with `Temporary failure resolving
'ports.ubuntu.com'` even after the resolver and the default route were fixed.
The kernel is built with `CONFIG_ANDROID_PARANOID_NETWORK`, which only lets a
process call `socket(AF_INET)` if it is in group `AID_INET` (3003) or holds
`CAP_NET_RAW`. Root has `CAP_NET_RAW`, so `getent` and `curl` worked, but apt
drops to `_apt` (uid 42) for its download methods and that user has neither, so
`socket()` returned `EACCES`. The resolver needs a UDP socket too, so the first
error to surface was the DNS one, which pointed at the wrong cause. Pinning a
host in `/etc/hosts` produced the real message: `Could not create a socket for
<ip> (f=2 t=1 p=6) - socket (13: Permission denied)`.

**Fix**
- `vps-setup` writes `APT::Sandbox::User "root";` to
  `/etc/apt/apt.conf.d/99sandbox` before the first `apt-get`.

**Files**
`vps-setup/vps-setup.sh`, `CHANGELOG.md`

**Impact**
`apt-get update` and `apt-get install` work in the chroot on this kernel without
disabling the paranoid network check. Adding `_apt` to group 3003 is not enough,
because apt calls `setgroups()` when it drops privileges.

### #60 — Stop the chroot login from printing unknown group IDs

**Problem**
Every interactive `adb shell` printed eleven lines of
`groups: cannot find name for group ID <n>` before the prompt. `chroot` does not
change credentials, so the shell inherits Android's supplementary groups
(1004, 1007, 1011, 1015, 1028, 3001, 3002, 3003, 3006, 3009, 3011), and
Ubuntu's `/etc/group` has no names for them. The caller is `/etc/bash.bashrc`,
whose sudo hint runs `$(groups)` on every interactive login. SSH logins were
clean because sshd calls `initgroups()` and rebuilds the list from the chroot's
own `/etc/group`.

**Fix**
- `ubuntu-enter` runs the login shell through `setpriv --clear-groups`, so the
  chroot starts with only root's primary group. The plain `bash -l` path is kept
  as a fallback for a rootfs without `util-linux`.

**Files**
`ubuntu-enter/ubuntu-enter.sh`, `CHANGELOG.md`

**Impact**
`adb shell` lands on a clean prompt. Devices on builds before this commit can
silence it without reflashing with `touch /root/.hushlogin`, which makes
`/etc/bash.bashrc` skip the sudo hint block entirely.

### #61 — Strip every remaining UI APK from the image

**Problem**
The first pass only overrode `SystemUI`, `Launcher3`, `Launcher3QuickStep`,
`GCam` and `XiaomiAddon`. A scan of `out/target/product/santoni` after the v22
build still found 16 UI APKs installed: `Settings`, `SettingsIntelligence`,
`DocumentsUI`, `FMRadio`, `MatLog`, `Calendar`, `DeskClock`, `ExactCalculator`,
`Gallery2`, `LatinIME`, `messaging`, `Contacts`, `Dialer`, `WallpaperCropper`,
`WallpaperPicker2` and `LiveWallpapersPicker`. The same scan turned up the rest
of the UI the first pass never looked at: `Aperture`, `EasterEgg`,
`WallpaperBackup`, `XiaomiParts`, `GamingMode`, `MusicFX`,
`SoundPickerPrebuilt`, `PowerOffAlarm`, `Provision`, `OneTimeInitializer`,
`EmergencyInfo`, `StorageManager`, `ShadyQuickStep`, `VpnDialogs` and
`DownloadProviderUi`.

**Fix**
- `LOCAL_OVERRIDES_PACKAGES` on the `RemovePackages` stub now lists all 37
  names, one per line.
- The comment in `qassa_santoni.mk` records what the list covers and what it
  deliberately leaves alone.

**Files**
`prebuilts/Android.mk`, `qassa_santoni.mk`, `CHANGELOG.md`, `README.md`

**Impact**
The image no longer carries an app that only exists to draw something. Core
system packages, the providers (`SettingsProvider`, `MediaProvider`,
`TelephonyProvider`, ...), the telephony/modem stack (`TeleService`, `Telecom`,
`ims`, `qcrilmsgtunnel`, `Stk`, `MmsService`, `CellBroadcastReceiver`) and the
network services (`InProcessNetworkStack`, `SoftAPManager`, `WfdService`,
`OsuLogin`, `PlatformCaptivePortalLogin`) are untouched. A wrong name in the
list is harmless: the override silently matches nothing.

### #62 — Replace the framework Wi-Fi path with wpa_cli and busybox udhcpc

**Problem**
`cmd wifi` and `svc wifi` are both shell front-ends for `system_server`. Once
Zygote is stopped neither exists, so `vps-setup` could not join a network and
nothing renewed the wlan0 lease. The framework's `DhcpClient` lives in
`system_server` as well, and the lease on this network is 7200 s, so the address
would have expired two hours after boot.

**Fix**
- `busybox/busybox`: static aarch64 BusyBox 1.37.0 (Alpine `busybox-static`,
  musl, sha256 `a6bb1e6e349cbdfa690a78cd0017413c5446bdae02ee003ceb682d4ae1a004ff`),
  installed to `/system/bin/busybox`. It supplies `udhcpc` and `wget`.
- `wifi/udhcpc.script`: the lease hook. It sets the address with busybox
  `ifconfig`, which takes the dotted netmask udhcpc hands over, replaces the
  default route, and rewrites the chroot's `resolv.conf` from the lease. It
  never flushes the address, so a failed renewal leaves the device reachable.
- `wifi/wifi.sh`: rewritten on top of `/vendor/bin/wpa_cli`. `connect` saves the
  credentials to `/data/vps_wifi.conf` (0600) because the supplicant runs
  without `-c` and has no config file to save into; `reconnect` replays that
  file; `dhcp` starts the udhcpc daemon. `scan`, `disconnect` and `status` no
  longer need the `WifiShellCommand` backports.
- `vps-setup` calls `wifi connect` instead of `svc wifi enable` plus
  `cmd wifi connect-network`, and installs `/data/ubuntu/usr/local/bin/wifi`,
  which chroots back into Android's root so the VPS can rejoin a network
  without adb.
- `wifi/resolv.conf` is copied to `/system/etc/resolv.conf`. busybox `wget` and
  `nslookup` read that file and Android has none, because bionic asks netd.
  `curl` keeps using netd.
- `wifi dhcp` reads `/proc/<pid>/cmdline` before trusting
  `/data/udhcpc.wlan0.pid`. `/data` survives a reboot, so a stale file can name
  a PID that now belongs to an unrelated process — the same trap that kept
  sshd from starting (#54).

**Files**
`busybox/Android.mk`, `busybox/busybox`, `wifi/Android.mk`, `wifi/wifi.sh`,
`wifi/udhcpc.script`, `wifi/resolv.conf`, `vps-setup/vps-setup.sh`,
`qassa_santoni.mk`, `CHANGELOG.md`, `README.md`

**Impact**
Wi-Fi no longer depends on the framework. Verified on the device: the aarch64
binary runs, and `udhcpc -i wlan0` obtained `192.168.110.171` from
`192.168.110.1` with a 7200 s lease. `wpa_cli` is not in the image yet — it is
added to `PRODUCT_PACKAGES` and needs the next build.

### #63 — Stop the graphics stack and Zygote at boot

**Problem**
The build was headless only in the sense that the UI APKs were gone.
`surfaceflinger`, `vendor.hwcomposer-2-1`, `zygote` and `zygote_secondary` still
ran, holding roughly 300 MB of RAM the chroot could use.

**Fix**
- `init.ubuntu.sh` stops `surfaceflinger`, `vendor.hwcomposer-2-1`, `zygote` and
  `zygote_secondary`, then writes 0 to
  `/sys/class/leds/lcd-backlight/brightness`. SurfaceFlinger goes first because
  its service definition carries `onrestart restart zygote`.
- The Wi-Fi section runs after the stop, not before. `wificond`'s
  `ClientInterfaceImpl` destructor calls `SetUpState(false)` when its client
  dies, which takes wlan0 down, so the interface is brought back up and the
  saved network re-selected afterwards. Connecting before the stop would be
  undone by `ClientModeImpl` anyway.
- The chroot's `resolv.conf` is only built from `dumpsys` when udhcpc's hook did
  not write one.

**Files**
`rootdir/init.ubuntu.sh`, `CHANGELOG.md`, `README.md`

**Impact**
The device boots with no display server and no Java runtime, and the chroot gets
the RAM back. Not yet verified on hardware: the stop sequence needs the next
build, and it cannot be tested over SSH because it is the link being torn down.

### #64 — Bring Wi-Fi up in the background after sshd

**Problem**
`init.ubuntu.sh` ran the whole Wi-Fi bring-up in the foreground, before the
chroot and sshd. With the router off at boot, `wifi reconnect` sits through its
20 s supplicant wait plus its 30 s association wait, and `wait_ip` another 45 s,
so everything after it — the mounts and sshd itself — was delayed by up to 95 s
for a network that was never going to come up. sshd does not need the network to
listen, so the delay bought nothing.

**Fix**
- The bring-up is now a `wifi_bringup` function: `ip link set wlan0 up`,
  `wifi reconnect` when `/data/vps_wifi.conf` exists, `wifi dhcp`, then the
  default route and the chroot's `resolv.conf`.
- The script launches it with `&` as the last step, after sshd is listening, and
  returns immediately. `vps-boot` is a `oneshot` service, so init does not kill
  the process group when the script exits and the background job survives.
- The default route and `resolv.conf` moved out of the chroot section into that
  function. They depend on the lease, so leaving them in the foreground would
  have kept the 60 s route wait on the boot path.
- The no-Ubuntu path launches the same function before its `exit 0`, so a device
  without a chroot still gets Wi-Fi.
- `resolv.conf` is only written when `$UBUNTU_ROOT/etc` exists, which keeps the
  no-Ubuntu path from logging a redirect error.
- `wifi` and `udhcpc.script` install as 0755. An `EXECUTABLES` prebuilt is
  installed with `chmod +x` on the source mode, and a checkout under umask 002
  leaves the source at 0664, which installed as 0775. `LOCAL_POST_INSTALL_CMD`
  now pins the mode, so the image no longer depends on the builder's umask.

**Files**
`rootdir/init.ubuntu.sh`, `wifi/Android.mk`, `CHANGELOG.md`, `README.md`

**Impact**
Boot no longer waits on the network. sshd is listening within seconds of
`sys.boot_completed`, and the link comes up whenever the router answers. Not yet
verified on hardware: needs the next build.

### #65 — Rebrand the build to qassa_ubuntu22-ziachi-santoni

**Problem**
The OTA zip was named
`qassa_Sisu-v2.4_0.s-UNOFFICIAL-santoni-<date>-Vanilla-signed.zip`, which still
carried the upstream keepQASSA codename and version number. The recovery banner
was worse: `FullOTA_Assertions` and `FullOTA_PostValidate` each printed their own
box, so recovery showed two headers, and `edify_generator.PrintQASSABanner`
ignored all six arguments it was given and printed a joke line instead of the
build id, the build date and the security patch. Settings still credited
`Omansh Krishn` as the maintainer.

**Fix**
- `vendor/qassa/config/branding.mk` spells the name out as
  `qassa_$(QASSA_BUILD_CODENAME)-$(QASSA_MAINTAINER)-$(QASSA_BUILD)`, with
  codename `ubuntu22` and maintainer `ziachi`. A GApps build still gets a
  `-GApps` suffix so the two variants cannot overwrite each other.
- `build/make/tools/releasetools/edify_generator.py` prints the build id, the
  build date and the security patch, plus the previous build for an incremental
  OTA.
- `releasetools/releasetools.py` prints one header before the flash and one
  footer after system and vendor are written, instead of two competing boxes.
- `qassa_strings.xml` credits `ziachi` as the maintainer.

**Files**
`patches/apply-branding.py`, `patches/README.md`, `releasetools/releasetools.py`,
`overlay/packages/apps/Settings/res/values/qassa_strings.xml`, `README.md`,
`CHANGELOG.md`

**Impact**
The next build produces
`out/target/product/santoni/qassa_ubuntu22-ziachi-santoni.zip`. The build date is
no longer part of the name, so a new build overwrites the previous zip. Not yet
verified on hardware: needs the next build.

### #66 — Start the chroot from `on boot` and drop the unused HALs

**Problem**
`vps-boot` was triggered by `on property:sys.boot_completed=1`. On a device
whose framework never finishes booting that property is never set, so the
service never ran: `/data/ubuntu-boot.log` did not exist and
`/data/adb_wifi_pass` was never created. The first boot after a data wipe
spends minutes in `dex2oat`, which is exactly when the property is still
unset, and stopping zygote by hand in the middle of it aborts the boot for
good. Nothing in the chroot needs Android to be up -- it needs `/data`
mounted, which happens at `post-fs-data`, well before `boot`.

**Fix**
- `init.ubuntu.rc` triggers on `on boot` instead of
  `on property:sys.boot_completed=1`. `on boot` runs after `/data` is mounted
  and after zygote has started, so the stop sequence still has something to
  stop.
- `qrngp` is started explicitly from the same trigger. It normally hangs off
  `sys.boot_completed`, which never arrives once zygote is stopped, and sshd
  wants the entropy for its host keys.
- `init.ubuntu.sh` gains step 4b: `stop` for `qcamerasvr`, `cameraserver`,
  `ril-daemon`, `ril-daemon2`, `vendor.audio-hal-2-0`, `audioserver`, `media`,
  `mediaextractor` and `media.swcodec`. Together they hold about 210 MB of
  RSS, and with zygote gone nothing will ask for them again. `stop` is used
  rather than a kill so init does not restart them.
- `init.qcom.rc` passes `-i wlan0` to `wpa_supplicant`.
- `wifi/wifi.sh` writes `sta` to `/sys/module/wlan/parameters/fwpath` before
  starting the supplicant, waits for the control socket instead of
  `init.svc.wpa_supplicant`, and creates the socket directory itself because
  `on boot` in `/system/etc/init` runs before `init.qcom.rc`'s own `on boot`.

**Files**
`rootdir/init.ubuntu.rc`, `rootdir/init.ubuntu.sh`, `rootdir/init.qcom.rc`,
`wifi/wifi.sh`, `CHANGELOG.md`

**Impact**
The chroot now comes up on every boot without waiting for the framework, and
the framework is stopped before it can run `dex2oat`. Measured on hardware
with the framework stopped by hand: 349 MB real usage (`MemTotal -
MemAvailable`), of which 153 MB is process memory, 85 MB kernel slab and
76 MB CMA. Step 4b should take the process share down to roughly 50 MB.
`CmaTotal` is 172 MB reserved by the kernel for camera and display and can
only be reduced from the device tree.

### #67 — Fix the wpa_supplicant socket directory and set the clock after DHCP

**Problem**
Two things broke the first headless boot. `ensure_supplicant` created
`/data/vendor/wifi/wpa/sockets` with `mkdir -p` from `on boot`, which runs
before `init.qcom.rc`'s own `on boot`. init's `mkdir ... 0770 wifi wifi` then
failed because the path already existed, so the directory stayed `root:root`
and `wpa_supplicant` could not bind its control socket after dropping to the
`wifi` user. `vps-setup` died at step 1 with `wpa_supplicant did not come up`.

Separately, the boot log was stamped `Thu Jan 1 00:23:17 GMT 1970`. With the
framework stopped nothing sets the clock -- `NetworkTimeUpdateService` lives in
`system_server` -- and the device has no battery-backed RTC. Every HTTPS
request then fails with `certificate is not yet valid`, which is exactly what
the rootfs download and `apt` do.

**Fix**
- `ensure_supplicant` no longer creates the directory. It waits for init to
  create it and only starts the daemon once the directory exists.
- `wifi.sh` gains `set_clock`, called after DHCP in both `connect` and
  `reconnect`. It reads the `Date` header from
  `http://connectivitycheck.gstatic.com/generate_204` -- plain HTTP needs no
  clock -- and sets the system time with toybox `date -u MMDDhhmmCCYY.ss`,
  falling back to `-D` for builds that parse it.

**Files**
`wifi/wifi.sh`, `CHANGELOG.md`

**Impact**
`vps-setup` gets past step 1 and the clock is sane before the first HTTPS
request. Verified in the image: `system/bin/wifi` has three `set_clock`
references and no `mkdir -p "$WPA_SOCK"`. Not yet verified on hardware.

### #68 — Give wpa_supplicant a config file so it adds wlan0

**Problem**
`vps-setup` still died at step 1 with `wpa_supplicant did not come up`, even
though the daemon was alive: `getprop init.svc.wpa_supplicant` read `running`
and `/data/vendor/wifi/wpa/sockets` was correctly `0770 wifi wifi`, but the
directory was empty. `-i wlan0` on the service line does nothing on its own.
`main.c` only reaches `wpa_supplicant_add_iface()` when the interface has a
config file; with `-g` set (which fills `params.ctrl_interface`) and `-c`
missing, it breaks out of the loop and runs the event loop with no interface
at all. The daemon stays up, so init reports `running`, but no per-interface
control socket is ever created.

**Fix**
- `init.qcom.rc` passes `-c/data/vendor/wifi/wpa/wpa_supplicant.conf`.
- `wifi.sh` writes that file with `ctrl_interface=/data/vendor/wifi/wpa/sockets`
  before starting the service, owned `wifi:wifi` `0660`.
- `ensure_supplicant` waits for the socket directory instead of creating it,
  and restarts the daemon unconditionally when the socket is missing, because
  a daemon left over from a start without the config file will never create it.

**Files**
`rootdir/init.qcom.rc`, `wifi/wifi.sh`, `CHANGELOG.md`

**Impact**
`wpa_cli -i wlan0` has a socket to talk to, so `vps-setup` gets past step 1.
Verified in the image: `vendor/etc/init/hw/init.qcom.rc` line 388 carries the
`-c` argument and `system/bin/wifi` has five `WPA_CONF` references. Not yet
verified on hardware.

### #69 — Add the main-table rule before the default route, resolve DNS without netd

**Problem**
Three network bugs surfaced once the framework was stopped for good. Android has
no `from all lookup main` rule: `ip rule` stops at
`17000: from all fwmark 0x0/0x10000 lookup local_network` and then
`32000: from all unreachable`, because netd creates the per-network tables and
rules only when the framework registers a network. With the framework stopped
they are never created, so the default route in the `main` table is never read
and every packet falls through to `unreachable` -- `ping: connect: Network is
unreachable`.

The order matters too. `ip route replace default via 192.168.110.1 dev wlan0`
was rejected with `RTNETLINK answers: Network is unreachable` (rc=2) while the
rule was missing, because the kernel validates the nexthop through
`fib_lookup()`, which reads the policy rules and not just the target table.

Separately, netd only learns resolvers from the framework, so bionic
`getaddrinfo()` cannot answer: `ping 8.8.8.8` succeeded while
`ping cdimage.ubuntu.com` returned `unknown host` and `curl` died with
`Could not resolve host`.

**Fix**
- `udhcpc.script` adds `ip rule add from all lookup main pref 20000`, guarded by
  `grep -q "lookup main"`, **before** the default route, and drops the
  `2>/dev/null` on the route so a failure is visible.
- `udhcpc.script` writes the lease resolvers to `/data/vps_dns`.
- `vps-setup` resolves with `busybox nslookup` -- its own DNS client, which does
  not go through netd -- and hands `curl --resolve host:443:IP`.

**Files**
`wifi/udhcpc.script`, `vps-setup/vps-setup.sh`, `CHANGELOG.md`

**Impact**
`ping 8.8.8.8` runs at 0% loss and
`curl -fsSI --capath /system/etc/security/cacerts --resolve cdimage.ubuntu.com:443:91.189.91.124 https://cdimage.ubuntu.com/`
returns `HTTP/1.1 200 OK` on the device. Verified in the image:
`system/bin/udhcpc.script` (2483 B) and `system/bin/vps-setup` (15456 B) are
identical to the repo.

### #70 — Resolve the clock-check host without netd

**Problem**
`set_clock` read the `Date` header over plain HTTP, which needs no clock, but
`curl` still had to resolve `connectivitycheck.gstatic.com` through bionic, and
netd has no resolvers once the framework is stopped. The request never left the
device, so the clock stayed in 1970 and every HTTPS download failed with
`certificate is not yet valid`.

**Fix**
`set_clock` resolves the host itself with `busybox nslookup` (resolvers from
`/data/vps_dns`, falling back to `8.8.8.8` and `223.5.5.5`) and passes
`curl --resolve host:80:IP`, trying `connectivitycheck.gstatic.com`, then
`www.google.com`, then `cdimage.ubuntu.com` before giving up.

**Files**
`wifi/wifi.sh`, `CHANGELOG.md`

**Impact**
The clock is set before the first HTTPS request. Verified in the image:
`system/bin/wifi` (9435 B) is identical to the repo and carries two `nslookup`
references and one `vps_dns`.

### #71 — Start sshd from vps-setup instead of waiting for a reboot

**Problem**
`apt` does not start sshd in a chroot, and `vps-setup` never started it either,
so the script printed an `ssh` command while port 22 was still closed and the
first login failed with `Connection refused`. sshd only came up on the next
boot, through `init.ubuntu.sh`.

**Fix**
- `vps-setup` starts sshd the way `init.ubuntu.sh` does: `ssh-keygen -A` then
  `/usr/sbin/sshd` directly, not through `service`.
- The `/dev`, `/proc` and `/sys` mounts stay up while sshd runs so sessions can
  get a pty.
- The final message only prints the `ssh` command when sshd is actually
  listening, and says to reboot first when it is not.
- The shadow check now runs with `$CHROOT_ENV`. It used to inherit Android's
  PATH inside the chroot, so `grep` was never found and the "root has no
  password hash" warning could not fire.

**Files**
`vps-setup/vps-setup.sh`, `CHANGELOG.md`

**Impact**
`vps-setup` finishes with a reachable sshd. Verified in the image:
`system/bin/vps-setup` (16636 B) is identical to the repo and carries five
`sshd_up` references.

### #72 — Mount devpts in the chroot so sshd can allocate a pty

**Problem**
`rbind /dev` does not bring `/dev/pts` on this device, so `posix_openpt` failed
with `ENODEV` inside the chroot. `apt` could not open its log
(`E: Can not write log (Is /dev/pts mounted?) - posix_openpt (19: No such
device)`), and every ssh session came up without a pty:
`PTY allocation request failed on channel 0`, then
`Error opening terminal: unknown` for anything that needs a tty.
`init.ubuntu.sh` already had a `mount -t devpts` fallback; `vps-setup` did not.

**Fix**
Both scripts mount devpts themselves when `/proc/mounts` has no entry for it
yet, with `-o mode=0620,ptmxmode=0666,gid=5` -- without `ptmxmode`,
`/dev/pts/ptmx` cannot be opened. The mount is guarded by a `/proc/mounts`
check so repeated runs do not stack layers.

**Files**
`rootdir/init.ubuntu.sh`, `vps-setup/vps-setup.sh`, `CHANGELOG.md`

**Impact**
`ssh -tt` gets a pty and `htop` runs. Verified in the image: `vps-setup`
(17133 B) and `init.ubuntu.sh` (13570 B) are identical to the repo; `vps-setup`
carries three `devpts` references and `init.ubuntu.sh` one `ptmxmode`.

### #73 — Do not trust a stale wpa_supplicant socket at boot

**Problem**
The boot log showed `wifi: add_network failed` and then `wlan0 no address`, so
the device came up with sshd listening but no network at all.
`ensure_supplicant` only tested that the control socket file exists, and a
socket left behind by the previous boot passes that test while nothing is
listening, so every `wpa_cli` call failed and `associate()` gave up.

**Fix**
- `supplicant_alive()` asks the daemon with `wpa_cli -p <sock> -i wlan0 ping`,
  which must answer `PONG`.
- The stale socket is removed before the daemon is started, and `add_network` is
  retried once after a restart.
- `wifi_bringup` retries the whole reconnect three times, five seconds apart,
  because the supplicant is still settling at boot.

**Files**
`wifi/wifi.sh`, `rootdir/init.ubuntu.sh`, `CHANGELOG.md`

**Impact**
The device comes up with an address and sshd reachable. Verified on hardware:
`/data/ubuntu-boot.log` ends at `reconnected to aeqaeqa` ->
`ip 142.251.150.120` -> `vps-boot: wlan0 192.168.110.171` with no
`add_network failed`, and `ssh -tt root@192.168.110.171` gets `/dev/pts/1`.
Verified in the image: `wifi` (10380 B), `vps-setup` (17133 B) and
`init.ubuntu.sh` (13715 B) are identical to the repo.

### #74 — Stop filtering multicast/broadcast and install the 224.0.0.0/4 route

**Problem**
A Minecraft server on the device (Paper on TCP 25565, Geyser bridging Bedrock on
UDP 19132) never appeared in a client's LAN list. The audit ruled the network
stack out: `CONFIG_IP_MULTICAST=y`, `wlan0` carried `BROADCAST,MULTICAST`,
`rp_filter=0`, SELinux permissive, and `iptables-legacy` had no rule touching
`224.0.0.0/4`. `tcpdump` on `wlan0` showed multicast and broadcast leaving the
device, and inbound multicast from `192.168.110.147` plus inbound broadcast from
`192.168.110.1` arriving, so both directions already worked.

Two settings were still wrong for a server that has to answer a discovery probe
at any moment rather than inside an awake window:

- `McastBcastFilter=3` made the firmware drop inbound multicast/broadcast while
  the radio was in power save, and `gEnableBmps=1` put it there between beacons.
- `224.0.0.0/4` had no route in `main`. Sends worked only because the kernel
  falls back to the default route's device, so `ip route` had no entry for
  anything that looks for one.

**Fix**
- `wifi/WCNSS_qcom_cfg.ini`: `McastBcastFilter=0`, `gEnableBmps=0`.
- `wifi/udhcpc.script`: install `224.0.0.0/4 dev <iface> scope link` on every
  `bound`/`renew`, next to the default route.

**Files**
`wifi/WCNSS_qcom_cfg.ini`, `wifi/udhcpc.script`, `CHANGELOG.md`

**Impact**
Applied at runtime on the device (`iw dev wlan0 set power_save off`,
`ip route replace 224.0.0.0/4 dev wlan0 scope link`) and verified: a RakNet
unconnected ping to `192.168.110.255:19132` is answered with `id=0x1c` and the
Geyser MOTD, both from the device and from another host on the LAN, and TCP
25565 accepts connections. The ini and the hook only take effect after the next
OTA build, because `/vendor` and `/system` are read-only on the running device.

- Follow-up: the same per-network-table problem hit IPv6. The RA default route
  lives in the wlan0 table and `main` only had `unreachable default`, so
  Geyser's NetherNet ICE agent could not answer STUN requests sent to a
  client's global IPv6 address and logged `Send failed, errno=101` about three
  times a second. `wifi_bringup` now copies the IPv6 default into `main` too.

### #75 — Start the Minecraft server and NetherNet responder at boot

**Problem**
The Paper + Geyser server and the NetherNet discovery responder were started by
hand over SSH, so a reboot left the device with sshd up and no Minecraft server.
Bedrock clients also saw the wrong LAN entry: the responder took the world name
from pong field 7 (`motd2`) and the game mode from field 9, which Geyser reports
as `1`, so the list showed "Creative World - Another Geyser server" instead of
the real world.

**Fix**
- `rootdir/init.ubuntu.sh`: call `/root/mcserver/start.sh` in the chroot once
  sshd is up. The script is idempotent, so a boot hook and a manual run cannot
  double-start anything.
- `/root/mcserver/start.sh` and `stop.sh` (on the device, not in this repo):
  start and stop Paper, the console FIFO holder and the responder, each only
  when its process is absent.
- `/root/mcserver/nethernet-discovery.py`: `level_name` now comes from
  `level-name` in `server.properties` instead of pong field 7, and `game_type`
  is mapped from pong field 8 (`Survival`) instead of field 9.

**Files**
- `rootdir/init.ubuntu.sh`

**Impact**
A reboot brings the server up without a login. The Bedrock LAN entry now reads
`world` / `A Minecraft Server` in Survival instead of
`Creative World - Another Geyser server`. The hook only takes effect after the
next OTA build; on the running device `start.sh` has to be called by hand.

### #76 — Tune kernel network limits and chroot net groups for game servers

**Problem**
The device is meant to host more than one game server plus a set of local
services, but the kernel was still running Android's phone defaults. A
packet-level audit found five ceilings: `icmp_echo_ignore_broadcasts=1` made the
device ignore broadcast pings, `netdev_max_backlog=1000` dropped bursts of small
UDP packets, `ip_local_port_range=37000-50000` left only ~13k ephemeral ports,
and `somaxconn` / `tcp_max_syn_backlog` were sized for a phone. The chroot's
`/etc/group` carried only `aid_inet` (3003), so `aid_net_raw` (3004) and
`aid_net_admin` (3005) were missing — the groups Android's paranoid network
check looks for before it allows a raw socket or a multicast group join.
`net.hostname` was empty as well, so mdnsd advertised the device as
`localhost.localdomain`.

**Fix**
- `rootdir/init.ubuntu.sh`: new section 6a writes the five sysctls through
  `/proc/sys`, because toybox has no `sysctl`. It also sets `net.hostname` to
  `santoni` when the property is empty, rewrites a `localhost` chroot hostname,
  and appends the two missing `aid_net_*` groups to the chroot's `/etc/group`.
- `rootdir/init.ubuntu.sh`: `ulimit -n 32768` before `sshd` starts, so the
  daemon and everything it spawns inherit the hard limit instead of 1024.
- `rootdir/init.ubuntu.sh`: section 6b is gone (`09dc324`). It existed only to
  start the Minecraft server, and that work is dropped, so the boot script no
  longer names a specific server. `start.sh` / `stop.sh` stay on the device, so
  the server can still be started by hand over SSH.

**Files**
- `rootdir/init.ubuntu.sh`

**Impact**
Applied by hand on the running device and read back: all five sysctls report the
new values, `/etc/group` lists 3003/3004/3005, and `hostname` is `santoni`. The
boot hook only takes effect after the next OTA build. The boot script is
game-agnostic again: nothing in it names a specific server.

### #77 — Make `reboot` actually reboot the device

**Problem**
`/sbin/reboot`, `/sbin/poweroff`, `/sbin/halt` and `/sbin/shutdown` are all
symlinks to `/bin/systemctl`, so the verb arrives as `argv[0]` and `args` is
empty. The shim ignored `argv[0]` and fell through to `args = ["list-units"]`,
so `sudo reboot` printed the unit list and returned 0 — the device never
rebooted, and nothing in the output said so. `systemctl reboot` was not
recognised either: `runcommand()` only had a `halt` branch. `shutdown -r now`
died earlier still, because optparse rejected `-r` as an unknown systemctl
option. Separately, `boot-services.sh` wrote `/run/sshd.pid` as `0600 root`, so
`systemctl status ssh` and `is-active ssh` reported `inactive` for every
non-root user even while sshd was running.

**Fix**
- `vps-setup/rootdir/usr/bin/systemctl`: dispatch `argv[0]` to the
  `reboot` / `poweroff` / `halt` verbs before the empty-`args` fallback, and
  translate `shutdown` before optparse so its own flags are not parsed as
  systemctl options.
- `vps-setup/rootdir/usr/bin/systemctl`: `reboot_target()` and
  `poweroff_target()` ask Android init to do the work through
  `chroot /proc/1/root /system/bin/setprop sys.powerctl reboot`. The chroot has
  no `/system`, but `/proc` belongs to Android, so PID 1 is reachable that way.
- `vps-setup/rootdir/usr/bin/systemctl`: refuse with a clear message and exit 1
  when not root, instead of printing the unit list. `halt` maps to a device
  poweroff, because SIGQUIT to Android's PID 1 is not a halt.
- `vps-setup/rootdir/root/boot-services.sh`: write `/run/sshd.pid` as `0644`.

**Files**
- `vps-setup/rootdir/usr/bin/systemctl`
- `vps-setup/rootdir/root/boot-services.sh`

**Impact**
Verified on the device with a real reboot, not a simulation: `sudo reboot`
returned 0, the phone went down and came back in about 20 seconds, and uptime
restarted at 0. `reboot` without sudo now prints
`reboot requires root (try: sudo reboot)` and exits 1. `systemctl is-active ssh`
reports `active` for `ubuntu`, `systemctl status ssh` shows `active (running)`
with a PID that matches `/run/sshd.pid`, and `systemctl list-units` prints 204
units with no `WARNING` lines.

### #78 — Make every vps-setup message and comment English

**Problem**
`apply.sh` mixed languages inside itself: sections 1, 2 and 5 were English while
3, 4, 6, 7 and 8 were Indonesian, and its detail lines (`systemctl.orig dibuat`,
`belum terpasang`, `apply.sh: selesai`) were Indonesian too. `boot-services.sh`
carried Indonesian comments, and `vps-setup.sh` had one Indonesian comment. A
single `vps-setup` run therefore printed English and Indonesian in the same
terminal, which reads as unfinished.

**Fix**
- `vps-setup/apply.sh`: translate the five Indonesian section headers and the
  seven Indonesian detail lines, and align the eight section rules to one column
  (they ranged from 76 to 80 characters).
- `vps-setup/rootdir/root/boot-services.sh`: translate the header, the
  `/run/systemd/system` note, the `PIDFile` note and the governor note.
- `vps-setup/vps-setup.sh`: translate the `6b` overlay comment.

**Files**
- `vps-setup/apply.sh`
- `vps-setup/rootdir/root/boot-services.sh`
- `vps-setup/vps-setup.sh`

**Impact**
Output text and comments only. No logic, no file mode and no overlay payload
changed; `bash -n` passes on all three scripts. The image must be rebuilt for the
new strings to reach the device.

### #79 — Give root the Android network groups and quiet the ssh condition

**Problem**
Inside the chroot, `root` had no network at all. `ping 8.8.8.8` failed with
`ping: socket: Permission denied` and `ping google.com` failed with
`Temporary failure in name resolution`, while the same two commands worked for
`ubuntu`. The kernel is built with `CONFIG_ANDROID_PARANOID_NETWORK`, which
gates `socket()` on the caller's GID — `aid_inet` (3003) for ordinary sockets
and `aid_net_raw` (3004) for raw ones — and ignores `cap_net_raw`, which
`/bin/ping` already carries. `apply.sh` created both groups but added only
`ubuntu` to them, so the account the chroot is normally used from was the one
account without a network stack. DNS failed for the same reason: `getaddrinfo`
needs a UDP socket before it can read `/etc/resolv.conf`.

Separately, every `systemctl start ssh`, `reload ssh` and `restart ssh` printed
`ERROR:systemctl:not found /etc/ssh/sshd_not_to_be_run`. `ssh.service` carries
`ConditionPathExists=!/etc/ssh/sshd_not_to_be_run`, and the shim logged the
missing file as an error before it looked at the `!` prefix, so the success case
of a negated condition was reported as a failure.

**Fix**
- `vps-setup/apply.sh`: `usermod -aG aid_inet,aid_net_raw root` right after the
  three Android groups are created, with a comment recording why capabilities
  are not enough.
- `vps-setup/rootdir/usr/bin/systemctl`: move the `not found` log inside the
  `"!" not in mode` branch and log the negated case at debug level, the way the
  `ConditionPathExistsGlob` branch above it already does.

**Files**
- `vps-setup/apply.sh`
- `vps-setup/rootdir/usr/bin/systemctl`

**Impact**
Verified on the device, not simulated. `ping -c 3 8.8.8.8` and
`ping -c 3 google.com` report 0% packet loss as `root` and as `ubuntu`, and
`dig +short ubuntu.com` resolves for both. `systemctl start ssh` now prints only
the legitimate `the service is already running on PID ...` warning, and
`reload`/`restart` are silent. `systemctl is-active ssh` still returns `active`
with exit 0 for both users, including with a poisoned
`/run/ssh.service.status`. The image must be rebuilt for the group change to
reach a fresh install; on a running device `usermod -aG aid_inet,aid_net_raw
root` applies it immediately.
### #80 — Start `cron` at boot so `crontab` jobs actually run

**Problem**
`cron` is in `vps-setup/packages.list`, so `crontab` and `/etc/init.d/cron`
were both present, but nothing ever enabled or started the daemon. The unit sat
at `inactive (dead)` and `disabled`, so a job written with `crontab -e` was
accepted and then never ran. The same audit confirmed the rest of the chroot was
healthy: `systemctl is-active ssh` returned `active` for both `root` and
`ubuntu`, `ping` reported 0% packet loss for both, and `apt-get update` was
clean.

**Fix**
- `vps-setup/rootdir/root/boot-services.sh`: add `start_cron()`, which runs
  `systemctl enable cron` and `systemctl start cron` when either
  `/lib/systemd/system/cron.service` or `/etc/init.d/cron` exists. It is called
  after `assert_sshd_pid` and `systemctl default`, so sshd is already settled
  and a slow or failing cron cannot delay the login path. Both calls are
  idempotent, so running the script by hand stays safe.

**Files**
- `vps-setup/rootdir/root/boot-services.sh`

**Impact**
Verified on the device, not simulated. After `sudo reboot` the device came back
on the network, `systemctl is-active cron` returned `active` with exit 0, and
`ps aux` showed the daemon. A real job — `* * * * * touch /tmp/cron_ok` — was
installed with `crontab`, `/tmp/cron_ok` appeared within the minute, and both
the job and the file were removed afterwards. `systemctl is-active ssh` still
returns `active` and `ping` still reports 0% packet loss for `root` and
`ubuntu`, so the new step did not disturb the existing boot path.

### #81 — Give `cron.service` a PIDFile so `is-active` reports it

**Problem**
After #80 the daemon was running — `ps aux` showed `/usr/sbin/cron -f -P` and
`systemctl is-enabled cron` said `enabled` — but `systemctl is-active cron`
still returned `inactive` with exit 3. `cron.service` has no `Type=` line, so it
defaults to `Type=simple`, and the shim's `get_active_service_from()` has no
PIDFile to read for that type: it falls back to `/run/cron.service.status`,
which was left 0 bytes, and then to a `MainPID` that was never written. The
daemon was healthy; only the status lookup was blind.

**Fix**
- `vps-setup/rootdir/etc/systemd/system/cron.service.d/pidfile.conf`: new
  drop-in with `PIDFile=/run/crond.pid`, the file cron writes itself. This is
  the same shape as the existing `ssh.service.d/pidfile.conf`, and it makes the
  shim's first branch — a live PIDFile outranks the status file — answer for
  cron.

**Files**
- `vps-setup/rootdir/etc/systemd/system/cron.service.d/pidfile.conf`
- `CHANGELOG.md`
- `README.md`

**Impact**
Verified on the device. `systemctl is-active cron` returns `active` with exit 0
and `systemctl status cron` shows `Active: active (running)` with the drop-in
listed. The check survives a reboot, because the drop-in lives in `/etc` on
`/data` and cron rewrites `/run/crond.pid` on every start.

### #82 — Move the boot scripts out of `/root`

**Problem**
`boot-services.sh` and `suid-mount.sh` lived in `/root`, so they were the first
two entries in `dir` after `ssh root@192.168.110.171`. Root's home is also the
directory an operator clears out when tidying up, and `rm -rf ~/*` there would
have deleted the scripts that re-apply the suid bind mounts and start cron, the
systemd marker directory and the CPU governor. The next boot would then come up
without sudo, without cron and with the governor pinned.

**Fix**
- Moved both scripts to `/usr/local/sbin/`, the FHS location for locally
  installed system administration programs. It is on root's `PATH`, it is not
  visible in `/root`, and it is outside `/usr/bin` and `/usr/sbin`, so the suid
  re-bind does not touch it.
- `vps-setup/rootdir/usr/sbin/sshd`: the wrapper now calls
  `/usr/local/sbin/suid-mount.sh` and `/usr/local/sbin/boot-services.sh`.
- `vps-setup/rootdir/usr/local/sbin/boot-services.sh`: calls
  `/usr/local/sbin/suid-mount.sh` instead of `/root/suid-mount.sh`.
- `vps-setup/apply.sh`: installs `usr/local/sbin/*.sh` as `0755 root:root`, runs
  the new `suid-mount.sh` path in step 7, and removes the legacy
  `/root/boot-services.sh` and `/root/suid-mount.sh` so a device that ran an
  older `apply.sh` converges instead of keeping a stale duplicate.
- `qassa_santoni.mk`: the product copy list points at the new paths.

**Files**
- `vps-setup/rootdir/usr/local/sbin/boot-services.sh` (moved from `rootdir/root/`)
- `vps-setup/rootdir/usr/local/sbin/suid-mount.sh` (moved from `rootdir/root/`)
- `vps-setup/rootdir/usr/sbin/sshd`
- `vps-setup/apply.sh`
- `qassa_santoni.mk`
- `CHANGELOG.md`
- `README.md`

**Impact**
Verified on the device. `dir` in `/root` after a real `sudo reboot` lists only
the dotfiles, and `systemctl is-active ssh`, `systemctl is-active cron`,
`mount --rbind / /`, `/run/systemd/system` at `0755` and the `schedutil`
governor all still come up from the new path.

## Key Changes by Version

### v32
- **Wi-Fi** — the supplicant is asked with `wpa_cli ping`, so a stale socket no longer blocks the boot
- **PTY** — devpts is mounted in the chroot, so ssh sessions get a pty

### v31
- **PTY** — devpts is mounted in the chroot, so ssh sessions get a pty

### v30
- **SSH** — `vps-setup` starts sshd itself instead of waiting for a reboot

### v29
- **Clock** — the clock-check host is resolved with `busybox nslookup`, so the clock leaves 1970

### v28
- **Network** — the `lookup main` rule is added before the default route
- **DNS** — resolvers come from the DHCP lease, so `curl` can resolve without netd

### v27
- **Wi-Fi** — `wpa_supplicant` gets a config file, so `-i wlan0` actually adds the interface

### v26
- **Wi-Fi** — the socket directory is left to init, so `wpa_supplicant` can bind
- **Clock** — set from the HTTP `Date` header after DHCP, HTTPS works again

### v25
- **Boot trigger** — `vps-boot` runs from `on boot`, not `sys.boot_completed`
- **RAM** — camera, radio and media services are stopped after the framework
- **Wi-Fi** — `wpa_supplicant` gets `-i wlan0`, helper waits for the socket

### v24
- **Rebrand** — the OTA zip is `qassa_ubuntu22-ziachi-santoni.zip`
- **Recovery banner** — one header, then build id, build date and security patch
- **Maintainer** — `ziachi` in Settings and in the installer

### v23
- **True headless** — `surfaceflinger`, `vendor.hwcomposer-2-1`, `zygote` and
  `zygote_secondary` are stopped at boot, backlight off
- **Every UI APK overridden** — 37 names in `LOCAL_OVERRIDES_PACKAGES`
- **Wi-Fi without the framework** — `wpa_cli` + busybox `udhcpc`, credentials in
  `/data/vps_wifi.conf`, `wifi` wrapper inside the chroot
- **Wi-Fi in the background** — the bring-up runs after sshd, so a dead router
  no longer delays boot
- **busybox** — static aarch64 1.37.0 for `udhcpc` and `wget`

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

## Detail

### #84 — `cron` was never installed

**Problem.** `boot-services.sh` enables `cron` on every boot and
`cron.service.d/pidfile.conf` points the shim at `/run/crond.pid`, but the
package itself was never installed. `VPS_PACKAGES` in `vps-setup.sh` is a
hardcoded list that did not include `cron`, and `packages.list` — which does
list it — is only copied into the image and never read by any script. The
`start_cron` guard therefore found neither `/lib/systemd/system/cron.service`
nor `/etc/init.d/cron` and skipped silently, so the drop-in was orphaned and
`crontab` was missing entirely.

**Fix.** Add `cron` to `VPS_PACKAGES`, and point the comments and README at
`VPS_PACKAGES` instead of the unused `packages.list`.

**Files.** `vps-setup/vps-setup.sh`,
`vps-setup/rootdir/usr/local/sbin/boot-services.sh`, `README.md`,
`CHANGELOG.md`.

**Impact.** `crontab` and `cron.service` now exist, so the boot step can
enable and start the daemon and the pidfile drop-in has a unit to attach to.

### #85 — `iproute2` was never installed

**Problem.** The end-to-end audit found `ip` and `ss` missing (`command not
found`, exit 127). `packages.list` — the manifest copied into the image — lists
`iproute2 5.15.0-1ubuntu2.2`, but no script ever reads that file. `VPS_PACKAGES`
in `vps-setup.sh` is the list that is actually installed, and it shipped
`net-tools` (so `netstat` worked) without `iproute2`, so the image advertised a
package it did not contain.

**Fix.** Add `iproute2` to `VPS_PACKAGES` next to `cron`.

**Files.** `vps-setup/vps-setup.sh`, `README.md`, `CHANGELOG.md`.

**Impact.** `ip a` and `ss -tulnp` now work for `root` and `ubuntu`, and the
image matches its own `packages.list`.

### #86 — `cron` was skipped after a reboot

**Problem.** `/run` is a plain directory on `/data` in this chroot, not a tmpfs,
so `/run/crond.pid` survives a reboot. `systemctl3.py` treats a pidfile whose
pid is alive as "already running", and Android reuses pids quickly: after the
second boot the stale pid belonged to an unrelated process, so
`boot-services.sh` logged `the service is already running on PID 1596` and never
started cron. `systemctl is-active cron` still said `active`, because it read
the same stale file, so the failure was silent.

**Fix.** In `start_cron()`, drop `/run/crond.pid` when the pid it names is not
`cron`, before calling `systemctl start cron`.

**Files.** `vps-setup/rootdir/usr/local/sbin/boot-services.sh`, `README.md`,
`CHANGELOG.md`.

**Impact.** `cron` starts on every boot, and `is-active` no longer reports a
dead daemon as active.

### #87 — `is-active cron` said inactive for non-root users

**Problem.** cron writes `/run/crond.pid` `0600`. `systemctl3.py` reads the pid
from that file, so `ubuntu` could not open it and `systemctl is-active cron`
returned `inactive` (exit 3) for every non-root user while the daemon was
running. `ssh.service` had the same problem and was fixed by making its pidfile
`0644`; cron's pidfile never got the same treatment.

**Fix.** `chmod 644 /run/crond.pid` after `systemctl start cron`, with a short
wait for the file to appear.

**Files.** `vps-setup/rootdir/usr/local/sbin/boot-services.sh`, `README.md`,
`CHANGELOG.md`.

**Impact.** `systemctl is-active cron` and `systemctl status cron` report the
real state for `ubuntu` as well as `root`.

### #88 — `docs/` had no landing page

**Problem.** `docs/` held three long reference files (`ARCHITECTURE.md`,
`VPS-SETUP.md`, `BUILD.md`) plus `bug-analysis/` and `screenshots/`. Opening
the folder on GitHub showed a bare file list: nothing said which file answers
which question, and `README.md` linked each file individually, so the folder
itself was never a destination.

**Fix.** Add `docs/README.md` as the folder index: a short summary of what the
folder is for, a navigation table with one line per file, the supporting
material, and a "where to start" list. Point the `## Documentation` table in
`README.md` at it.

**Files.** `docs/README.md`, `README.md`, `CHANGELOG.md`.

**Impact.** `docs/` renders as a readable page on GitHub, and the README links
the index instead of leaving the folder unlinked.

### #89 — the proof screenshot was from a prerelease build

**Problem.** The README and the v1.2 release both showed
`docs/screenshots/ssh-ubuntu-2204.jpg`, a capture from an early prerelease
build taken next to the phone. It predates the `cron`, `iproute2` and
`systemctl` fixes, so the numbers in it (274 dpkg packages, 31 minutes uptime)
no longer matched what a v1.2 flash reports, and the prose around it described
a phone that is not in the frame.

**Fix.** Replace it with `docs/screenshots/neofetch-v1.2.png`, a `neofetch`
capture from a v1.2 build over SSH: 314 dpkg packages, 256 MiB of 1817 MiB in
use, 39 minutes uptime, bash 5.1.16 on `/dev/pts/0`. Update the field table to
the values in that capture, move the `htop` numbers into the paragraph that
describes the `htop` image, and point the v1.2 release notes at the new file.
The same pass removes the em dashes from `README.md`, `AGENTS.md`,
`docs/README.md`, `docs/ARCHITECTURE.md`, `docs/VPS-SETUP.md` and
`docs/BUILD.md`, replacing them with commas, colons, parentheses or a full
stop, so the prose reads like a person wrote it.

**Files.** `README.md`, `AGENTS.md`, `docs/README.md`, `docs/ARCHITECTURE.md`,
`docs/VPS-SETUP.md`, `docs/BUILD.md`, `docs/screenshots/neofetch-v1.2.png`,
`docs/screenshots/ssh-ubuntu-2204.jpg` (removed), `CHANGELOG.md`.

**Impact.** The README and the release page show the build that is actually
published, and the docs no longer read like a generated wall of dashes.

### #90 — a full-screen TUI in the chroot looks like a frozen shell
> **Corrected by #91.** The diagnosis below is wrong. The TUI does release raw
> mode and the alternate screen before it spawns `$EDITOR`, and Ctrl+C does
> exit. The real cause is an empty `$EDITOR`, which makes zeroclaw open `vi`.

**Problem.** `zeroclaw quickstart` is a full-screen TUI: it switches to the
alternate screen, hides the cursor and puts the pty in raw mode. In raw mode
Ctrl+C is delivered as a key event instead of SIGINT, so the interrupt never
reaches the process and the only exit is Esc. When the process is force-stopped
instead, the terminal stays in the alternate screen with echo off, which reads
as a dead shell that has to be closed. The same command also refuses to start
when the pty reports no size, which is what a client that sends no window size,
or a `script` wrapper, produces.

**Fix.** Add both cases to the troubleshooting table in `docs/VPS-SETUP.md`:
Esc is the exit, `reset` or `stty sane` recovers a terminal left behind by a
force-stopped TUI, and `stty rows 40 cols 100` or `zeroclaw config set` covers
the missing-size case. The chroot itself needed no change: `/etc/environment`
already sets `EDITOR` and `VISUAL` to `nano`, `pam_env` is active in
`/etc/pam.d/sshd`, `nano` 6.2 is installed, the terminfo entries for `xterm`,
`xterm-256color` and `screen-256color` are present, and `/dev/ptmx` plus the
`devpts` mount allocate a pty correctly.

**Files.** `docs/VPS-SETUP.md`, `CHANGELOG.md`.

**Impact.** Documentation only, no image change. A user who hits the freeze now
has the exit key and the recovery command instead of force-closing the terminal.

### #91 — SSH sessions do not inherit `/etc/environment`, so `$EDITOR` is empty

**Problem.** Any program that opens `$EDITOR` — `crontab -e`, `git commit`
without `-m`, `sensible-editor`, `sudoedit`, `sudo -e`, or an application that
shells out to the editor — opens `vi` (`/usr/bin/vim.tiny`) instead of `nano`.
`vi` is modal, so typing beeps and nothing appears and there is no visible way
out, which reads as a frozen program. `/etc/environment` does set `EDITOR=nano`
and `VISUAL=nano`, and `/etc/pam.d/sshd` does call `pam_env.so`, but `pam_env`
never applies `/etc/environment` to an SSH session in this chroot. The session
`PATH` is the seven-entry one, not the nine-entry one in `/etc/environment`, and
`EDITOR` and `VISUAL` are absent from the environment in both a non-pty and a
pty (`ssh -tt`) session.

**Root cause.** sshd runs on the Android side, outside the chroot, so the
chroot's PAM stack is never consulted for an SSH login. `su(1)` and `sudo(1)`
do run inside the chroot and do apply `/etc/environment`, which is why the same
account has `EDITOR=nano` under `sudo -i` but an empty `EDITOR` over SSH.

**Evidence.** `ssh <host> env` shows no `EDITOR` and a seven-entry `PATH`, while
`sudo -i bash -c 'echo $EDITOR'` shows `nano`. Driving a TUI in a pty and
sampling the process tree at the moment the editor runs shows the child is
`vi /tmp/edit-XXXXXXXX.txt`, not `nano`. The child's own `stty -a` reports
`isig icanon iexten echo`, and the raw output carries `ESC[?1049l` before the
editor draws and `ESC[?1049h` after it exits, so the TUI does restore the
terminal and leave the alternate screen correctly.

**Fix.** Standardise the CLI environment for every session type instead of
patching one program; see #92.

**Files.** `vps-setup/rootdir/home/ubuntu/.bashrc`,
`vps-setup/rootdir/home/ubuntu/.profile`, `vps-setup/rootdir/root/.bashrc`,
`vps-setup/rootdir/root/.profile`, `docs/VPS-SETUP.md`, `CHANGELOG.md`.

**Impact.** Every program that opens `$EDITOR` now opens `nano`. No image
change; the overlay applies on the next `vps-setup` run.

### #92 — standardise the CLI environment for every session type

**Problem.** #91 fixed the symptom per user, but the gap is wider than one
program: the chroot's PAM stack never runs for an SSH login, so
`/etc/environment` reaches `su` and `sudo` but not `ssh`. Anything that depends
on a global variable — `EDITOR`, `VISUAL`, `PAGER`, `PATH`, `LANG` — behaves
differently depending on how the session was opened.

**Fix.** Cover every session type with the mechanism that actually applies to
it:

| Session | Mechanism |
|---|---|
| `ssh <host> <cmd>` (non-interactive) | `SetEnv` in `/etc/ssh/sshd_config` |
| `ssh <host>` (login shell) | `/etc/profile.d/00-environment.sh` |
| `bash -i` (interactive non-login) | `/etc/bash.bashrc` |
| `sudo -i`, `sudo -s`, `su -` | `pam_env` (already worked) |
| `sudo -e`, `sudo visudo`, `sudo crontab -e` | `env_keep` in `/etc/sudoers.d/10-editor` |
| `sensible-editor`, `editor` | `update-alternatives` + `~/.selected_editor` |

`/etc/environment` stays the single source of truth: the `profile.d` script and
the `bash.bashrc` block source it, and `SetEnv` mirrors it for sessions that
never start a shell. `/etc/default/locale` is set to `C.UTF-8`, the only locale
the image generates, so no session can emit a locale warning.

**Verification.** Two full rounds from a fresh SSH login, each covering
`crontab -e`, `git commit` without `-m`, `sensible-editor`, `sudoedit`,
`sudo -e`, `sudo visudo`, and a TUI that opens `$EDITOR`; plus `EDITOR`,
`VISUAL`, `PAGER`, `PATH`, `LANG` and `TERM` as `ubuntu`, under `sudo -i` and
`sudo -s`, and in a non-interactive `ssh <host> env`; plus `less`, `man` and
`htop` in a pty. All open `nano`; `locale` writes nothing to stderr.

**Files.** `vps-setup/rootdir/etc/environment`,
`vps-setup/rootdir/etc/default/locale`,
`vps-setup/rootdir/etc/profile.d/00-environment.sh`,
`vps-setup/rootdir/etc/bash.bashrc`,
`vps-setup/rootdir/etc/sudoers.d/10-editor`,
`vps-setup/rootdir/etc/ssh/sshd_config`,
`vps-setup/rootdir/home/ubuntu/.selected_editor`,
`vps-setup/rootdir/root/.selected_editor`,
`vps-setup/rootdir/usr/sbin/sshd`, `docs/VPS-SETUP.md`, `CHANGELOG.md`.

**Impact.** No image change; the overlay applies on the next `vps-setup` run.
`man` still prints the "system has been minimized" stub because the image ships
no man pages; that is a packaging decision, not an environment bug.

### #93 — logs grow until the data partition fills, and nothing TRIMs the flash

**Problem.** `/var/log` lives on the same 16 GB data partition as the chroot.
Nothing rotated it: `logrotate` was not in `VPS_PACKAGES`, so the package was
not even installed. `fstrim` was scheduled by `fstrim.timer`, and systemd timers
do not run in this chroot, so the flash was never trimmed either.

**Trial-Error.**
- Installing `logrotate` alone is not enough. The packaged
  `/etc/cron.daily/logrotate` starts with `[ -d /run/systemd/system ] && exit 0`
  to defer to `logrotate.timer`. Android's init creates `/run/systemd/system`,
  so the job exited 0 on every run and rotated nothing. Confirmed with `sh -x`:
  the trace was `+ [ -d /run/systemd/system ]` then `+ exit 0`.
- The first `/etc/logrotate.d/vps` also listed `/var/log/wtmp` and
  `/var/log/btmp`. `logrotate -d` then reported
  `error: vps:21 duplicate log entry for /var/log/btmp` and
  `error: found error in file vps, skipping`, and the whole file was skipped.
  The package already ships `/etc/logrotate.d/wtmp` and `/etc/logrotate.d/btmp`,
  so those blocks were removed.
- `run-parts` skips a cron file that is not executable, and `apply.sh` gave
  every overlay file mode 644 by default. The cron scripts are matched
  explicitly now.

**Fix.**
- `logrotate` added to `VPS_PACKAGES` and to `packages.list`.
- `vps-setup/rootdir/etc/logrotate.d/vps`: weekly, `rotate 4`, `compress`,
  `delaycompress`, `missingok`, `notifempty`, `copytruncate` for
  `/var/log/boot-services.log` and `/var/log/vps-*.log`.
- `vps-setup/rootdir/etc/cron.daily/logrotate`: the packaged script with the
  systemd guard removed.
- `vps-setup/rootdir/etc/cron.weekly/fstrim`: `fstrim --verbose /`.
- `apply.sh` installs `etc/cron.daily/*` and `etc/cron.weekly/*` as 755 and
  pins `/etc/logrotate.d`, `/etc/cron.daily` and `/etc/cron.weekly` to 755
  `root:root`, because `run-parts` ignores a writable cron directory.
- `qassa_santoni.mk` copies the three new files into
  `/system/etc/vps-setup/rootdir`.
- `docs/VPS-SETUP.md` gains "Log rotation and weekly TRIM", plus an
  "Intentional by design" section that records ADB `:5555`,
  `PermitRootLogin yes`, the default passwords and `NOPASSWD` as deliberate.

**Verification.** In the device chroot: `logrotate -d /etc/logrotate.conf`
printed no `error:` lines; `/etc/cron.daily/logrotate` exited 0 and wrote
`/var/lib/logrotate/status`; a test log rotated to `.1` with the original
truncated to 0 bytes; `/etc/cron.weekly/fstrim` trimmed 197.4 MiB and exited 0.

**Files.** `vps-setup/vps-setup.sh`, `vps-setup/apply.sh`,
`vps-setup/packages.list`, `vps-setup/rootdir/etc/logrotate.d/vps`,
`vps-setup/rootdir/etc/cron.daily/logrotate`,
`vps-setup/rootdir/etc/cron.weekly/fstrim`, `qassa_santoni.mk`,
`docs/VPS-SETUP.md`, `README.md`, `CHANGELOG.md`.

**Impact.** No image change until the next build; the overlay applies on the
next `vps-setup` run. Logs are capped at four compressed weeks and the flash is
trimmed weekly. `wtmp` and `btmp` keep rotating through the package's own files.

### #94 — the six overlay files from #92 never reached the image

**Problem.** Commit #92 added `etc/bash.bashrc`, `etc/profile.d/00-environment.sh`,
`etc/ssh/sshd_config`, `etc/sudoers.d/10-editor`, `home/ubuntu/.selected_editor`
and `root/.selected_editor` to `vps-setup/rootdir/`, but none of them were added
to `PRODUCT_COPY_FILES`. The build only ships what that list names, so the six
files never landed in `/system/etc/vps-setup/rootdir`. `vps-setup.sh` copies
`/system/etc/vps-setup/.` into the chroot and `apply.sh` walks that directory, so
the files were simply absent: `$EDITOR` stayed empty over SSH, `sudo -e` and
`sudo visudo` had no `env_keep`, and `sshd` never got the `SetEnv` block. The
whole of #92 was inert on a built image.

**Trial-Error.** Nothing failed loudly, which is why it went unnoticed. The
overlay is a directory walk, not a manifest, so a file missing from the image is
indistinguishable from a file that was never written. The check that catches it
is a set difference between `find vps-setup/rootdir -type f` and the sources
named in `PRODUCT_COPY_FILES`; it now reports nothing.

**Fix.** Six entries added to `PRODUCT_COPY_FILES`, each mirroring its source
path under `system/etc/vps-setup/rootdir/`. No `apply.sh` change was needed: the
existing mode table already resolves them correctly — `etc/sudoers.d/*` to 440
`root:root`, `home/ubuntu/*` to 644 `ubuntu:ubuntu`, everything else to 644
`root:root`.

**Verification.** All 27 `PRODUCT_COPY_FILES` sources exist; the set difference
against `vps-setup/rootdir` is empty; every destination equals
`system/etc/vps-setup/` plus its source path; the mode table resolves the six
files to 644/644/644/440/644/644 with the owners above.

**Files.** `qassa_santoni.mk`, `CHANGELOG.md`.

**Impact.** No image change until the next build. After it, #92's CLI
environment actually applies: `$EDITOR`, `$VISUAL` and `$PAGER` reach every
session type, `sudo -e` and `sudo visudo` keep them, and `sshd` carries the
`SetEnv` block for sessions that never start a shell.

### #95 — `systemctl` floods stderr, and `loginctl` cannot reach a bus

**Problem.** `hermes gateway install` as `ubuntu` printed a wall of
`ERROR:systemctl:` lines — `not found /dev/tty0`, `[Install] WantedBy unknown:
getty.target`, `not found /lib/systemd/system/dbus-broker.service` — and then
exited 1. Three separate defects sat behind that output.

`daemon-reload` validates every unit file on the image, including the stock
Ubuntu units that cannot work in a chroot, and logs each finding at ERROR.
`logg` was set to NOTE (25), so WARNING and ERROR both reached the root handler
`basicConfig` installs, which prints `LEVEL:name:message` to stderr. Real
`systemctl` is silent on success.

`loginctl` was still the stock ELF, a logind client that needs the system bus.
There is no bus here, so `loginctl enable-linger ubuntu` died with `Failed to
connect to bus: No such file or directory`, and nothing ever created
`/run/user/<uid>`. Installers probe both before they will touch `systemctl
--user`, so they gave up before reaching the shim — which needs no D-Bus at all.

`syntax_check_service` compared the raw `ExecStart=` text against `/`, so a
quoted path (`ExecStart="/path/to/bin" "arg"`, which systemd allows and hermes
writes) was reported as "Executable path is not absolute".

**Trial-Error.** The first attempt set `logg.propagate = False` for the scan.
The messages kept appearing, just without the `ERROR:systemctl:` prefix: with no
handler of its own and propagation off, the record fell through to
`logging.lastResort`, which prints the bare message to stderr. A `NullHandler`
on `logg` is what actually stops it.

**Fix.** The stderr handler is pinned to ERROR, so the scan's diagnostics stay in
`/var/log/systemctl.log` and `-v` still surfaces them. `daemon_reload_target`
stops propagating for the duration of the scan. `exec_first_word` splits the
`Exec*=` line with `shlex` before the absolute-path check. A new
`usr/bin/loginctl` answers `enable-linger`, `disable-linger`, `show-user`,
`list-users` and the session no-ops from the filesystem, and reports
`Linger=yes` because there is no logind to tear user services down. A new
`usr/local/sbin/user-session-bus.sh`, called from `boot-services.sh`, creates
`/run/user/<uid>` and starts a real `dbus-daemon --session` on
`/run/user/<uid>/bus`; `00-environment.sh` exports `XDG_RUNTIME_DIR` and
`DBUS_SESSION_BUS_ADDRESS` for login shells. The `journalctl` shim now consumes
the value of `-n`, `-u`, `-p`, `--since` and `--until` instead of treating it as
a unit name.

**Verification.** On the device, as `ubuntu` and as `root`: `systemctl
daemon-reload` and `systemctl --user daemon-reload` print 0 bytes; `status`,
`is-active`, `is-enabled`, `is-system-running` and `list-units` are unchanged;
`systemctl start no-such-unit.service` still prints `Unit ... not found.`;
`-v daemon-reload` still reports the 92 problems and `/var/log/systemctl.log`
still records them. A user unit with `ExecStart="/bin/sleep" "300"` starts and
reports active. `loginctl enable-linger ubuntu` exits 0, `show-user` reports
`Linger=yes`, and `dbus-send --session ... ListNames` gets a reply from the new
bus. `hermes gateway install` now exits 0 with "Systemd linger is enabled" and
"User service started"; `hermes gateway status` reads the unit through the shim.
The service itself reports `failed` only because a manual `hermes gateway run`
(PID 4880) already holds hermes' singleton lock — hermes says so in its own
output.

**Files.** `vps-setup/rootdir/usr/bin/systemctl`,
`vps-setup/rootdir/usr/bin/loginctl` (new),
`vps-setup/rootdir/usr/local/sbin/user-session-bus.sh` (new),
`vps-setup/rootdir/usr/local/sbin/boot-services.sh`,
`vps-setup/rootdir/usr/local/bin/journalctl`,
`vps-setup/rootdir/etc/profile.d/00-environment.sh`, `vps-setup/apply.sh`,
`qassa_santoni.mk`, `docs/VPS-SETUP.md`, `CHANGELOG.md`.

**Impact.** No image change until the next build. After it, any CLI or daemon
that manages a service — system or `--user` — sees the quiet, D-Bus-free
behaviour a stock Ubuntu server gives it, instead of a wall of chroot-specific
diagnostics.

### #96 — `is-active` called a dead service active, and `reset-failed` exited 1

**Problem.** Once a service's process died, `systemctl is-active` and `status`
kept reporting `active`: the shim trusted the `ActiveState` it had written at
start and never re-checked the recorded `MainPID`. `hermes gateway status`
therefore said the gateway was running while nothing was listening.
`systemctl reset-failed` on a unit with no failure record exited 1, which made
`hermes gateway uninstall` look like it had failed.

**Fix.** `is_active_from` and the status printer treat a unit as active only
while its `MainPID` is still alive; a dead PID is reported as `failed` and the
stale status file is cleaned. `reset-failed` returns 0 when there is nothing to
clear, matching systemd.

**Verification.** On the device, `systemctl --user is-active hermes-gateway`
reports `failed` (exit 3) once the gateway process is gone and `active` (exit 0)
while it runs. `systemctl reset-failed` on a clean unit exits 0.

**Files.** `vps-setup/rootdir/usr/bin/systemctl`.

**Impact.** Status output matches reality, so installers and health checks stop
trusting a stale `active`.

### #97 — `ExecStopPost` could not see a systemd parent, and `journalctl` read the wrong user log path

**Problem.** hermes' `cgroup_cleanup` runs as `ExecStopPost` and refuses to reap
the service's cgroup unless `/proc/<ppid>/comm` is `systemd`. Real systemd's PID 1
carries that name; here the parent is the shim, so the cleanup bailed out and the
gateway's singleton lock survived a stop. Separately, the `journalctl` shim looked
for user unit logs in `~/.config/log/`, but the shim writes them to
`~/.config/log/journal/`, so `journalctl --user -u <unit>` found nothing.

**Fix.** Lifecycle commands (`start`, `stop`, `restart`, `reload` and the
`*-restart` variants) rename the shim to `systemd` in `/proc/self/comm` before
dispatching, so a unit's `ExecStopPost` sees the parent name it would see under
real systemd. The `journalctl` shim reads `~/.config/log/journal/<unit>.log`.

**Verification.** On the device, `hermes gateway stop` releases the lock and the
next `hermes gateway install` starts the service. `journalctl -u hermes-gateway
-n 10` prints the gateway's own log lines.

**Files.** `vps-setup/rootdir/usr/bin/systemctl`,
`vps-setup/rootdir/usr/local/bin/journalctl`.

**Impact.** A stopped service is fully stopped, and user unit logs are readable.

### #98 — the gateway refused to start because `INVOCATION_ID` was missing

**Problem.** `hermes gateway install` left the service `failed`. The gateway
decides whether a service manager started it by looking for systemd's
`INVOCATION_ID`; without it, it ran the "a gateway is already running under
systemd" guard, saw its own unit, and exited 1. The shim never exported
`INVOCATION_ID`.

**Fix.** `execve_from` sets `INVOCATION_ID` to a random 32-hex value for every
process it spawns, the way systemd does for each unit invocation.

**Verification.** On the device, `hermes gateway stop` → `uninstall` → `install`
all exit 0 with empty stderr; `hermes gateway status` reports `Active: active
(running)`, `systemctl --user is-active hermes-gateway` prints `active`, and the
gateway process stays up.

**Files.** `vps-setup/rootdir/usr/bin/systemctl`.

**Impact.** Supervised daemons that check for a service manager now start
normally.

### #99 — enabled user services did not start after a reboot

**Problem.** `hermes gateway install` enabled `hermes-gateway.service` in
`~/.config/systemd/user/default.target.wants/` and started it, and the gateway
ran until the device was rebooted. After `adb reboot` the unit was `inactive
(dead)` and `hermes gateway status` reported the gateway stopped, with no error
anywhere: `boot-services.sh` ran, started the session bus, and finished.
Nothing ever started a user unit. `systemctl default` only walks the system
target, and there is no logind to start `user@<uid>.service`, so an enabled
user unit was started exactly once, by the installer, and never again.

A second problem was waiting behind it. `/run` is a plain directory on `/data`
here, not a tmpfs, so the status file a unit wrote before the reboot survived
it. Android reuses pids quickly, so the recorded `MainPID` could name an
unrelated process that was alive, and the shim would then report the unit
running and skip the start.

**Fix.** `boot-services.sh` starts every unit in
`~/.config/systemd/user/*.wants/` for every human user, as that user, with
`HOME`, `USER`, `LOGNAME`, `SHELL`, `PATH`, `XDG_RUNTIME_DIR` and
`DBUS_SESSION_BUS_ADDRESS` set, after `user-session-bus.sh` has created the
runtime directory and the bus. It also drops status files that did not come
from the current boot. The shim stamps every status file with
`/proc/sys/kernel/random/boot_id` and ignores a record written in an earlier
boot, so a reused pid can no longer make a dead unit look alive.

**Verification.** Three full `install` → `adb reboot` → check → `uninstall`
rounds on the device, each with `hermes-gateway.service` and a generic
`ExecStart=/bin/sleep 300` unit enabled. After every reboot, with no manual
`start`, `boot-services.log` recorded both units as `active`,
`systemctl --user is-active` agreed, the gateway process was in `ps`, and
`hermes gateway status` reported `active (running)`.

**Files.** `vps-setup/rootdir/usr/local/sbin/boot-services.sh`,
`vps-setup/rootdir/usr/bin/systemctl`, `docs/VPS-SETUP.md`.

**Impact.** A service a user enables survives a reboot, which is what
`loginctl enable-linger` promises and what every installer assumes.
