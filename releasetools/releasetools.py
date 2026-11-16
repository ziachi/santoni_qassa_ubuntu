import common

RULE = "=========================================="
THIN_RULE = "------------------------------------------"


def _print(info, *lines):
    for line in lines:
        info.script.AppendExtra('ui_print("%s");' % (line,))


def FullOTA_Assertions(info):
    _print(info,
           RULE,
           "  Qassa Ubuntu 22.04 for Xiaomi Redmi 4X (santoni)",
           "  Android 10 (Q) - still flashing in 2026",
           "  Maintainer: ziachi",
           RULE)


def FullOTA_PostValidate(info):
    _print(info,
           THIN_RULE,
           "  System and vendor written.",
           "  Writing boot image, then reboot to system.",
           "  github.com/ziachi - t.me/kalomakan",
           RULE)
