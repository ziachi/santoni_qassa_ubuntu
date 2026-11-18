# Architecture

How the headless image is assembled, why each piece is where it is, and what the
prebuilt kernel can and cannot do. Operational steps live in
[VPS-SETUP.md](VPS-SETUP.md); the build itself is in [BUILD.md](BUILD.md).

## Where the changes live

| Change | Where |
|---|---|
| `androidboot.selinux=permissive` | `BoardConfig.mk` (`BOARD_KERNEL_CMDLINE`) |
| 37 UI APKs dropped, including `SystemUI`, `Launcher3`, `Settings`, `Contacts`, `Dialer`, `LatinIME`, `GCam`, `XiaomiAddon` | `prebuilts/Android.mk` (`LOCAL_OVERRIDES_PACKAGES` on `RemovePackages`) |
| `surfaceflinger`, `vendor.hwcomposer-2-1`, `zygote`, `zygote_secondary` stopped at boot, backlight 0 | `rootdir/init.ubuntu.sh` |
| Wi-Fi through `wpa_cli` + busybox `udhcpc`, no `cmd wifi` / `svc wifi` | `wifi/wifi.sh`, `wifi/udhcpc.script` |
| `service surfaceflinger` kept enabled | `rootdir/init.target.rc` |
| `service bootanim` kept enabled, `debug.sf.nobootanimation=1` | `rootdir/init.target.rc`, `qassa_santoni.mk` |
| ADB over USB without the RSA prompt, ADB over Wi-Fi on 5555 | `qassa_santoni.mk` (`PRODUCT_PROPERTY_OVERRIDES`) |

Both services are redefined with the init `override` keyword, which replaces the
AOSP definition from `system/core/rootdir/init.rc`. `init.target.rc` is imported
from `init.qcom.rc`, which `init.rc` imports after its own service definitions,
so the override lands in the right order.

---

## Boot sequence

`init.ubuntu.rc` starts `vps-boot` from `on boot`, which runs
`/system/bin/init.ubuntu.sh`:

```sh
service vps-boot /system/bin/init.ubuntu.sh
    class late_start
    user root
    group root system
    oneshot
    disabled

on boot
    start qrngp
    start vps-boot
```

The trigger used to be `on property:sys.boot_completed=1`. That property is only
set once the framework finishes booting, and on a device with nothing to boot
for it can stay unset for a long time — the first boot after a data wipe spends
minutes in dex2oat. `on boot` runs after `/data` is mounted and after Zygote has
started, which is all this needs. `qrngp` is started explicitly because it
normally waits on `sys.boot_completed`, which never arrives once Zygote is
stopped below, and sshd wants the entropy.

| Step | What it does |
|---|---|
| Wake lock | `echo vps_server_lock > /sys/power/wake_lock` — the SoC never suspends |
| ZRAM | checks `/sys/block/zram0/disksize`; resizes to 2147483648 bytes and `mkswap` + `swapon` when it differs |
| Password file | creates `/data/adb_wifi_pass` with `santoniadmin` when missing, then `chmod 600` + `chown 0:0` |
| Headless | `stop surfaceflinger`, `stop vendor.hwcomposer-2-1`, `stop zygote`, `stop zygote_secondary`, then `echo 0 > /sys/class/leds/lcd-backlight/brightness` |
| Mounts | `rbind` `/dev` + `make-rslave`, devpts only when the rbind did not bring it, then `/proc` and `/sys` |
| sshd prerequisites | creates `/data/ubuntu/tmp` (1777) and `/data/ubuntu/run/sshd` (0755) |
| SSH | `chroot /data/ubuntu /usr/sbin/sshd` after `ssh-keygen -A`; the Debian init script behind `service ssh start` expects systemd and fails silently. `/run/sshd.pid` is removed first, because `/run` lives on `/data` and a stale PID there would name an unrelated process |
| Wi-Fi (background) | launched with `&` once sshd is listening: `ip link set wlan0 up`, `wifi reconnect` when `/data/vps_wifi.conf` exists, `wifi dhcp` to start the udhcpc daemon, then the default route and the chroot's `resolv.conf` |

`/dev` is rbind-mounted rather than bind-mounted because ueventd keeps creating
nodes after boot; a plain bind would freeze the chroot's view at the moment of
the mount. `--make-rslave` keeps an unmount inside the chroot from propagating
back into Android's `/dev`. The mount syntax is probed once at boot: toybox
takes `-o rbind` / `-o rslave`, util-linux takes `--rbind` / `--make-rslave`,
and busybox is used when the built-in mount understands neither.

`fstab.qcom` already asks for `zramsize=2147483648`, so the ZRAM step is
normally just a check — it exists for a device that booted with the old 1 GB
fstab.

### Why the headless step runs before Wi-Fi

`wificond`'s `ClientInterfaceImpl` destructor calls `SetUpState(false)` when its
client (`system_server`) dies, so stopping Zygote takes `wlan0` down; the Wi-Fi
step brings it back up and re-selects the saved network afterwards. Joining a
network before the stop would be undone by `ClientModeImpl`, which disconnects
any network it does not know about.

### Why the Wi-Fi step runs in the background

It runs after sshd is listening. A router that is off at boot makes
`wifi reconnect` sit through its 20 s supplicant wait and its 30 s association
wait, and `wait_ip` another 45 s, so running it in the foreground would hold the
rest of the boot for up to 95 s. sshd does not need the network to listen, so
the script starts it first, launches the bring-up with `&`, and returns. The
default route and the chroot's `resolv.conf` are written by that background job
once the lease arrives, which is also why they are no longer part of the chroot
section.

`stop` does not fire `onrestart`, so nothing restarts the four services. They
are `class main`, and `class_start main` only runs once, at boot.

### Boot log

init sends a service's stdout to `/dev/null`, so `adb logcat -s vps-boot` and
`dmesg | grep vps-boot` both come back empty even when the script ran. The
script keeps its own log instead, capped at 64 KB:

```bash
adb shell cat /data/ubuntu-boot.log
```

The last lines say whether sshd actually came up: `sshd started` followed by
`sshd listening on :22`, or `sshd is NOT listening on :22` when it did not.
`vps-setup` stops at `sshd started` on the console; the listening check is
written to this boot log, not to the installer output.

---

## Headless services: why SurfaceFlinger stays enabled

**SurfaceFlinger stays enabled on purpose.** An earlier revision disabled it to
save RAM. That is not safe: `system_server` binds to the display path and the
camera HAL allocates graphic buffers through it, so a missing SurfaceFlinger is
a bootloop risk, not a saving. The headless part of this build comes from the
missing UI APKs, not from a missing display server.

`bootanim` also stays enabled, but `debug.sf.nobootanimation=1` makes it exit
immediately, so nothing is drawn and init still gets its `service.bootanim.exit`
handshake.

Two related bootloops are written up in `docs/bug-analysis/`:
`allocator-bootloop.md` and `privapp-permissions-bootloop.md`.

---

## Package removal

### Removed from the image

37 APKs are dropped through `LOCAL_OVERRIDES_PACKAGES` on the `RemovePackages`
stub in `prebuilts/Android.mk`. The list covers every APK that only exists to
draw something for a human:

```
Aperture AudioFX Calendar Contacts DeskClock Dialer DocumentsUI
DownloadProviderUi EasterEgg EmergencyInfo ExactCalculator FMRadio Gallery2
GamingMode GCam Launcher3 Launcher3QuickStep LatinIME LiveWallpapersPicker
MatLog messaging MusicFX OneTimeInitializer PowerOffAlarm Provision Settings
SettingsIntelligence ShadyQuickStep SoundPickerPrebuilt StorageManager
SystemUI VpnDialogs WallpaperBackup WallpaperCropper WallpaperPicker2
XiaomiAddon XiaomiParts
```

`GCam` and `XiaomiAddon` are on that list. They are **not** in the image — a
headless build has no UI to show them in, and Zygote is stopped at boot so they
could never run.

Deliberately kept: `framework-res`, `telephony-common`, `WcnssService`, the
providers (`SettingsProvider`, `MediaProvider`, `TelephonyProvider`, ...), the
telephony/modem stack (`TeleService`, `Telecom`, `ims`, `qcrilmsgtunnel`, `Stk`,
`MmsService`, `CellBroadcastReceiver`) and the network services
(`InProcessNetworkStack`, `SoftAPManager`, `WfdService`, `OsuLogin`,
`PlatformCaptivePortalLogin`).

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

The stub has to be installed for the override to apply, so `RemovePackages` is
listed in `PRODUCT_PACKAGES` in `device.mk`. Keep the two lists in sync. A name
that does not match a module is harmless — the override silently does nothing —
so the list can be extended without risk.

> `debloat/` is not the debloat mechanism. It holds a single Dolby stub
> manifest and nothing else.

---

## Chroot boot services: `boot-services.sh`

`/usr/sbin/sshd` is a wrapper that runs `/usr/local/sbin/boot-services.sh` five
seconds after sshd comes up, so the chroot needs no change in `init.ubuntu.sh`.
The script is idempotent and safe to run by hand; it logs to
`/var/log/boot-services.log`.

Both scripts live in `/usr/local/sbin`, not in `/root`. Root's home is the first
thing an operator sees after `ssh root@...`, and a `rm -rf ~/*` there used to
delete the boot path along with it. `/usr/local/sbin` is the FHS location for
locally installed admin programs: it is on root's `PATH`, it stays out of the
home directory, and it is outside `/usr/bin` and `/usr/sbin`, so the suid
re-bind does not touch it.

| Step | What it does |
|---|---|
| Mounts | `/usr/local/sbin/suid-mount.sh` re-applies the setuid mounts the chroot needs |
| systemd marker | creates `/run/systemd/system` (0755), which installers check before they use `systemctl` |
| sshd pidfile | rewrites `/run/sshd.pid` from the live listener, before and after `systemctl default`, and keeps it `0644` so non-root users can read it |
| cron | `systemctl enable cron` + `systemctl start cron` when the unit or the init script exists, so `crontab` jobs actually run; `cron.service.d/pidfile.conf` points the shim at `/run/crond.pid` so `is-active` sees it |
| CPU governor | picks `schedutil` (or `interactive`/`ondemand`) instead of pinning `performance` on a device with no heatsink |

`cron` is installed from `VPS_PACKAGES` in `vps-setup.sh` but nothing else
enables it, so the cron step is what makes `crontab -e` useful. It runs after
sshd is settled, so a slow or failing cron cannot delay the login path.

`cron.service` has no `Type=` line, so the shim cannot derive its state from a
`MainPID` it never wrote, and `is-active` reported `inactive` for a daemon that
was running. The drop-in gives it the pidfile cron writes itself, which is the
same trick `ssh.service.d/pidfile.conf` uses for sshd.

`VPS_PACKAGES` in `vps-setup.sh` is the only package list that is installed;
`packages.list` is copied into the image but no script reads it. `iproute2` was
missing from `VPS_PACKAGES` even though `packages.list` lists it, so `ip` and
`ss` were absent while `netstat` from `net-tools` still worked. Both are in the
list now.

`/run` is a plain directory on `/data`, not a tmpfs, so pidfiles survive a
reboot. The shim reads a pidfile whose pid is alive as "already running", and
Android reuses pids quickly, so a stale `/run/crond.pid` could point at an
unrelated process and make the cron step skip a daemon that was not running.
`start_cron` now drops a pidfile that does not name `cron` before starting it.

`cron` writes `/run/crond.pid` `0600`, and the shim reads the pid from that
file, so `is-active cron` reported `inactive` for `ubuntu` while the daemon was
running. The pidfile is made `0644` after the start, the same way
`/run/sshd.pid` is.

Both drop-ins are shipped in the image by `PRODUCT_COPY_FILES` in
`qassa_santoni.mk`, alongside the rest of `vps-setup/rootdir`.

---

## Wi-Fi helper internals

`cmd wifi` and `svc wifi` are shell front-ends for `system_server`, and
`system_server` is stopped at boot. `wifi` is a short front-end for
`/vendor/bin/wpa_cli` and busybox `udhcpc`, installed to `/system/bin/wifi`:

```sh
adb root
adb shell wifi scan
adb shell wifi connect aeqaeqa <password>
adb shell wifi status
adb shell wifi disconnect
adb shell wifi reconnect
adb shell wifi dhcp
adb shell wifi help
```

| Command | What it does |
|---|---|
| `scan` | `wpa_cli scan` then `scan_results`; raw `bssid / frequency / signal level / flags / ssid` lines |
| `connect <ssid> [pw]` | brings `wlan0` up, starts `wpa_supplicant` when needed, adds the network, waits for `wpa_state=COMPLETED`, saves the credentials, starts the udhcpc daemon and prints the IP |
| `reconnect` | the same, using `/data/vps_wifi.conf` |
| `disconnect` | `wpa_cli disconnect`, then flushes the address |
| `status` | `wpa_cli status` plus the IPv4 address |
| `dhcp` | starts the udhcpc daemon when it is not already running |

All of it needs root, so run `adb root` first.

`wpa_supplicant` runs without `-c`, so it has no config file and `save_config`
has nowhere to write. `connect` therefore keeps the credentials in
`/data/vps_wifi.conf` (0600), and `init.ubuntu.sh` replays them on every boot.

The lease is renewed by `busybox udhcpc` in daemon mode, with
`/system/bin/udhcpc.script` as the hook. The hook never flushes the address, so
a renewal that fails leaves the device reachable on its old address instead of
taking it off the network.

`wifi dhcp` treats `/data/udhcpc.wlan0.pid` as a hint, not a fact: `/data`
survives a reboot, so the PID in a stale file can belong to an unrelated
process. It reads `/proc/<pid>/cmdline` and only skips the start when that
process really is `udhcpc`.

Inside the chroot the same CLI is available as `/usr/local/bin/wifi`. It chroots
back into Android's root, so `/proc` has to be mounted — the boot script does
that.

The `WifiShellCommand` backports in `patches/` are no longer used by anything.
They stay in the tree because they are harmless.

---

## ADB access and `ubuntu-enter`

| Property | Value | Effect |
|---|---|---|
| `persist.sys.usb.config` | `adb` | USB gadget exposes adb only (no MTP) |
| `persist.service.adb.enable` | `1` | adbd starts at boot |
| `ro.adb.secure` | `0` | no RSA authorisation prompt |
| `ro.secure` | `0` | adbd runs as root |
| `ro.debuggable` | `1` | debuggable build |
| `service.adb.tcp.port` | `5555` | adbd also listens on TCP 5555 |

> **Debug-phase access only.** `ro.adb.secure=0` and `ro.secure=0` mean anyone
> who can reach port 5555 is root once they pass the gate. That is deliberate
> while the device sits on the bench on a trusted LAN, and it is not a shipping
> configuration.

`persist.sys.adb.shell=/system/bin/ubuntu-enter` makes every adb session go
through a dual-auth wrapper:

| Connection | Behaviour |
|---|---|
| USB attached (`/sys/class/android_usb/android0/state` = `CONFIGURED`) | straight in, no password |
| Wi-Fi only (`DISCONNECTED`) | `ADB Wi-Fi Password:` prompt, 3 tries, then the session is closed |
| `DEBUG_NO_PASSWORD=0` (current) | gate active — the two rows above apply |
| `DEBUG_NO_PASSWORD=1` | prompt skipped on every transport — debug only, never ship |
| Ubuntu installed (`/data/ubuntu/bin/bash`) | `chroot /data/ubuntu /bin/bash -l` as root |
| Ubuntu not installed | drops to `/system/bin/sh` with a hint to run `vps-setup` |

The password is read from `/data/adb_wifi_pass`, which `vps-setup` and
`init.ubuntu.sh` create on first boot as `0600 root:root`.

> **Requires the adb patch.** AOSP hard-codes the adb shell to
> `/system/bin/sh`; `persist.sys.adb.shell` is only honoured after
> `patches/apply-adb-shell-override.py` has been applied to the synced source.
> See [patches/README.md](../patches/README.md).

---

## Hardware bridges

Three bridges live in the device tree and are **built into the image**. They are
Android-side helpers that expose hardware the chroot cannot reach on its own.

### `webcam-bridge` — camera

Camera2 NDK to MJPEG. `/dev/video*` on MSM8937 is not UVC, so the NDK is the
only entry point. Missing: JPEG encode, the repeating request, and the MJPEG
server on `127.0.0.1:8080`. Run it as `camera`, not as root from the chroot —
`cameraserver` rejects clients outside the `camera` group.

### `audio-bridge` — speaker and mic

PulseAudio config only. The unix socket is `/data/ubuntu/tmp/pulse.sock` and the
sink/source go through OpenSL ES so the Android audio HAL keeps the mixer. The
arm64 PulseAudio binary and the `module-sles-*` modules are **not** in this
tree; the config fails to load until they are installed in the chroot.

### `sensor-bridge` — sensors

`ASensorManager` to `/data/ubuntu/tmp/sensors.log`, one line per sample. Reading
`/dev/input` directly would split the evdev queue with `system_server`. The log
is append-only and never rotated.

---

## Kernel capability check

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

> The kernel is a **prebuilt binary**, not built from this tree. The
> `kernel/xiaomi/msm8937` checkout only supplies `headers_install` output. To
> change a kernel option you need a new `Image.gz-dtb` from the Luuvy
> maintainer — the source is not public.
