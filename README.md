# Qassa ROM — Xiaomi Redmi 4X (santoni)

> **keepQASSA Sisu v2.4_0.s** (Android 10) — Unofficial build for santoni.
> Vanilla, custom signed, with XiaomiAddon & GCam preinstalled.

> im just rebuild the rom the source devicetree it self already clean. 

---

## Quick Reference

| Key | Value |
|-----|-------|
| **ROM** | keepQASSA Sisu v2.4_0.s (Android 10) |
| **Device** | Xiaomi Redmi 4X (santoni) |
| **SoC** | Qualcomm MSM8937 (Snapdragon 435) |
| **Lunch** | `qassa_santoni-userdebug` |
| **Build command** | `mka qassa -j$(nproc)` |
| **Build type** | UNOFFICIAL |
| **Signed with** | `vendor/ziachi-keys/releasekey` |
| **SELinux** | Permissive (headless VPS build, see Hard Rule #2) |
| **Kernel** | Luuvy C.4.0.eol202601 — prebuilt, Linux 4.9.228 arm64 |
| **Manifest** | `https://github.com/keepQASSA/manifest.git` branch `Q` |
| **Maintainer** | [@kalomakan](https://t.me/kalomakan) / [ziachi](https://github.com/ziachi) |

---

## Repository Map

All custom repos for this ROM. Clone each into the matching path inside the Qassa source tree.

```
~/qassa/                                    <- ROM source root
|-- .repo/                                  <- repo tool metadata
|-- device/xiaomi/santoni/                  <- THIS REPO (device tree)
|-- vendor/xiaomi/santoni/                  <- Vendor blobs
|-- kernel/xiaomi/msm8937/                  <- Kernel source (OPTIONAL, see below)
|-- frameworks/base/                        <- Framework patches (custom)
|-- vendor/qassa/                           <- ROM vendor config (from repo sync)
|-- vendor/ziachi-keys/                     <- Signing keys (NOT on GitHub)
|-- build/                                  <- Build system (from repo sync)
|-- external/chromium-webview/              <- Webview (needs git-lfs pull!)
`-- out/                                    <- Build output (~200GB)
```

| Repo | GitHub URL | Branch | Clone Path |
|------|-----------|--------|------------|
| **Device tree** | [santoni_qassa_ubuntu](https://github.com/ziachi/santoni_qassa_ubuntu) | `main` | `device/xiaomi/santoni` |
| **Vendor blobs** | [vendor_xiaomi_santoni_qassa](https://github.com/ziachi/vendor_xiaomi_santoni_qassa) | `10.0` | `vendor/xiaomi/santoni` |
| **Kernel** | [kernel_xiaomi_msm8937_qassa](https://github.com/ziachi/kernel_xiaomi_msm8937_qassa) | `13` | `kernel/xiaomi/msm8937` |
| **Framework** | [frameworks_base_qassa](https://github.com/ziachi/frameworks_base_qassa) | `qassa-10` | `frameworks/base` |

> **Signing keys** (`vendor/ziachi-keys`) are NOT on GitHub. Generate your own or ask the maintainer.

---

## Full Setup Guide (from scratch on a new VPS)

### Prerequisites

- **OS:** Ubuntu 22.04+ (or WSL2 on Windows)
- **CPU:** 6+ cores recommended (Ryzen 5 7600 or similar)
- **RAM:** 16GB+ (22GB+ recommended for -j10)
- **Disk:** 250GB+ free space
- **Packages:** OpenJDK 8, Python 3, git, git-lfs, ccache, repo

```bash
# Install build dependencies (Ubuntu 22.04)
sudo apt update && sudo apt install -y \
    bc bison build-essential ccache curl flex g++-multilib gcc-multilib \
    git git-lfs gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev \
    lib32z1-dev liblz4-tool libncurses5 libncurses5-dev libsdl1.2-dev \
    libssl-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool \
    squashfs-tools xsltproc zip zlib1g-dev openjdk-8-jdk python3

# Install repo tool
mkdir -p ~/bin
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo
echo 'export PATH=~/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# Setup ccache (optional but recommended)
echo 'export USE_CCACHE=1' >> ~/.bashrc
echo 'export CCACHE_DIR=~/.ccache' >> ~/.bashrc
source ~/.bashrc
ccache -M 40G
```

### Step 1: Initialize ROM Source

```bash
mkdir -p ~/qassa && cd ~/qassa
repo init -u https://github.com/keepQASSA/manifest.git -b Q --depth=1
repo sync -j8 --force-sync --no-tags --no-clone-bundle
```

> Initial sync takes 1-3 hours depending on internet speed. ~70GB download.

### Step 2: Clone Custom Repos

```bash
cd ~/qassa

# Device tree
rm -rf device/xiaomi/santoni
git clone https://github.com/ziachi/santoni_qassa_ubuntu.git \
    device/xiaomi/santoni -b main

# Vendor blobs
rm -rf vendor/xiaomi/santoni
git clone https://github.com/ziachi/vendor_xiaomi_santoni_qassa.git \
    vendor/xiaomi/santoni -b 10.0

# Kernel — OPTIONAL
# The boot image is built from prebuilts/kernel/Image.gz-dtb (Luuvy C.4.0),
# so this clone is only needed if you want to compile the kernel yourself.
# If you do, also export SANTONI_BUILD_KERNEL=1 before building.
# rm -rf kernel/xiaomi/msm8937
# git clone https://github.com/ziachi/kernel_xiaomi_msm8937_qassa.git \
#     kernel/xiaomi/msm8937 -b 13

# Framework patches (on top of synced frameworks/base)
cd frameworks/base
git remote add ziachi https://github.com/ziachi/frameworks_base_qassa.git
git fetch ziachi
git checkout ziachi/qassa-10
cd ~/qassa
```

### Step 3: Fix Webview (IMPORTANT - build will fail without this)

```bash
cd ~/qassa/external/chromium-webview
git lfs pull
# Verify webview.apk is ~40MB+, NOT a tiny LFS pointer file:
ls -lh prebuilt/x86_64/webview.apk
cd ~/qassa
```

### Step 4: Setup Signing Keys

Generate your own keys if you don't have the maintainer's keys:

```bash
mkdir -p ~/qassa/vendor/ziachi-keys
cd ~/qassa/vendor/ziachi-keys
for key in releasekey platform shared media networkstack testkey; do
    subject="/C=ID/ST=Java/L=Jakarta/O=Qassa/OU=Android/CN=${key}"
    openssl genrsa 2048 2>/dev/null | \
        openssl pkcs8 -topk8 -inform PEM -outform DER -nocrypt -out ${key}.pk8
    openssl req -new -x509 -sha256 -key <(openssl rsa -inform DER -in ${key}.pk8 2>/dev/null) \
        -out ${key}.x509.pem -days 10000 -subj "${subject}" 2>/dev/null
done
cd ~/qassa
```

### Step 5: Build

```bash
cd ~/qassa
source build/envsetup.sh
lunch qassa_santoni-userdebug
mka qassa -j$(nproc)
```

> First build: ~4-8 hours (6-core). Subsequent builds with ccache: ~1-3 hours.
>
> Output: `out/target/product/santoni/qassa_Sisu-*.zip`

### Step 6: Flash

```bash
# Boot into TWRP recovery, then sideload:
adb sideload out/target/product/santoni/qassa_Sisu-*.zip

# OR copy ZIP to device and flash from TWRP file manager
```

---

## Build Commands Cheat Sheet

| Command | Purpose | Time |
|---------|---------|------|
| `source build/envsetup.sh` | Load build environment | instant |
| `lunch qassa_santoni-userdebug` | Select device/variant | instant |
| `mka qassa -j10` | Full build (10 threads) | 1-8 hr |
| `mka installclean` | Clean product output, keep cache | instant |
| `mka clean` | Full clean (delete entire out/) | instant |
| `rm -rf out/soong/.bootstrap` | Fix Soong cache errors | instant |

### Background build with logging:
```bash
nohup mka qassa -j10 > /tmp/build.log 2>&1 &
tail -f /tmp/build.log          # monitor
grep -i "error\|fail" /tmp/build.log  # check errors
```

---

## What's Included

### Prebuilt Apps
| App | Path | Description |
|-----|------|-------------|
| GCam | `GCam/Camera.apk` | Google Camera |
| XiaomiAddon | `XiaomiAddon/` | KCal display, USB Fast Charge, QS tiles |

### Device Features
- ADB enabled by default (headless/automation access)
- Custom signed with releasekey
- SELinux permissive (headless VPS build)
- Maintainer info embedded in build.prop

---

## Headless VPS Mode

The ROM is built as a headless server: no Android UI, no display server, no
boot animation. Everything is driven over ADB.

### Quick start

From a freshly flashed device to an SSH session, in order:

```bash
# 1. USB — no RSA prompt, adbd is already root
adb devices
adb shell id                      # uid=0(root)

# 2. USB — join Wi-Fi and install Ubuntu 22.04 in one command
adb shell vps-setup "MyWiFi" "MyWiFiPassword"

# 3. note the IP the script prints, then move to Wi-Fi ADB
adb connect 192.168.1.50:5555
echo 'santoniadmin' | adb -s 192.168.1.50:5555 shell id

# 4. inside Ubuntu — give root a password (vps-setup already installed sshd)
passwd root                       # sshd refuses an empty root password

# 5. from any machine on the LAN
ssh root@192.168.1.50
```

Steps 1–2 need the cable. After step 2 the device is self-sufficient: it
rejoins Wi-Fi and starts Ubuntu on every boot, so steps 3–5 work over the
network from then on.

| Change | Where |
|---|---|
| `androidboot.selinux=permissive` | `BoardConfig.mk` (`BOARD_KERNEL_CMDLINE`) |
| `SystemUI`, `Launcher3`, `Launcher3QuickStep`, `GCam`, `XiaomiAddon` dropped | `prebuilts/Android.mk` (`LOCAL_OVERRIDES_PACKAGES` on `RemovePackages`) |
| `service surfaceflinger` kept enabled | `rootdir/init.target.rc` |
| `service bootanim` kept enabled, `debug.sf.nobootanimation=1` | `rootdir/init.target.rc`, `qassa_santoni.mk` |
| ADB over USB without the RSA prompt, ADB over Wi-Fi on 5555 | `qassa_santoni.mk` (`PRODUCT_PROPERTY_OVERRIDES`) |

Both services are redefined with the init `override` keyword, which replaces the
AOSP definition from `system/core/rootdir/init.rc`. `init.target.rc` is imported
from `init.qcom.rc`, which `init.rc` imports after its own service definitions,
so the override lands in the right order.

> **SurfaceFlinger stays enabled on purpose.** An earlier revision disabled it
> to save RAM. That is not safe: `system_server` binds to the display path and
> the camera HAL allocates graphic buffers through it, so a missing
> SurfaceFlinger is a bootloop risk, not a saving. The headless part of this
> build comes from the missing UI APKs, not from a missing display server.
>
> `bootanim` also stays enabled, but `debug.sf.nobootanimation=1` makes it exit
> immediately, so nothing is drawn and init still gets its
> `service.bootanim.exit` handshake.

### Why the `PRODUCT_PACKAGES` filter-out is gone

`qassa_santoni.mk` used to strip the UI with
`PRODUCT_PACKAGES := $(filter-out SystemUI Launcher3 ...)`. That never worked.
`inherit-product` is deferred in this tree (`build/make/core/product.mk:378`):
it appends a `$(INHERIT_TAG)<path>` marker instead of including the makefile, so
at that point the variable holds only markers and the filter matches nothing.
`get_build_var PRODUCT_PACKAGES` still lists `SystemUI`, `Launcher3`,
`Launcher3QuickStep` and `XiaomiAddon` for that reason.

The APKs are removed by `LOCAL_OVERRIDES_PACKAGES` on the `RemovePackages` stub
in `prebuilts/Android.mk`. `build/make/core/main.mk:1110-1112` filters the
overridden names out of `PRODUCTS.<mk>.PRODUCT_PACKAGES` before install, so they
never reach the image. `PRODUCT_PACKAGES_REMOVE` does not exist in this tree.

### ADB Access

| Property | Value | Effect |
|---|---|---|
| `persist.sys.usb.config` | `adb` | USB gadget exposes adb only (no MTP) |
| `persist.service.adb.enable` | `1` | adbd starts at boot |
| `ro.adb.secure` | `0` | no RSA authorisation prompt |
| `ro.secure` | `0` | adbd runs as root |
| `ro.debuggable` | `1` | debuggable build |
| `service.adb.tcp.port` | `5555` | adbd also listens on TCP 5555 |

```bash
# Over USB — no on-screen confirmation needed
adb devices
adb shell

# Over Wi-Fi, once the device is on the network
adb connect 192.168.1.50:5555
adb -s 192.168.1.50:5555 shell
```

> **Debug-phase access only.** `ro.adb.secure=0`, `ro.secure=0` and ADB over
> Wi-Fi on 5555 without authentication mean anyone who can reach port 5555 is
> root. That is deliberate while the device sits on the bench on a trusted
> LAN, and it is not a shipping configuration. `ubuntu-enter` also runs with
> `DEBUG_NO_PASSWORD=1`, which removes the Wi-Fi password gate entirely.

### Login shell: `ubuntu-enter`

`persist.sys.adb.shell=/system/bin/ubuntu-enter` makes every adb session go
through a dual-auth wrapper:

| Connection | Behaviour |
|---|---|
| USB attached (`/sys/class/android_usb/android0/state` = `CONFIGURED`) | straight in, no password |
| Wi-Fi only (`DISCONNECTED`) | `ADB Wi-Fi Password:` prompt, 3 tries, then the session is closed |
| `DEBUG_NO_PASSWORD=1` (current) | the prompt is skipped on every transport — debug phase only |
| Ubuntu installed (`/data/ubuntu/bin/bash`) | `chroot /data/ubuntu /bin/bash -l` as root |
| Ubuntu not installed | drops to `/system/bin/sh` with a hint to run `vps-setup` |

Default password: **`santoniadmin`**. It is read from `/data/adb_wifi_pass`,
which `vps-setup` and `init.ubuntu.sh` create on first boot as `0600 root:root`:

```bash
# change it (over USB, no password needed)
adb shell "echo 'my-new-password' > /data/adb_wifi_pass && chmod 600 /data/adb_wifi_pass"
```

Scripted access over Wi-Fi is gated too, so feed the password on stdin:

```bash
echo 'santoniadmin' | adb -s 192.168.1.50:5555 shell getprop ro.product.model
```

> **Requires the adb patch.** AOSP hard-codes the adb shell to
> `/system/bin/sh`; `persist.sys.adb.shell` is only honoured after
> `patches/apply-adb-shell-override.py` has been applied to the synced source.
> See [patches/README.md](patches/README.md).

> **Security:** port 5555 gives a root shell to anyone who can reach it. The
> password gate is the only thing in front of it — firewall 5555 to trusted
> networks if the device is ever exposed.

### Changing the ADB Wi-Fi password

The password lives in `/data/adb_wifi_pass` (mode 600, owner `root:root`). Change it over USB,
where no password is required:

```bash
adb shell "echo 'my-new-password' > /data/adb_wifi_pass && chmod 600 /data/adb_wifi_pass"
```

The file is read on every Wi-Fi session, so no reboot is needed. Check that the
new value is accepted and the old one is not:

```bash
echo 'my-new-password' | adb -s 192.168.1.50:5555 shell id   # works
echo 'santoniadmin'    | adb -s 192.168.1.50:5555 shell id   # 3 tries, then closed
```

Forgot it? Delete the file over USB and the default `santoniadmin` comes back.
`init.ubuntu.sh` recreates it with `0600 root:root` on the next boot:

```bash
adb shell rm -f /data/adb_wifi_pass
```

### First setup (USB)

Flash the ROM, plug in USB, then run one command:

```bash
adb shell vps-setup "MyWiFi" "MyWiFiPassword"
```

It does seven things:

1. `svc wifi enable`, wait for `wpa_supplicant`, then
   `cmd wifi connect-network <SSID> wpa2 <PASSWORD>`
2. wait up to 30s for an IPv4 address on `wlan0`
3. download `ubuntu-base-22.04-base-arm64.tar.gz` to `/data/local/tmp/`
4. `tar -xzf` it into `/data/ubuntu` and create `dev`, `dev/pts`, `proc`,
   `sys`, `tmp`, `run`
5. write `/etc/resolv.conf` (8.8.8.8, 1.1.1.1) and an `apt` `sources.list` for
   `ports.ubuntu.com`
6. create `/data/adb_wifi_pass` with `santoniadmin` if it is missing, then
   `chmod 600` and `chown 0:0`
7. mount `/dev`, `/proc` and `/sys` inside the chroot, write a `resolv.conf`,
   then `apt update && apt install -y openssh-server` and unmount again

If the device has no `curl` and no `wget`, the script prints the `adb push`
recipe instead of failing silently:

```bash
curl -LO https://cdimage.ubuntu.com/ubuntu-base/releases/22.04/release/ubuntu-base-22.04-base-arm64.tar.gz
adb push ubuntu-base-22.04-base-arm64.tar.gz /data/local/tmp/ubuntu-base.tar.gz
adb shell vps-setup "MyWiFi" "MyWiFiPassword"
```

After that, `adb shell` lands in Ubuntu as root with `openssh-server` already
installed. The only thing left is a root password, because `sshd` refuses an
empty one:

```bash
passwd root
```

### Boot behaviour

`init.ubuntu.rc` starts `vps-boot` on `sys.boot_completed=1`, which runs
`/vendor/bin/init.ubuntu.sh`:

| Step | What it does |
|---|---|
| Wake lock | `echo vps_server_lock > /sys/power/wake_lock` — the SoC never suspends |
| ZRAM | checks `/sys/block/zram0/disksize`; resizes to 2147483648 bytes and `mkswap` + `swapon` when it differs |
| Password file | creates `/data/adb_wifi_pass` with `santoniadmin` when missing, then `chmod 600` + `chown 0:0` |
| Mounts | `rbind` `/dev` + `make-rslave`, devpts only when the rbind did not bring it, then `/proc` and `/sys` |
| sshd prerequisites | creates `/data/ubuntu/tmp` (1777) and `/data/ubuntu/run/sshd` (0755) |
| SSH | `chroot /data/ubuntu /usr/sbin/service ssh start` |

`/dev` is rbind-mounted rather than bind-mounted because ueventd keeps creating
nodes after boot; a plain bind would freeze the chroot's view at the moment of
the mount. `--make-rslave` keeps an unmount inside the chroot from propagating
back into Android's `/dev`. The mount syntax is probed once at boot: toybox
takes `-o rbind` / `-o rslave`, util-linux takes `--rbind` / `--make-rslave`,
and busybox is used when the built-in mount understands neither.

`fstab.qcom` already asks for `zramsize=2147483648`, so the ZRAM step is
normally just a check — it exists for a device that booted with the old 1 GB
fstab. Everything logs under the `vps-boot:` tag:

```bash
adb logcat -s vps-boot
```

### Hardware bridges (disabled)

Three bridge skeletons live in the device tree. Each ships as
`Android.bp.disabled` with `enabled: false`, so Soong never parses the directory
and the build is unchanged until the file is renamed to `Android.bp`.

#### `webcam-bridge` — camera

Camera2 NDK to MJPEG. `/dev/video*` on MSM8937 is not UVC, so the NDK is the
only entry point. Missing: JPEG encode, the repeating request, and the MJPEG
server on `127.0.0.1:8080`. Run it as `camera`, not as root from the chroot —
`cameraserver` rejects clients outside the `camera` group.

### Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `vps-setup: no IP on wlan0 after 30s` | wrong SSID or password, or a 5 GHz-only AP | re-run with the exact SSID — santoni is 2.4 GHz only |
| `vps-setup: no downloader on the device` | no `curl` and no `wget` | use the `adb push` recipe the script prints |
| `adb connect` → `connection refused` | adbd not listening yet, or wrong IP | `adb shell getprop service.adb.tcp.port` must be `5555`; read the IP with `adb shell ip -4 addr show wlan0` |
| Wi-Fi ADB asks for a password you do not know | `/data/adb_wifi_pass` was changed | over USB: `adb shell cat /data/adb_wifi_pass`, or delete the file to fall back to `santoniadmin` |
| `adb shell` drops to `/system/bin/sh` | Ubuntu is not installed | run `vps-setup` |
| `vps-boot: openssh-server not installed` in logcat | sshd missing | `apt install -y openssh-server` inside the chroot |
| `vps-boot: could not mount /proc` | `/data/ubuntu` is missing or not a rootfs | re-run `vps-setup` |
| `system_server` crash-loops after boot | SurfaceFlinger is disabled | see the note above — drop the `surfaceflinger` override |

## Kernel Capability Check

The prebuilt kernel is verified against the options the Ubuntu chroot needs:

```bash
tools/verify-ikconfig.sh prebuilts/kernel/Image.gz-dtb
```

It reads the config straight out of the image (no kernel source needed), prints
a per-option table and exits non-zero if a required option is missing.

Current result for Luuvy C.4.0.eol202601: **46/49 required present**.

| Missing (required) | Consequence |
|---|---|
| `CONFIG_SYSVIPC` | PostgreSQL / Redis and other SysV-IPC daemons will not start |
| `CONFIG_POSIX_MQUEUE` | No POSIX message queues |
| `CONFIG_DEVTMPFS` | `/dev` must be bind-mounted from Android into the chroot |

Also absent, container-only: `CONFIG_PID_NS`, `CONFIG_UTS_NS`, `CONFIG_IPC_NS`,
`CONFIG_USER_NS`, `CONFIG_MEMCG`, `CONFIG_VETH`, `CONFIG_SQUASHFS`,
`CONFIG_BINFMT_MISC`. **Docker / LXC / podman cannot run on this kernel.**
Plain `chroot` is fully supported.

## Known Issues & Fixes

| # | Issue | Status | Fix |
|---|-------|--------|-----|
| 6 | allocator@3.0 bootloop (MSM8937) | Fixed | Remove `<version>3.0</version>` from manifest.xml |
| 8 | Privapp-permissions bootloop | Fixed | Added whitelist XML for all privapps |
| 10 | Calendar crash (startService from bg) | Fixed | Debloated via Android.bp overlay |
| 11 | GameSpace crash | Fixed | Debloated via Android.bp overlay |
| 15 | SELinux memtrack/libutils denials | Fixed | dontaudit + allow rules |
| 15 | Vibrator haptic type 2 error | Fixed | Overlay `config_enableHapticTextHandle=false` |
| 17 | Dolby remnants in device tree | Fixed | Removed all Dolby refs |
| 22 | Android Override integrated | Fixed | Removed all Override hooks + app |

### Common Build Errors

| Problem | Fix |
|---------|-----|
| webview.apk build error (tiny file) | `cd external/chromium-webview && git lfs pull` |
| Soong build error after .mk change | `rm -rf out/soong/.bootstrap` |
| Disk full during build | `mka installclean` or `mka clean` |
| Jack server OOM | `export JACK_SERVER_VM_ARGUMENTS="-Xmx4g"` |

---

## Hard Rules

> **These rules MUST be followed by any human or AI agent working on this project.**

| # | Rule |
|---|------|
| 1 | **NEVER `git push --force`** — History is sacred, no exceptions |
| 2 | **SELinux is Permissive for the headless VPS build** — `androidboot.selinux=permissive` in `BoardConfig.mk`. This supersedes the old "always Enforcing" rule; the Ubuntu chroot needs it. Revert to Enforcing only for a phone build. |
| 3 | **1 fix = 1 commit** — Format: `[vN] santoni: description (#N)` |
| 4 | **Commit body must include:** Problem / Fix / Files / Impact |
| 5 | **Don't mix Matrixx patterns with Qassa** — Different ROM, different codebase |
| 6 | **Don't auto-build** — Wait for explicit "gas build" from maintainer |
| 7 | **README + CHANGELOG must update** with every commit+push |
| 8 | **Monitor builds** with 5-minute poll intervals |
| 9 | **GPG sign all commits** — Ask maintainer for key setup |

---

## For AI Agents

If you are an AI agent (Viktor, Cursor, Copilot, etc.) continuing work on this project, read this section carefully.

### Project Context
- This is **keepQASSA** (Android 10 / Q), NOT LineageOS, NOT Matrixx
- Build system: standard AOSP Make (`mka`)
- ROM manifest: `https://github.com/keepQASSA/manifest.git` branch `Q`
- Source tree synced with `repo sync --depth=1` (shallow clones)
- Device codename: `santoni` (Xiaomi Redmi 4X)

### Build Environment Setup
```bash
cd ~/qassa
source build/envsetup.sh
lunch qassa_santoni-userdebug
mka qassa -j$(nproc)
```

### Common Tasks

| Task | How |
|------|-----|
| Add prebuilt app | Put APK + Android.mk in `device/xiaomi/santoni/<AppName>/`, add to device.mk PRODUCT_PACKAGES |
| Change build prop | Edit `system.prop` or `qassa_santoni.mk` PRODUCT_PROPERTY_OVERRIDES |
| Fix SELinux denial | Add rules to `sepolicy/vendor/`, NEVER set permissive |
| Debloat system app | Add entry to `debloat/Android.bp` |
| Add overlay | Put XML in `overlay/` or `overlay-lineage/` |
| Update kernel config | Edit defconfig in `kernel/xiaomi/msm8937` |

### Disk Management
The `out/` directory grows to 200GB+. Always check `df -h` before building.
- `mka installclean` — frees ~10-15GB, keeps compiled objects, rebuild ~1-3hr
- `mka clean` — frees everything, full rebuild ~4-8hr

### GPG Signing
All commits must be GPG signed. Ask the maintainer for the signing key ID, then:
```bash
git config --global user.signingkey <KEY_ID>
git config --global commit.gpgsign true
```

### Commit Workflow
1. Make changes
2. Test build compiles (or get maintainer approval to skip)
3. Commit with format: `[vN] santoni: description (#N)`
4. Include in commit body: Problem / Fix / Files / Impact
5. Update README.md and CHANGELOG.md
6. Push (never force push)

---

## Commit History

See [CHANGELOG.md](CHANGELOG.md) for full history.

| # | Version | Hash | Change |
|---|---------|------|--------|
| 23 | v20 | 2e0ceda | Add Spectrum kernel profile to XiaomiAddon |
| 22 | v19 | 727c886 | Fix PinnerService path for flattened APEX |
| 21 | v18 | c687798 | Fix PinnerService APEX path for Android 10 |
| 20 | v17 | cfbf6ba | Complete Dolby removal from device tree |
| 19 | v16 | 3f69e6d | Update README — comprehensive setup guide |
| 18 | v16 | 32160a3 | Remove Android Override integration |
| 17 | v15 | df886c1 | Fix README — separate device tree vs override bugs |
| 16 | v15 | fc1ceaa | Update README + CHANGELOG |
| 15 | v15 | ae7f47a | Build deps fix + device info overlay |
| 14 | v15 | ac19f79 | Add Spectrum kernel manager + OverrideSettings SEPolicy |
| 13 | v15 | aa0fc5d | Remove Dolby from device tree |
| 12 | v15 | 60526f3 | SEPolicy cleanup — remove non-existent types |
| 11 | - | 0a1ca39 | Fix 6 bugs from V14 logcat analysis |
| 9 | - | d3098f2 | Add bug analysis docs + update README |
| 8 | - | 4032e6f | Fix privapp-permissions bootloop |
| 6 | - | 03332ae | Fix allocator@3.0 bootloop + update docs |

---

## Credits

- [omansh-krishn](https://github.com/omansh-krishn) — original keepQASSA device tree for santoni
- [ziachi](https://github.com/ziachi) — santoni port, customizations, bug fixes
