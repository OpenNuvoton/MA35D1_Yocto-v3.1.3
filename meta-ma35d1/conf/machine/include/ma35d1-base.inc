#@TYPE: Machine
#@NAME: ma35d1
#@DESCRIPTION: Configuration for all ma35d1 boards (EV, DK, ...)
#@NEEDED_BSPLAYERS: layers/meta-openembedded/meta-oe layers/meta-openembedded/meta-python

MACHINEOVERRIDES = "ma35d1"

# =========================================================================
# Chip architecture
# =========================================================================
DEFAULTTUNE_ma35d1 = "cortexa35"
include conf/machine/include/tune-cortexa35.inc

# =========================================================================
# Kernel
# =========================================================================
PREFERRED_PROVIDER_kernel = "linux-ma35d1"
PREFERRED_PROVIDER_virtual/kernel = "linux-ma35d1"

# =========================================================================
# u-boot
# =========================================================================
PREFERRED_PROVIDER_u-boot = "u-boot-ma35d1"
PREFERRED_PROVIDER_virtual/bootloader = "u-boot-ma35d1"

EXTRA_IMAGEDEPENDS += "virtual/bootloader"

UBOOT_ENTRYPOINT_ma35d1 = "0x80E00000"
# =========================================================================
# trusted-firmware-a
# =========================================================================
TFA_PLATFORM = "ma35d1"
PREFERRED_PROVIDER_virtual/trusted-firmware-a = "tf-a-ma35d1"
EXTRA_IMAGEDEPENDS += "virtual/trusted-firmware-a"

# =========================================================================
# optee-os
# =========================================================================
OPTEE_PLATFORM = "nuvoton"
OPTEE_PLATFORM_FLAVOR = "ma35d1"
PREFERRED_PROVIDER_virtual/optee-os = "optee-os-ma35d1"
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
#IMAGE_FSTYPES = " spinand sdcard nand ext2 tar.bz2 "
IMAGE_FSTYPES = " sdcard ext2 tar.bz2 "
IMAGE_CLASSES = "image_types_nvt"

# Block size for SPINAND, kb
SPINAND_BLKZ ?= "128"

# Block size for NAND, kb
NAND_BLKZ ?= "128"

# Disable the serial console due to auto-serial-console
SERIAL_CONSOLES = "115200;ttyS0"

# we do not want to have getty running on tty1 as we run
# auto-serial-console there
USE_VT = "0"

# Free size for SD card, kb
SDCARD_FREE_SIZE ?="0"

