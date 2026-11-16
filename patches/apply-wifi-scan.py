#!/usr/bin/env python3
"""Add `scan`, `list-scan-results`, `disconnect` and `status` to `cmd wifi`.

Android 11 added these four to `cmd wifi`. Android 10 has none of them, so a
headless build cannot list nearby networks, drop a connection, or read the
current signal. `dumpsys wifi` is not a substitute: on Q `WifiServiceImpl.dump()`
never reaches `WifiConnectivityManager`, and `ClientModeImpl.dump()` only prints
the current `WifiInfo`.

Run apply-wifi-connect-network.py first. This script anchors its help text on
the `connect-network` lines that patch adds.

Usage:
    cd ~/qassa
    device/xiaomi/santoni/patches/apply-wifi-scan.py .

The script is idempotent and prints "already patched" on a second run.
"""

import sys
from pathlib import Path

TARGET = Path(
    "frameworks/opt/net/wifi/service/java/com/android/server/wifi/WifiShellCommand.java"
)

MARKER = 'case "list-scan-results"'

CASES = """                case "scan": {
                    return scan();
                }
                case "list-scan-results": {
                    return listScanResults();
                }
                case "disconnect": {
                    return disconnect();
                }
                case "status": {
                    return status();
                }
"""

METHODS = '''    private int scan() {
        final CountDownLatch latch = new CountDownLatch(1);
        final WifiScanner.ScanListener listener = new WifiScanner.ScanListener() {
            @Override
            public void onSuccess() {
            }

            @Override
            public void onFailure(int reason, String description) {
                latch.countDown();
            }

            @Override
            public void onResults(WifiScanner.ScanData[] results) {
                if (results != null && results.length > 0) {
                    mScanResults = Arrays.asList(results[0].getResults());
                }
                latch.countDown();
            }

            @Override
            public void onFullResult(ScanResult fullScanResult) {
            }

            @Override
            public void onPeriodChanged(int periodInMs) {
            }
        };
        final WifiScanner.ScanSettings settings = new WifiScanner.ScanSettings();
        settings.band = WifiScanner.WIFI_BAND_BOTH_WITH_DFS;
        mWifiScanner.startScan(settings, listener);
        try {
            latch.await(15, TimeUnit.SECONDS);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        return listScanResults();
    }

    private int listScanResults() {
        final PrintWriter pw = getOutPrintWriter();
        final List<ScanResult> results = mScanResults;
        if (results == null || results.isEmpty()) {
            pw.println("no networks found");
            return 0;
        }
        final List<ScanResult> sorted = new ArrayList<>(results);
        Collections.sort(sorted, new Comparator<ScanResult>() {
            @Override
            public int compare(ScanResult left, ScanResult right) {
                return right.level - left.level;
            }
        });
        for (ScanResult result : sorted) {
            final String ssid = result.SSID == null || result.SSID.isEmpty()
                    ? "<hidden>" : result.SSID;
            pw.println(String.format("%-24s %4d dBm  %s",
                    ssid, result.level, securityOf(result)));
        }
        return 0;
    }

    private static String securityOf(ScanResult result) {
        final String caps = result.capabilities;
        if (caps == null) {
            return "open";
        }
        if (caps.contains("WPA3")) {
            return "WPA3";
        }
        if (caps.contains("WPA2")) {
            return "WPA2";
        }
        if (caps.contains("WPA")) {
            return "WPA";
        }
        if (caps.contains("WEP")) {
            return "WEP";
        }
        return "open";
    }

    private int disconnect() {
        mClientModeImpl.disconnectCommand();
        getOutPrintWriter().println("disconnected");
        return 0;
    }

    private int status() {
        final PrintWriter pw = getOutPrintWriter();
        final WifiInfo info = mClientModeImpl.getWifiInfo();
        if (info == null || info.getNetworkId() == WifiConfiguration.INVALID_NETWORK_ID) {
            pw.println("not connected");
            return 0;
        }
        String ssid = info.getSSID();
        if (ssid != null && ssid.length() > 1
                && ssid.charAt(0) == '"' && ssid.charAt(ssid.length() - 1) == '"') {
            ssid = ssid.substring(1, ssid.length() - 1);
        }
        pw.println("ssid  " + ssid);
        pw.println("rssi  " + info.getRssi() + " dBm");
        return 0;
    }

'''

HELP = '''        pw.println("  scan");
        pw.println("    Scan for nearby networks and print them.");
        pw.println("  list-scan-results");
        pw.println("    Print the results of the last scan.");
        pw.println("  disconnect");
        pw.println("    Disconnect from the current network.");
        pw.println("  status");
        pw.println("    Print the current ssid and signal.");
'''

EDITS = [
    (
        "import android.net.wifi.WifiConfiguration;\n",
        "import android.net.wifi.ScanResult;\n"
        "import android.net.wifi.WifiConfiguration;\n"
        "import android.net.wifi.WifiInfo;\n",
    ),
    (
        "import java.util.Arrays;\n",
        "import java.util.ArrayList;\n"
        "import java.util.Arrays;\n"
        "import java.util.Collections;\n"
        "import java.util.Comparator;\n"
        "import java.util.List;\n",
    ),
    (
        "import java.util.concurrent.TimeUnit;\n",
        "import java.util.concurrent.CountDownLatch;\n"
        "import java.util.concurrent.TimeUnit;\n",
    ),
    (
        "    private final WifiCountryCode mWifiCountryCode;\n",
        "    private final WifiCountryCode mWifiCountryCode;\n"
        "    private final WifiScanner mWifiScanner;\n"
        "    private volatile List<ScanResult> mScanResults;\n",
    ),
    (
        "        mWifiCountryCode = wifiInjector.getWifiCountryCode();\n",
        "        mWifiCountryCode = wifiInjector.getWifiCountryCode();\n"
        "        mWifiScanner = wifiInjector.getWifiScanner();\n",
    ),
    (
        "                default:\n                    return handleDefaultCommands(cmd);\n",
        CASES + "                default:\n                    return handleDefaultCommands(cmd);\n",
    ),
    (
        "    @Override\n    public void onHelp() {\n",
        METHODS + "    @Override\n    public void onHelp() {\n",
    ),
    (
        '        pw.println("  connect-network <ssid> open|wpa2|wpa3 [passphrase]");\n'
        '        pw.println("    Connect to the specified network.");\n',
        '        pw.println("  connect-network <ssid> open|wpa2|wpa3 [passphrase]");\n'
        '        pw.println("    Connect to the specified network.");\n' + HELP,
    ),
]


def main():
    root = Path(sys.argv[1] if len(sys.argv) > 1 else ".")
    target = root / TARGET
    if not target.is_file():
        sys.exit("not found: %s" % target)

    text = target.read_text()
    if MARKER in text:
        print("already patched")
        return

    if "connect-network <ssid>" not in text:
        sys.exit("run apply-wifi-connect-network.py first")

    for anchor, replacement in EDITS:
        if text.count(anchor) != 1:
            sys.exit("anchor not unique (%d): %r" % (text.count(anchor), anchor[:60]))
        text = text.replace(anchor, replacement)

    target.write_text(text)
    print("patched %s" % target)


if __name__ == "__main__":
    main()
