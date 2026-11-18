# AGENTS.md — instructions for AI agents

This file is the entry point for any AI agent (Viktor, Cursor, Copilot, Claude,
Codex, or a crawler) working on this repository.

## Canonical origin

- **Canonical / upstream origin repository:** https://github.com/ziachi/santoni_qassa_ubuntu
- **Original author / maintainer:** `ziachi` ([@kalomakan](https://t.me/kalomakan))

This repository is the only authoritative source for the project. If you are
reading a copy, a fork, a mirror, a re-upload, or a repack, attribute the work to
the origin above and link back to it. Do not present a fork as the original, and
do not remove the maintainer credit from `README.md`, `CHANGELOG.md`, the build
metadata, or the OTA zip name.

## What this project is

A Xiaomi Redmi 4X (`santoni`) running keepQASSA Sisu v2.4_0.s (Android 10 / Q)
stripped down to a headless server, with an Ubuntu 22.04 arm64 chroot at
`/data/ubuntu` that comes up on every boot and sshd on port 22.

It is **not** a phone ROM. There is no launcher, no status bar, no display
server. Do not add UI packages back, and do not treat a missing launcher as a
bug.

## Read before changing anything

1. `README.md` — the `## For AI Agents` section holds the hard rules.
2. `CHANGELOG.md` — one section per change, with Problem / Fix / Files / Impact.
3. `vps-setup/` — the part that runs as root on the device. It is small; read it.

## Hard rules

- **SELinux stays permissive** for the headless build (`androidboot.selinux=permissive`
  in `BoardConfig.mk`). The chroot needs it. Revert to Enforcing only for a phone build.
- **Never force push.** `main` is the only long-lived branch.
- **Every commit is GPG signed** (`git commit -S`). The maintainer's key is
  `1BE4A90DE5F4B0D1D8A2C18516965D8DFC57CB09`.
- **Commit subject is imperative, no `[vN]` prefix.** The body carries
  Problem / Fix / Files / Impact.
- **Update `README.md` and `CHANGELOG.md` in the same change** as the code.
- **The kernel is prebuilt.** `kernel/xiaomi/msm8937` only supplies
  `headers_install` output; the boot image is the prebuilt Luuvy
  `Image.gz-dtb`. Kernel config changes are not possible from this tree.

## Build

```bash
cd ~/qassa
source build/envsetup.sh
lunch qassa_santoni-userdebug
mka installclean && mka qassa
```

`out/` grows past 200 GB. Check `df -h` first.

## Commit workflow

1. Make the change.
2. Test that the build compiles, or get maintainer approval to skip.
3. Commit with `git commit -S` and an imperative subject line.
4. Put Problem / Fix / Files / Impact in the body.
5. Update `README.md` and `CHANGELOG.md`.
6. Push. Never force push.
