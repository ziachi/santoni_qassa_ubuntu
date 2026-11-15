#!/usr/bin/env bash
#
# verify-ikconfig.sh — check a santoni kernel for the options the
# Ubuntu-on-santoni VPS needs.
#
# The config is read straight out of the kernel image (the IKCFG_ST blob that
# CONFIG_IKCONFIG embeds), so no kernel source tree is required.
#
# Usage:
#   tools/verify-ikconfig.sh <Image.gz-dtb | Image | .config> [--dump] [--quiet]
#
#   --dump    print the extracted config to stdout and exit
#   --quiet   only print the summary line
#
# Exit status: 0 all required options present, 1 something required is missing,
#              2 usage or extraction error.

set -u

usage() {
    sed -n '3,16p' "$0" | sed 's/^# \{0,1\}//'
    exit 2
}

[ $# -ge 1 ] || usage
INPUT=$1
shift
DUMP=0
QUIET=0
for arg in "$@"; do
    case "$arg" in
        --dump) DUMP=1 ;;
        --quiet) QUIET=1 ;;
        *) usage ;;
    esac
done

[ -f "$INPUT" ] || { echo "error: no such file: $INPUT" >&2; exit 2; }

extract_config() {
    python3 - "$1" <<'PY'
import sys, zlib

path = sys.argv[1]
raw = open(path, 'rb').read()

def gunzip(buf):
    d = zlib.decompressobj(16 + zlib.MAX_WBITS)
    return d.decompress(buf)

# A plain .config starts with a comment or a CONFIG_ line.
if raw.lstrip()[:1] == b'#' or raw.lstrip().startswith(b'CONFIG_'):
    sys.stdout.buffer.write(raw)
    sys.exit(0)

# Image.gz-dtb: gzip payload followed by the appended DTB.
image = gunzip(raw) if raw[:2] == b'\x1f\x8b' else raw

marker = image.find(b'IKCFG_ST')
if marker < 0:
    sys.exit('no IKCFG_ST marker: kernel was built without CONFIG_IKCONFIG')

start = image.find(b'\x1f\x8b\x08', marker)
if start < 0:
    sys.exit('IKCFG_ST found but no gzip stream follows it')

config = gunzip(image[start:])
end = config.find(b'IKCFG_ED')
if end > 0:
    config = config[:end]
sys.stdout.buffer.write(config)
PY
}

CONFIG=$(extract_config "$INPUT") || exit 2
[ -n "$CONFIG" ] || { echo "error: extracted config is empty" >&2; exit 2; }

if [ "$DUMP" = 1 ]; then
    printf '%s\n' "$CONFIG"
    exit 0
fi

# name:severity:why
#   required — the chroot-based Ubuntu VPS does not work without it
#   optional — only needed for container runtimes or extra tooling
REQUIRED_LIST='
CONFIG_NAMESPACES:required:namespace syscalls (unshare/clone flags)
CONFIG_NET_NS:required:network namespace for isolated networking
CONFIG_SYSVIPC:required:SysV IPC (PostgreSQL, Redis, many daemons)
CONFIG_POSIX_MQUEUE:required:POSIX message queues
CONFIG_CGROUPS:required:cgroup filesystem
CONFIG_CGROUP_FREEZER:required:freeze/thaw processes
CONFIG_CPUSETS:required:CPU pinning
CONFIG_DEVTMPFS:required:/dev population inside the chroot
CONFIG_EXT4_FS:required:rootfs and /data
CONFIG_TMPFS:required:/tmp, /run, /dev/shm
CONFIG_TMPFS_POSIX_ACL:required:ACLs on tmpfs
CONFIG_SWAP:required:ZRAM swap
CONFIG_ZRAM:required:compressed RAM swap
CONFIG_SECCOMP:required:sandboxing for sshd and friends
CONFIG_KEYS:required:keyring support
CONFIG_UNIX:required:unix domain sockets
CONFIG_INET:required:IPv4
CONFIG_IPV6:required:IPv6
CONFIG_PACKET:required:raw sockets (dhcpcd, tcpdump)
CONFIG_NETFILTER:required:iptables/nftables
CONFIG_NF_CONNTRACK:required:connection tracking
CONFIG_IP_NF_NAT:required:NAT for the Wi-Fi uplink
CONFIG_IP_NF_TARGET_MASQUERADE:required:masquerade for the Wi-Fi uplink
CONFIG_TUN:required:VPN and tunnel interfaces
CONFIG_BRIDGE:required:bridged networking
CONFIG_OVERLAY_FS:required:overlay mounts
CONFIG_FUSE_FS:required:FUSE filesystems
CONFIG_BLK_DEV_LOOP:required:loop devices
CONFIG_BLK_DEV_DM:required:device mapper
CONFIG_DM_CRYPT:required:encrypted volumes
CONFIG_VFAT_FS:required:FAT/exFAT SD cards
CONFIG_NLS_CODEPAGE_437:required:VFAT codepage
CONFIG_NLS_ISO8859_1:required:VFAT charset
CONFIG_IKCONFIG:required:config embedded in the image
CONFIG_IKCONFIG_PROC:required:/proc/config.gz on device
CONFIG_MODULES:required:loadable modules
CONFIG_ANDROID_BINDER_IPC:required:Android binder
CONFIG_ASHMEM:required:Android ashmem
CONFIG_ION:required:Android ION allocator
CONFIG_SDCARD_FS:required:sdcardfs for /storage
CONFIG_AUDIT:required:audit subsystem
CONFIG_SECURITY_SELINUX:required:SELinux (permissive still needs it)
CONFIG_BINFMT_ELF:required:ELF binaries
CONFIG_SHMEM:required:shared memory
CONFIG_PPP:required:PPP (USB tethering fallback)
CONFIG_PPP_ASYNC:required:async PPP
CONFIG_USB_CONFIGFS:required:USB gadget configfs
CONFIG_ARM64_4K_PAGES:required:4K pages
CONFIG_ARM64_VA_BITS:required:VA size
CONFIG_PID_NS:optional:PID namespaces (Docker/LXC/podman)
CONFIG_UTS_NS:optional:UTS namespaces (hostname isolation)
CONFIG_IPC_NS:optional:IPC namespaces
CONFIG_USER_NS:optional:user namespaces (rootless containers)
CONFIG_MEMCG:optional:memory cgroup limits
CONFIG_VETH:optional:veth pairs for container networking
CONFIG_SQUASHFS:optional:squashfs images
CONFIG_BINFMT_MISC:optional:binfmt_misc (qemu-user)
CONFIG_DEVPTS_MULTIPLE_INSTANCES:optional:separate /dev/pts per namespace
'

missing_required=0
missing_optional=0
total_required=0
total_optional=0
report=""

while IFS=: read -r name severity why; do
    [ -n "${name:-}" ] || continue
    line=$(printf '%s\n' "$CONFIG" | grep -E "^${name}=" | head -1)
    if [ -n "$line" ]; then
        state="OK"
        value=${line#*=}
    elif printf '%s\n' "$CONFIG" | grep -qE "^# ${name} is not set"; then
        state="MISSING"
        value="not set"
    else
        state="ABSENT"
        value="not in config"
    fi

    if [ "$severity" = required ]; then
        total_required=$((total_required + 1))
        [ "$state" = OK ] || missing_required=$((missing_required + 1))
    else
        total_optional=$((total_optional + 1))
        [ "$state" = OK ] || missing_optional=$((missing_optional + 1))
    fi

    report="${report}$(printf '%-6s %-8s %-34s %-12s %s' "$state" "$severity" "$name" "$value" "$why")
"
done <<EOF
$(printf '%s\n' "$REQUIRED_LIST" | sed '/^$/d')
EOF

if [ "$QUIET" = 0 ]; then
    printf '%-6s %-8s %-34s %-12s %s\n' STATE LEVEL OPTION VALUE NOTE
    printf '%s\n' "$report"
    echo
fi

echo "required: $((total_required - missing_required))/$total_required present, $missing_required missing"
echo "optional: $((total_optional - missing_optional))/$total_optional present, $missing_optional missing"

[ "$missing_required" -eq 0 ] || exit 1
exit 0
