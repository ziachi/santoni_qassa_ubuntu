# Documentation

Deep technical reference for **santoni_qassa_ubuntu** — a Xiaomi Redmi 4X
(`santoni`) running keepQASSA Sisu v2.4_0.s (Android 10 / Q) reduced to a
headless Ubuntu 22.04 arm64 server.

The [project README](../README.md) is the quick start: what the image is, the
default credentials, and the four commands that take a freshly flashed device to
an SSH session. This folder is the long form — why the boot sequence is ordered
the way it is, what `vps-setup` does step by step, and how to build the ZIP
yourself.

## Contents

| File | What it covers |
|---|---|
| [ARCHITECTURE.md](ARCHITECTURE.md) | How the image is assembled: the boot order driven by `init.ubuntu.sh`, why `SurfaceFlinger` stays enabled even though nothing draws, the chroot mounts (`rbind` + `make-rslave`, devpts, `/proc`, `/sys`), the ZRAM resize, the internal `wifi` helper, the hardware bridges (`webcam`, `audio`, `sensor`), and the 46/49 kernel option check against the prebuilt Luuvy kernel. |
| [VPS-SETUP.md](VPS-SETUP.md) | Operating the device: the `vps-setup` workflow from USB to SSH, managing the ADB Wi-Fi password, the chroot network routing that makes `apt` work, and the full 20-scenario troubleshooting table. |
| [BUILD.md](BUILD.md) | Building the ROM from source on the keepQASSA `Q` manifest, the Git LFS WebView fix the build fails without, generating your own signing keys, the build cheat sheet, and the common build errors. |

## Supporting material

| Path | What it is |
|---|---|
| [bug-analysis/](bug-analysis/) | Post-mortems for the two bootloops that were traced to their root cause: `allocator@3.0` and `privapp-permissions`. |
| [screenshots/](screenshots/) | The proof images used in the README: SSH into the chroot, and `htop` on an idle device. |

## Where to start

- **First time on the device** — [Quick Start](../README.md#quick-start), then [VPS-SETUP.md](VPS-SETUP.md).
- **Why the image is built this way** — [ARCHITECTURE.md](ARCHITECTURE.md).
- **Building the ZIP yourself** — [BUILD.md](BUILD.md).
- **Before changing anything** — the hard rules in [AGENTS.md](../AGENTS.md) and the history in [CHANGELOG.md](../CHANGELOG.md).

Back to the [project README](../README.md).
