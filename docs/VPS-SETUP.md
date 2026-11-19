# Headless VPS mode

The build is a headless server: no Android UI, no display server, no boot
animation. Everything is driven over ADB, then over SSH. For the internals
behind these steps, see [ARCHITECTURE.md](ARCHITECTURE.md).

## Quick start

From a freshly flashed device to an SSH session, in order:

```bash
# 1. USB: no RSA prompt, adbd is already root
adb devices
adb shell id                      # uid=0(root)

# 2. USB: join Wi-Fi and install Ubuntu 22.04 in one command
adb shell vps-setup "MyWiFi" "MyWiFiPassword"

# 3. note the IP the script prints, then move to Wi-Fi ADB
adb connect <device-ip>:5555
echo 'santoniadmin' | adb -s <device-ip>:5555 shell id

# 4. vps-setup already set a random root password and printed it
#    (it is also in /data/ubuntu_root_pass if you missed it)

# 5. from any machine on the LAN
ssh root@<device-ip>
```

Steps 1-2 need the cable. After step 2 the device is self-sufficient: it
rejoins Wi-Fi and starts Ubuntu on every boot, so steps 3-5 work over the
network from then on.

## First setup (USB)

Flash the ROM, plug in USB, then run one command:

```bash
adb shell vps-setup "MyWiFi" "MyWiFiPassword"
```

It does eight things:

1. `/system/bin/wifi connect <SSID> <PASSWORD>` brings `wlan0` up, starts
   `wpa_supplicant` when needed, adds the network through `wpa_cli` and saves
   the credentials to `/data/vps_wifi.conf`. `svc wifi` and `cmd wifi` are not
   used: both go through `system_server`, which the boot script stops.
2. wait up to 45s for an IPv4 address on `wlan0`, read with
   `ip -4 addr show wlan0`
3. download `ubuntu-base-22.04-base-arm64.tar.gz` to `/data/local/tmp/`
4. `tar -xzf` it into `/data/ubuntu` and create `dev`, `dev/pts`, `proc`,
   `sys`, `tmp`, `run`
5. write `/etc/resolv.conf` (8.8.8.8, 1.1.1.1) and an `apt` `sources.list` for
   `ports.ubuntu.com`
6. create `/data/adb_wifi_pass` with `santoniadmin` if it is missing, then
   `chmod 600` and `chown 0:0`, and print the value
7. mount `/dev`, `/proc` and `/sys` inside the chroot, write a `resolv.conf`,
   then `apt update && apt install -y openssh-server` and unmount again
8. set the root password to `santoniadmin` (or `$UBUNTU_ROOT_PASS`), `chpasswd`
   it into the chroot, verify the hash landed in `/etc/shadow`, save it to
   `/data/ubuntu_root_pass` (0600 root:root) and set `PermitRootLogin yes` in
   `sshd_config`

`curl` is built into the image from the in-tree `external/curl` module, so the
download normally happens on the device. If it is missing (an older build), the
script prints the `adb push` recipe instead of failing silently:

```bash
curl -LO https://cdimage.ubuntu.com/ubuntu-base/releases/22.04/release/ubuntu-base-22.04-base-arm64.tar.gz
adb push ubuntu-base-22.04-base-arm64.tar.gz /data/local/tmp/
adb shell vps-setup "MyWiFi" "MyWiFiPassword"
```

After that, `adb shell` lands in Ubuntu as root with `openssh-server`
installed, the root password set, and `PermitRootLogin yes` written into
`sshd_config`. The script prints both passwords at the end:

```
  Passwords, also stored on the device (mode 600 root:root):
    adb over Wi-Fi : santoniadmin
                     /data/adb_wifi_pass
    ssh root       : santoniadmin
                     /data/ubuntu_root_pass
```

`PermitRootLogin yes` is required because Ubuntu 22.04 defaults to
`prohibit-password`, which refuses root password logins even after
`passwd root`. To use a key instead, put it in
`/data/ubuntu/root/.ssh/authorized_keys` and set `PermitRootLogin
prohibit-password` back.

## ADB access

```bash
# Over USB: no on-screen confirmation needed
adb devices
adb shell

# Over Wi-Fi, once the device is on the network
adb connect <device-ip>:5555
adb -s <device-ip>:5555 shell
```

> **Debug-phase access only.** `ro.adb.secure=0` and `ro.secure=0` mean anyone
> who can reach port 5555 is root once they pass the gate. That is deliberate
> while the device sits on the bench on a trusted LAN, and it is not a shipping
> configuration. `ubuntu-enter` runs with `DEBUG_NO_PASSWORD=0`, so the Wi-Fi
> password gate is active: USB lands straight in, Wi-Fi asks for the password.

The property table and the `ubuntu-enter` behaviour matrix are in
[ARCHITECTURE.md](ARCHITECTURE.md#adb-access-and-ubuntu-enter).

## Login shell: `ubuntu-enter`

`persist.sys.adb.shell=/system/bin/ubuntu-enter` makes every adb session go
through a dual-auth wrapper: USB lands straight in, Wi-Fi asks for
`ADB Wi-Fi Password:` with 3 tries, then the session is closed. Once Ubuntu is
installed the session becomes `chroot /data/ubuntu /bin/bash -l` as root;
before that it drops to `/system/bin/sh` with a hint to run `vps-setup`.

Default password: **`santoniadmin`**. It is read from `/data/adb_wifi_pass`,
which `vps-setup` and `init.ubuntu.sh` create on first boot as `0600 root:root`.

Scripted access over Wi-Fi is gated too, so feed the password on stdin:

```bash
echo 'santoniadmin' | adb -s <device-ip>:5555 shell getprop ro.product.model
```

> **Requires the adb patch.** AOSP hard-codes the adb shell to
> `/system/bin/sh`; `persist.sys.adb.shell` is only honoured after
> `patches/apply-adb-shell-override.py` has been applied to the synced source.
> See [patches/README.md](../patches/README.md).

> **Security:** port 5555 gives a root shell to anyone who can reach it. The
> password gate is the only thing in front of it, so firewall 5555 to trusted
> networks if the device is ever exposed.

## Changing the ADB Wi-Fi password

The password lives in `/data/adb_wifi_pass` (mode 600, owner `root:root`).
Change it over USB, where no password is required:

```bash
adb shell "echo 'my-new-password' > /data/adb_wifi_pass && chmod 600 /data/adb_wifi_pass"
```

The file is read on every Wi-Fi session, so no reboot is needed. Check that the
new value is accepted and the old one is not:

```bash
echo 'my-new-password' | adb -s <device-ip>:5555 shell id   # works
echo 'santoniadmin'    | adb -s <device-ip>:5555 shell id   # 3 tries, then closed
```

Forgot it? Delete the file over USB and the default `santoniadmin` comes back.
`init.ubuntu.sh` recreates it with `0600 root:root` on the next boot:

```bash
adb shell rm -f /data/adb_wifi_pass
```

## Wi-Fi helper: `wifi`

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

All of it needs root, so run `adb root` first. Inside the chroot the same CLI
is available as `/usr/local/bin/wifi`. Command-by-command behaviour and the
`/data/vps_wifi.conf` replay logic are in
[ARCHITECTURE.md](ARCHITECTURE.md#wifi-helper-internals).

## Boot log

init sends a service's stdout to `/dev/null`, so `adb logcat -s vps-boot` and
`dmesg | grep vps-boot` both come back empty even when the script ran. The boot
script keeps its own log instead, capped at 64 KB:

```bash
adb shell cat /data/ubuntu-boot.log
```

The last lines say whether sshd actually came up: `sshd started` followed by
`sshd listening on :22`, or `sshd is NOT listening on :22` when it did not.

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `vps-setup: no IP on wlan0, check SSID/password` | wrong SSID or password, or a 5 GHz-only AP | re-run with the exact SSID, santoni is 2.4 GHz only |
| `wifi: add_network failed` | `wpa_supplicant` is not running, or `/vendor/bin/wpa_cli` is missing from the image | `adb shell getprop init.svc.wpa_supplicant` must print `running`; `wpa_cli` needs a build that lists it in `PRODUCT_PACKAGES` |
| `wifi: no /data/vps_wifi.conf, run 'wifi connect'` | the device has never joined a network, so the boot script has nothing to replay | `adb shell wifi connect <ssid> <password>` once; the file is written from then on |
| `vps-setup: no downloader on the device` | `curl` is missing from the image | use the `adb push` recipe the script prints, or rebuild with `curl` in `PRODUCT_PACKAGES` |
| `adb connect` → `connection refused` | adbd not listening yet, or wrong IP | `adb shell getprop service.adb.tcp.port` must be `5555`; read the IP with `adb shell ip -4 addr show wlan0` |
| Wi-Fi ADB asks for a password you do not know | `/data/adb_wifi_pass` was changed | over USB: `adb shell cat /data/adb_wifi_pass`, or delete the file to fall back to `santoniadmin` |
| `vps-setup` prints `/bin/sh: 1: apt-get: not found` | the chroot inherited Android's `PATH`, which has no `/usr/bin` | fixed in #52; on an older build run `chroot /data/ubuntu /bin/sh -c 'export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin; apt-get update && apt-get install -y openssh-server'` |
| `bash: groups: command not found` inside the chroot | `/etc/profile` in ubuntu-base sets `PS1` but not `PATH`, so the chroot keeps Android's `PATH` | fixed in #53; on an older build run `export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin` |
| `apt` says `Temporary failure resolving 'ports.ubuntu.com'` | the chroot is unmarked, so it uses the main routing table, which on Android holds only the local subnet plus an `unreachable default` | fixed in #53; `vps-setup` and `init.ubuntu.sh` copy the `wlan0` gateway into the main table. To repair a running device: `ip route add default via <gateway> dev wlan0` |
| `chpasswd` exits 0 but the password is still rejected | PAM inside the chroot cannot complete the change, so nothing is written to `/etc/shadow` | write the hash directly, which skips PAM: `adb shell "chroot /data/ubuntu /usr/sbin/usermod -p '<sha512-crypt-hash>' root"`. Keep the single quotes and do not wrap this in `bash -c`: the hash contains `$`, and a second parse expands `$6`, `$salt` and the leading part of the digest, storing a truncated string that no password can match. Generate the hash with `openssl passwd -6 -salt santoni <password>` |
| SSH still rejects a correct password after the hash is in `/etc/shadow` | PAM inside the chroot cannot complete authentication, usually because `/dev` or `/proc` is not mounted, so `pam_unix` and `pam_loginuid` fail | set `UsePAM no` in `/etc/ssh/sshd_config` and restart sshd; it then compares the password itself with `crypt()` and loads no PAM modules. Confirm the account is not locked with `chroot /data/ubuntu /usr/bin/passwd -S root`, which prints `P` for a usable password |
| SSH says `Permission denied (publickey,password)` | `PermitRootLogin` is still `prohibit-password`, or `chpasswd` never applied the hash | over USB: `adb shell "chroot /data/ubuntu /bin/bash -c 'echo root:santoniadmin | /usr/sbin/chpasswd'"`, then confirm `grep ^root: /etc/shadow` shows a hash and not `!` |
| SSH says `Connection refused` after a reboot | sshd never started. On builds before `c82969e` the boot script used `service ssh start`, and `start-stop-daemon` skips the start when `/run/sshd.pid` still names a live PID; `--oknodo` then hides the failure and the log still says `sshd started` | rebuild with `c82969e` or later. On a running device: `adb shell "rm -f /data/ubuntu/run/sshd.pid; chroot /data/ubuntu /usr/sbin/sshd"` |
| `adb shell` drops to `/system/bin/sh` | Ubuntu is not installed | run `vps-setup` |
| `vps-boot: openssh-server not installed` in `/data/ubuntu-boot.log` | sshd missing | `apt install -y openssh-server` inside the chroot |
| `dpkg` fails with `mktemp: failed to create file via template '/data/local/tmp/tmp.XXXXXXXXXX'` | `adb shell` exports `TMPDIR=/data/local/tmp`, which does not exist inside the chroot, so package postinst scripts abort | fixed in #53; run chroot commands with `export TMPDIR=/tmp` |
| `apt` cannot reach the network from the chroot at all, for any resolver | Android routes unmarked traffic through the main table, which holds only the local subnet plus an `unreachable default` | fixed in #53. If the device still cannot reach the network, install offline: download the ten arm64 packages in `vps-setup/offline-debs.txt`, `adb push` them to `/data/ubuntu/tmp/`, then `DEBIAN_FRONTEND=noninteractive dpkg -i /tmp/*.deb` inside the chroot |
| `ping` says `socket: Permission denied` inside the chroot | the kernel is built with `CONFIG_ANDROID_PARANOID_NETWORK`, which gates `socket()` on the caller's GID and ignores `cap_net_raw`, so a user outside `aid_inet` (3003) and `aid_net_raw` (3004) cannot open a socket at all, and name resolution fails the same way, as `Temporary failure in name resolution` | fixed in #79; on an older build run `chroot /data/ubuntu /usr/sbin/usermod -aG aid_inet,aid_net_raw root` and log in again |
| `vps-boot: could not mount /proc` | `/data/ubuntu` is missing or not a rootfs | re-run `vps-setup` |
| `system_server` crash-loops after boot | SurfaceFlinger is disabled | see [ARCHITECTURE.md](ARCHITECTURE.md#headless-services-why-surfaceflinger-stays-enabled): drop the `surfaceflinger` override |
| A full-screen TUI such as `zeroclaw quickstart` looks frozen and Ctrl+C does nothing | the TUI puts the pty in raw mode, where Ctrl+C arrives as a key event and not as SIGINT, so the shell never sees an interrupt | press Esc, which is the TUI's own exit; if the process was force-stopped instead, the terminal is left in the alternate screen with echo off, so run `reset` (or `stty sane`) to get the prompt back |
| `zeroclaw quickstart` exits with `could not determine the terminal size` | the pty reports 0 rows and 0 columns, which is what a client that sends no window size, or a `script` wrapper, produces | run it from a real terminal, or set the size first with `stty rows 40 cols 100`; for a headless setup use `zeroclaw config set <path> <value>` instead of the TUI |
