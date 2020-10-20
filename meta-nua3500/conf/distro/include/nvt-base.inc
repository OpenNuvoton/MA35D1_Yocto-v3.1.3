# NUA3500 DISTRO for the FrameBuffer graphical backend.

DISTRO = "nvt-base"
DISTRO_NAME = "Nuvoton Release Distro"
DISTRO_VERSION = "5.5-dunfell"

DISTRO_CODENAME = "dunfell"
SDK_VENDOR = "-pokysdk"
SDK_VERSION := "${DISTRO_VERSION}"

MAINTAINER = "Nuvoton <www.nuvoton.com>"

TARGET_VENDOR = "-poky"

DISTRO = "nvt-nua3500-fb"


PREFERRED_PROVIDER_udev = "systemd"
PREFERRED_PROVIDER_udev-utils = "systemd"


# =========================================================================
# DISTRO features
# =========================================================================
DISTRO_FEATURES = " dcultrafb gc520 directfb virtualization systemd "

