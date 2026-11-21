# Building from source

Full build guide for `qassa_ubuntu22-ziachi-santoni.zip`. For what the image
contains and why, see [ARCHITECTURE.md](ARCHITECTURE.md).

## Prerequisites

- **OS:** Ubuntu 22.04+ (or WSL2 on Windows)
- **CPU:** 6+ cores recommended (Ryzen 5 7600 or similar)
- **RAM:** 16 GB+ (22 GB+ recommended for `-j10`)
- **Disk:** 250 GB+ free space
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

> On Ubuntu 24.04 the package names differ: `lib32ncurses5-dev` becomes
> `lib32ncurses-dev`, `libncurses5-dev` becomes `libncurses-dev`, and
> `libncurses5` does not exist (only `libncurses6`). The prebuilt clang still
> needs `libncurses.so.5`, so install the bionic debs from
> `archive.ubuntu.com/ubuntu/pool/main/n/ncurses/` and run `sudo ldconfig`.

## Step 1: Initialize ROM source

```bash
mkdir -p ~/qassa && cd ~/qassa
repo init -u https://github.com/keepQASSA/manifest.git -b Q --depth=1
repo sync -j8 --force-sync --no-tags --no-clone-bundle
```

> Initial sync takes 1-3 hours depending on internet speed. ~70 GB download.

## Step 2: Clone custom repos

```bash
cd ~/qassa

# Device tree
rm -rf device/xiaomi/santoni
git clone https://github.com/ziachi/santoni_qassa_ubuntu.git \
    device/xiaomi/santoni -b main

# Vendor blobs: the repo root holds a single santoni/ directory, so clone it
# one level up. Cloning into vendor/xiaomi/santoni doubles the path and lunch
# fails with "vendor/xiaomi/santoni/santoni-vendor.mk" does not exist.
rm -rf vendor/xiaomi
git clone https://github.com/ziachi/vendor_xiaomi_santoni_qassa.git \
    vendor/xiaomi -b qassa-ubuntu

# Kernel headers: REQUIRED, even though the boot image is prebuilt.
# Soong's generated_kernel_includes module runs
# "make -C kernel/xiaomi/msm8937 headers_install", and external/tinycompress
# plus hardware/qassa/interfaces/cryptfshw/1.0 consume the output. Without
# this checkout the build stops at 1% with
# "make: *** kernel/xiaomi/msm8937: No such file or directory. Stop."
# The boot image still comes from prebuilts/kernel/Image.gz-dtb
# (Luuvy C.4.0), so nothing built here reaches the device.
rm -rf kernel/xiaomi/msm8937
git clone https://github.com/ziachi/kernel_xiaomi_msm8937_qassa.git \
    kernel/xiaomi/msm8937 -b qassa-ubuntu

# Framework patches (on top of synced frameworks/base)
cd frameworks/base
git remote add ziachi https://github.com/ziachi/frameworks_base_qassa.git
git fetch ziachi
git checkout ziachi/qassa-10
cd ~/qassa

# Build system patch: OTA banner prints build details instead of a joke.
cd build/make
git remote add ziachi https://github.com/ziachi/build_make_qassa.git
git fetch ziachi
git checkout ziachi/qassa-ubuntu
cd ~/qassa

# Wi-Fi shell command backport: cmd wifi connect-network / scan /
# list-scan-results / disconnect / status. vps-setup's `wifi connect` needs it.
cd frameworks/opt/net/wifi
git remote add ziachi https://github.com/ziachi/frameworks_opt_net_wifi_qassa.git
git fetch ziachi
git checkout ziachi/qassa-ubuntu
cd ~/qassa

# Vendor config: brand the build as ubuntu22/ziachi.
cd vendor/qassa
git remote add ziachi https://github.com/ziachi/vendor_qassa.git
git fetch ziachi
git checkout ziachi/qassa-ubuntu
cd ~/qassa
```

### Kernel toolchain: `clang-proton`

The kernel build needs `prebuilts/clang/host/linux-x86/clang-proton`, which the
keepQASSA manifest does not provide. It is Proton clang 13.0.0 from
[`kdrag0n/proton-clang`](https://github.com/kdrag0n/proton-clang) at commit
`9fb011b` ("Update to 20210522 build"):

```bash
cd ~/qassa/prebuilts/clang/host/linux-x86
git clone https://github.com/kdrag0n/proton-clang.git clang-proton
cd clang-proton && git checkout 9fb011b
```

`clang-proton/bin/clang --version` should print
`Proton clang version 13.0.0`. If the build complains about a missing
`zyc_clang`, point `TARGET_KERNEL_CLANG_VERSION` at `clang-proton` (or at
`clang-r353983c1` if you prefer the AOSP prebuilt).

## Step 3: Fix webview (build fails without this)

```bash
cd ~/qassa/external/chromium-webview
git lfs pull
# Verify webview.apk is ~40MB+, NOT a tiny LFS pointer file:
ls -lh prebuilt/x86_64/webview.apk
cd ~/qassa
```

> `external/chromium-webview` is split into five sub-repos by the keepQASSA
> manifest. Run `git lfs pull` inside each `prebuilt/*`, not in the parent.

## Step 4: Setup signing keys

Generate your own keys if you do not have the maintainer's keys:

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

## Step 5: Build

```bash
cd ~/qassa
source build/envsetup.sh
lunch qassa_santoni-userdebug
mka qassa -j$(nproc)
```

> First build: ~4-8 hours (6-core). Subsequent builds with ccache: ~1-3 hours.
>
> Output: `out/target/product/santoni/qassa_ubuntu22-ziachi-santoni.zip`

## Step 6: Flash

```bash
# Boot into TWRP recovery, then sideload:
adb sideload out/target/product/santoni/qassa_ubuntu22-ziachi-santoni.zip

# OR copy ZIP to device and flash from TWRP file manager
```

---

## Cheat sheet

| Command | Purpose | Time |
|---------|---------|------|
| `source build/envsetup.sh` | Load build environment | instant |
| `lunch qassa_santoni-userdebug` | Select device/variant | instant |
| `mka qassa -j10` | Full build (10 threads) | 1-8 hr |
| `mka installclean` | Clean product output, keep cache | instant |
| `mka clean` | Full clean (delete entire `out/`) | instant |
| `rm -rf out/soong/.bootstrap` | Fix Soong cache errors | instant |

### Background build with logging

```bash
nohup mka qassa -j10 > /tmp/build.log 2>&1 &
tail -f /tmp/build.log                  # monitor
grep -i "error\|fail" /tmp/build.log    # check errors
```

> `lunch` must not be piped. `lunch ... | tail -3` runs it in a subshell, so
> `TARGET_PRODUCT` never reaches the parent shell, `VendorVars` in
> `out/soong/soong.variables` ends up empty, and Soong dies with
> `unknown variable '$(PATH_OVERRIDE_SOONG)'`. Redirect instead:
> `lunch ... >/dev/null 2>&1`.

---

## Common build errors

| Problem | Fix |
|---------|-----|
| webview.apk build error (tiny file) | `cd external/chromium-webview && git lfs pull` |
| Soong build error after `.mk` change | `rm -rf out/soong/.bootstrap` |
| Disk full during build | `mka installclean` or `mka clean` |
| Jack server OOM | `export JACK_SERVER_VM_ARGUMENTS="-Xmx4g"` |
| `clang.real: error while loading shared libraries: libncurses.so.5` | install the bionic `libncurses5` / `libtinfo5` debs, then `sudo ldconfig` |
| `ccache: error: Could not find compiler "clang" in PATH` | `TARGET_KERNEL_CLANG_VERSION` points at a `zyc_clang` that does not exist; use `clang-r353983c1` |
| `MODULE.TARGET.ETC.init.ubuntu.rc already defined` | `init.ubuntu.rc` / `init.ubuntu.sh` are already defined in `rootdir/Android.mk`; do not add a second module |

Every fixed issue is written up in [CHANGELOG.md](../CHANGELOG.md) with its
Problem / Fix / Files / Impact. Runtime symptoms on a flashed device are in
[VPS-SETUP.md](VPS-SETUP.md#troubleshooting).
