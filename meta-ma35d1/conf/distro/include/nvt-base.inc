# ma35d1 DISTRO for the FrameBuffer graphical backend.

DISTRO = "nvt-base"
DISTRO_NAME = "Nuvoton Release Distro"
DISTRO_VERSION = "5.5-dunfell"

DISTRO_CODENAME = "dunfell"
SDK_VENDOR = "-pokysdk"
SDK_VERSION := "${DISTRO_VERSION}"

MAINTAINER = "Nuvoton <www.nuvoton.com>"

TARGET_VENDOR = "-poky"

DISTRO = "nvt-ma35d1"


PREFERRED_PROVIDER_udev = "systemd"
PREFERRED_PROVIDER_udev-utils = "systemd"


# =========================================================================
# DISTRO features
# =========================================================================
DISTRO_FEATURES ?= " vc8000 gc520 directfb virtualization systemd alsa"

CORE_IMAGE_EXTRA_INSTALL += " ${@bb.utils.contains('KERNEL_DEFCONFIG', 'ma35d1_drm_defconfig', '', 'dcultrafb', d)} "

VIRTUAL-RUNTIME_init_manager = "systemd"
DISTRO_FEATURES_BACKFILL_CONSIDERED += "sysvinit"

