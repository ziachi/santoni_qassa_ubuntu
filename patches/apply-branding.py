#!/usr/bin/env python3
"""Rebrand the build: OTA zip name, maintainer and the recovery banner.

Two of the three strings live outside this device tree, so they cannot be
committed here:

- `vendor/qassa/config/branding.mk` builds the OTA zip name from the codename,
  the version number, the build type and the build date. The name is the ROM's
  identity, so it is spelled out as `qassa_ubuntu22-ziachi-santoni` instead.
- `build/make/tools/releasetools/edify_generator.py` prints the recovery banner.
  Its `PrintQASSABanner` ignored every argument it was given and printed a joke
  line; it now prints the build id, the build date and the security patch.

Usage:
    cd ~/qassa
    device/xiaomi/santoni/patches/apply-branding.py .

The script is idempotent and prints "already patched" on a second run.
"""

import sys
from pathlib import Path

BRANDING = Path("vendor/qassa/config/branding.mk")
EDIFY = Path("build/make/tools/releasetools/edify_generator.py")

BRANDING_OLD = """# Set all versions
QASSA_BUILD_CODENAME := Sisu
QASSA_VERSION_NUMBER := v2.4_0.s
"""
BRANDING_NEW = """# Set all versions
QASSA_BUILD_CODENAME := ubuntu22
QASSA_MAINTAINER := ziachi
QASSA_VERSION_NUMBER := v2.4_0.s
"""

VERSION_OLD = """ifeq ($(WITH_GAPPS), true)
QASSA_VERSION := qassa_$(QASSA_BUILD_CODENAME)-$(QASSA_VERSION_NUMBER)-$(QASSA_BUILD_TYPE)-$(QASSA_BUILD)-$(QASSA_BUILD_DATE)-GApps-signed
else
QASSA_VERSION := qassa_$(QASSA_BUILD_CODENAME)-$(QASSA_VERSION_NUMBER)-$(QASSA_BUILD_TYPE)-$(QASSA_BUILD)-$(QASSA_BUILD_DATE)-Vanilla-signed
endif
"""
VERSION_NEW = """# The zip name is the ROM's identity, so it is spelled out instead of being
# assembled from the version number and the build type. The build date is not
# part of it, so a new build overwrites the previous zip.
ifeq ($(WITH_GAPPS), true)
QASSA_VERSION := qassa_$(QASSA_BUILD_CODENAME)-$(QASSA_MAINTAINER)-$(QASSA_BUILD)-GApps
else
QASSA_VERSION := qassa_$(QASSA_BUILD_CODENAME)-$(QASSA_MAINTAINER)-$(QASSA_BUILD)
endif
"""

BANNER_OLD = '''  def PrintQASSABanner(self, QASSA_version, android_version, build_id, build_date,
                                  security_patch, device, prev_build_id=None,
                                  prev_build_date=None, prev_security_patch=None):
    self.Print("Yooo look at this dude, flashing Android 10 in 2026! [LAUGH]")
'''
BANNER_NEW = '''  def PrintQASSABanner(self, QASSA_version, android_version, build_id, build_date,
                                  security_patch, device, prev_build_id=None,
                                  prev_build_date=None, prev_security_patch=None):
    """Print the build details under the ROM banner from the device releasetools.

    The signature is fixed by the three call sites in ota_from_target_files;
    only the fields that are useful in recovery are printed.
    """
    self.Print("  Build: %s (%s)" % (build_id, build_date))
    self.Print("  Security patch: %s" % (security_patch,))
    if prev_build_id:
      self.Print("  Updating from: %s (%s)" % (prev_build_id, prev_build_date))
    self.Print("------------------------------------------")
'''


def replace(text, old, new, label, path):
    if old not in text:
        sys.exit("error: cannot find the %s block in %s" % (label, path))
    return text.replace(old, new, 1)


def main():
    if len(sys.argv) != 2:
        sys.exit("usage: apply-branding.py <aosp-root>")

    root = Path(sys.argv[1])
    branding = root / BRANDING
    edify = root / EDIFY
    for path in (branding, edify):
        if not path.is_file():
            sys.exit("error: %s not found" % path)

    branding_text = branding.read_text()
    if "QASSA_MAINTAINER" in branding_text:
        print("branding.mk: already patched")
    else:
        branding_text = replace(branding_text, BRANDING_OLD, BRANDING_NEW,
                                "version header", BRANDING)
        branding_text = replace(branding_text, VERSION_OLD, VERSION_NEW,
                                "QASSA_VERSION", BRANDING)
        branding.write_text(branding_text)
        print("branding.mk: patched")

    edify_text = edify.read_text()
    if "Yooo look at this dude" not in edify_text:
        print("edify_generator.py: already patched")
    else:
        edify_text = replace(edify_text, BANNER_OLD, BANNER_NEW,
                             "PrintQASSABanner", EDIFY)
        edify.write_text(edify_text)
        print("edify_generator.py: patched")


if __name__ == "__main__":
    main()
