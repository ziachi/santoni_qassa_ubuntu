# Prebuilt kernel — Luuvy C.4.0.eol202601

The boot image is built from this prebuilt kernel, so `kernel/xiaomi/msm8937`
does not have to be checked out to produce a ROM.

| Item | Value |
|---|---|
| File | `Image.gz-dtb` |
| Kernel | `Linux version 4.9.257-Luuvy-Checkmate-B.4.0.Lesion.EOL202601` (arm64) |
| Source | `ksu-Luuvy-C.4.0.eol202601-santoni-Treble-2026-11-17-05.55.07.zip` — not published on `ziachi/v0backup`, identify it by the SHA-256 below |
| SHA-256 | `3594196d447f01dcfaece128b36b9fdf8f97d68de9a147d7af1f05965e851b0f` |
| Size | 12,246,246 B (gzip payload + appended DTB) |
| Config snapshot | `kernel.config` (extracted with `extract-ikconfig`) |

## What this build adds over the 2026-01-29 build

The 2026-11-17 image is a strict superset of the 2026-01-29 image. A kallsyms
diff of the two `Image` files (53,111 vs 53,471 unique symbols) shows 384 new
symbols and 24 removed ones, and every removed symbol is either an internal
KernelSU refactor (`ksu_*_exit`, `persistent_allow_list`, `ksu_handle_devpts`,
`ksu_get_ksu_file_sid`) or an ARM64 erratum trampoline (`e843419@...`). No core
subsystem changed:

| Subsystem | 2026-01-29 | 2026-11-17 |
|---|---|---|
| `create_new_namespaces` / `copy_namespaces` | 1 / 1 | 1 / 1 |
| `selinux_*` symbols | 209 | 211 |
| `ext4_*` symbols | 438 | 438 |
| `ovl_*` symbols | 98 | 98 |
| `binder_*` symbols | 70 | 70 |
| `ksu_*` symbols | 99 | 176 |

New in this build:

- **UVC gadget** — `uvc_function_bind`, `uvcg_*`, `f_uvc_opts_*`, `uvcg_mjpeg_*`,
  `uvcg_h264_*`, `vb2_vmalloc_*`. First Luuvy build with a USB video class
  gadget.
- **UAC2 gadget** — `afunc_bind`, `afunc_unbind`, `f_uac2_opts_*`, `uac2mod_init`.
- **Newer KernelSU** — `ksu_selinux_hide`, `ksu_avc_spoof`, `ksu_sulog_capture`,
  `ksu_event_queue`, `ksu_supercall_*`, `ksu_handle_execve`.

## The embedded config is stale — do not trust it

`CONFIG_IKCONFIG` is enabled, but the author shipped the **B.3.0** config blob
inside the **B.4.0** image. `extract-ikconfig` therefore reports:

```
CONFIG_LOCALVERSION="-Luuvy-Checkmate-B.3.0"
# CONFIG_MEDIA_USB_SUPPORT is not set
# CONFIG_USB_CONFIGFS_F_UVC is not set
# CONFIG_USB_CONFIGFS_F_UAC2 is not set
```

while the version string in the same file is
`Linux version 4.9.257-Luuvy-Checkmate-B.4.0.Lesion.EOL202601`, and the symbols
listed above prove UVC and UAC2 are compiled in. The 2026-01-29 image carries
the same stale blob, so `kernel.config` is byte-identical between the two builds
and `tools/verify-ikconfig.sh` prints the same `required: 46/49 present, 3
missing` for both. Read that output as a description of the B.3.0 baseline, not
of this kernel. The three missing required options (`CONFIG_SYSVIPC`,
`CONFIG_POSIX_MQUEUE`, `CONFIG_DEVTMPFS`) are pre-existing and unrelated to this
swap; the chroot gets `/dev` from an `rbind` of the Android `/dev`, so devtmpfs
is not needed.

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
unzip -o <Luuvy-*.zip> Image.gz-dtb
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
`CONFIG_USER_NS` or `CONFIG_SYSVIPC`, so plain `chroot` works while container
runtimes (Docker/LXC/podman) and SysV-IPC services do not.

## Do not flash the author's AnyKernel3 zip

The `ksu-Luuvy-*.zip` release is an AnyKernel3 package and its `anykernel.sh`
breaks this ROM. It sets `TMPSYSROOT=/system_root` and then inserts
`import /system_root/system/etc/init/init.spectrum.rc` into
`/system_root/system/etc/init/hw/init.rc`. `/system_root` is a recovery-only
mount point, so at boot the import cannot be resolved, `ParseData()` returns
false before parsing the rest of `init.rc`, and the device bootloops. The same
script also rewrites the system sepolicy in place with no backup and drops
Spectrum's `init.spectrum.rc` (which resets zram0) into the system partition.

Only `Image.gz-dtb` from that zip is used here. The boot image is produced by
the normal Qassa build, which keeps the v33 ramdisk and cmdline untouched.
