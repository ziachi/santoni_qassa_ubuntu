#!/usr/bin/env python3
"""Add `cmd wifi connect-network` to Android 10's WifiShellCommand.

Android 11 added `connect-network` to `cmd wifi`. Android 10 has no shell
command that can join a network at all, so a headless build with no Settings UI
can never get on Wi-Fi and `vps-setup` cannot download the rootfs.

The framework still owns the connection: the new command only saves the network
and asks ClientModeImpl to connect, so DHCP, DNS and the network agent stay with
the framework.

Usage:
    cd ~/qassa
    device/xiaomi/santoni/patches/apply-wifi-connect-network.py .

The script is idempotent and prints "already patched" on a second run.
"""

import sys
from pathlib import Path

TARGET = Path(
    "frameworks/opt/net/wifi/service/java/com/android/server/wifi/WifiShellCommand.java"
)

IMPORT_ANCHOR = "import android.net.wifi.WifiScanner;\n"
IMPORT_ADD = "import android.net.wifi.WifiConfiguration;\n"

PROCESS_ANCHOR = "import android.os.ShellCommand;\n"
PROCESS_ADD = "import android.os.Process;\n"

CASE_ANCHOR = (
    "                default:\n"
    "                    return handleDefaultCommands(cmd);\n"
)
CASE_ADD = """                case "connect-network": {
                    return connectNetwork();
                }
"""

METHOD_ANCHOR = (
    "    private int sendLinkProbe(PrintWriter pw) throws InterruptedException {\n"
)
METHOD_ADD = '''    /**
     * Backport of the Android 11 {@code cmd wifi connect-network} command.
     *
     * The framework still owns the connection: this only saves the network and
     * asks ClientModeImpl to connect, so DHCP, DNS and the network agent stay
     * with the framework.
     */
    private int connectNetwork() {
        final PrintWriter pw = getOutPrintWriter();
        String ssid = getNextArgRequired();
        String type = getNextArgRequired();
        String passphrase = null;
        if ("wpa2".equals(type) || "wpa3".equals(type)) {
            passphrase = getNextArgRequired();
        } else if (!"open".equals(type)) {
            pw.println("Invalid network type: " + type + " (expected open, wpa2 or wpa3)");
            return -1;
        }

        WifiConfiguration config = new WifiConfiguration();
        config.SSID = "\\"" + ssid + "\\"";
        if (passphrase == null) {
            config.allowedKeyManagement.set(WifiConfiguration.KeyMgmt.NONE);
        } else {
            config.allowedKeyManagement.set(WifiConfiguration.KeyMgmt.WPA_PSK);
            config.preSharedKey = "\\"" + passphrase + "\\"";
        }

        NetworkUpdateResult result =
                mWifiConfigManager.addOrUpdateNetwork(config, Process.SHELL_UID);
        if (!result.isSuccess()) {
            pw.println("Failed to add/update network " + ssid);
            return -1;
        }
        int networkId = result.getNetworkId();
        if (!mWifiConfigManager.enableNetwork(networkId, true, Process.SHELL_UID)) {
            pw.println("Failed to enable network " + ssid);
            return -1;
        }
        mClientModeImpl.startConnectToNetwork(networkId, Process.SHELL_UID, null);
        pw.println("Connecting to " + ssid + " (networkId=" + networkId + ")");
        return 0;
    }

'''

HELP_ANCHOR = '        pw.println("  set-ipreach-disconnect enabled|disabled");\n'
HELP_ADD = '''        pw.println("  connect-network <ssid> open|wpa2|wpa3 [passphrase]");
        pw.println("    Connect to the specified network.");
'''


def insert_before(text, anchor, addition, label):
    if anchor not in text:
        sys.exit("error: cannot find the %s anchor in %s" % (label, TARGET))
    return text.replace(anchor, addition + anchor, 1)


def main():
    if len(sys.argv) != 2:
        sys.exit("usage: apply-wifi-connect-network.py <aosp-root>")

    target = Path(sys.argv[1]) / TARGET
    if not target.is_file():
        sys.exit("error: %s not found" % target)

    text = target.read_text()
    if "connect-network" in text:
        print("already patched")
        return

    text = insert_before(text, IMPORT_ANCHOR, IMPORT_ADD, "WifiScanner import")
    text = insert_before(text, PROCESS_ANCHOR, PROCESS_ADD, "ShellCommand import")
    text = insert_before(text, CASE_ANCHOR, CASE_ADD, "onCommand default case")
    text = insert_before(text, METHOD_ANCHOR, METHOD_ADD, "sendLinkProbe method")
    text = insert_before(text, HELP_ANCHOR, HELP_ADD, "onHelp text")

    target.write_text(text)
    print("patched %s" % target)


if __name__ == "__main__":
    main()
