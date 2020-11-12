#@TYPE: Machine
#@NAME: nua3500
#@DESCRIPTION: Configuration for all NUA3500 boards (EV, DK, ...)
#@NEEDED_BSPLAYERS: layers/meta-openembedded/meta-oe layers/meta-openembedded/meta-python

MACHINEOVERRIDES = "nua3500"

# =========================================================================
# Chip architecture
# =========================================================================
DEFAULTTUNE_nua3500 = "cortexa35"
include conf/machine/include/tune-cortexa35.inc

# =========================================================================
# Kernel
# =========================================================================
PREFERRED_PROVIDER_kernel = "linux-nua3500"
PREFERRED_PROVIDER_virtual/kernel = "linux-nua3500"

# =========================================================================
# u-boot
# =========================================================================
PREFERRED_PROVIDER_u-boot = "u-boot-nua3500"
PREFERRED_PROVIDER_virtual/bootloader = "u-boot-nua3500"

EXTRA_IMAGEDEPENDS += "virtual/bootloader"

UBOOT_ENTRYPOINT_nua3500 = "0x80E00000"
# =========================================================================
# trusted-firmware-a
# =========================================================================
TFA_PLATFORM = "nua3500"
PREFERRED_PROVIDER_virtual/trusted-firmware-a = "tf-a-nua3500"
EXTRA_IMAGEDEPENDS += "virtual/trusted-firmware-a"

# =========================================================================
# optee-os
# =========================================================================
OPTEE_PLATFORM = "nuvoton"
OPTEE_PLATFORM_FLAVOR = "NUA3500"
PREFERRED_PROVIDER_virtual/optee-os = "optee-os-nua3500"
EXTRA_IMAGEDEPENDS += "virtual/optee-os"

# =========================================================================
# m4proj
# =========================================================================
EXTRA_IMAGEDEPENDS += "m4proj"

# =========================================================================
# nuwriter
# =========================================================================
EXTRA_IMAGEDEPENDS += "python3-nuwriter-native"

# =========================================================================
# fs
# =========================================================================
IMAGE_FSTYPES = " spinand sdcard nand ext2 tar.bz2 "
IMAGE_CLASSES = "image_types_nvt"

# Disable the serial console due to auto-serial-console
SERIAL_CONSOLES = "115200;ttyS0"

# we do not want to have getty running on tty1 as we run
# auto-serial-console there
USE_VT = "0"

