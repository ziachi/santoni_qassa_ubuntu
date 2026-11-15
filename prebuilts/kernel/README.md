# Prebuilt kernel — Luuvy C.4.0.eol202601

The boot image is built from this prebuilt kernel, so `kernel/xiaomi/msm8937`
does not have to be checked out to produce a ROM.

| Item | Value |
|---|---|
| File | `Image.gz-dtb` |
| Kernel | Linux 4.9.228 (arm64) |
| Source | [Luuvy-C.4.0.eol202601-santoni-Treble-2026-01-29-03.59.35.zip](https://github.com/ziachi/v0backup/releases/download/v1.4.5/Luuvy-C.4.0.eol202601-santoni-Treble-2026-01-29-03.59.35.zip) |
| Release | `ziachi/v0backup` tag `v1.4.5` |
| SHA-256 | `0aefe162f81f4cf4ce23db1bd9dd4d4ba499685b14d3fb90fe48048d1e5e86b9` |
| Size | 12 MB (gzip payload + appended DTB) |
| Config snapshot | `kernel.config` (extracted with `extract-ikconfig`) |

## How it is wired

`BoardConfig.mk` sets:

```makefile
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilts/kernel/Image.gz-dtb
```

The build copies that file into the boot image and skips the kernel build
entirely. To compile the kernel from source instead:

```bash
export SANTONI_BUILD_KERNEL=1
```

## Updating the kernel

```bash
gh release download <tag> --repo ziachi/v0backup --pattern 'Luuvy-*.zip'
unzip -o Luuvy-*.zip Image.gz-dtb
cp Image.gz-dtb prebuilts/kernel/Image.gz-dtb
sha256sum prebuilts/kernel/Image.gz-dtb   # update the table above
```

Then re-extract the config snapshot so the verification step stays accurate:

```bash
tools/verify-ikconfig.sh prebuilts/kernel/Image.gz-dtb --dump > prebuilts/kernel/kernel.config
```

## Kernel config caveats

`kernel.config` is the authoritative record of what this kernel can do. It is
verified by `tools/verify-ikconfig.sh`; see `CHANGELOG.md` for the current
pass/fail list. Notably this kernel has `CONFIG_NAMESPACES=y` and
`CONFIG_NET_NS=y` but **not** `CONFIG_PID_NS`, `CONFIG_UTS_NS`, `CONFIG_IPC_NS`,
`CONFIG_USER_NS` or `CONFIG_SYSVIPC`, so plain `chroot` works while
container runtimes (Docker/LXC/podman) and SysV-IPC services do not.
