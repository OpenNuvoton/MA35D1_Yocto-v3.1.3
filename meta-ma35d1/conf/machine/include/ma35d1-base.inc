#@TYPE: Machine
#@NAME: ma35d1
#@DESCRIPTION: Configuration for all ma35d1 boards (EV, DK, ...)
#@NEEDED_BSPLAYERS: layers/meta-openembedded/meta-oe layers/meta-openembedded/meta-python

MACHINEOVERRIDES = "ma35d1"

# =========================================================================
# Chip architecture
# =========================================================================
DEFAULTTUNE_ma35d1 = "cortexa35-crypto"
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
TFA_PLATFORM ?= "ma35d1"
TFA_DTB ?= "ma35d1xx7"
PREFERRED_PROVIDER_virtual/trusted-firmware-a = "tf-a-ma35d1"
EXTRA_IMAGEDEPENDS += "virtual/trusted-firmware-a"

# =========================================================================
# optee-os
# =========================================================================
OPTEE_PLATFORM = "nuvoton"
OPTEE_PLATFORM_FLAVOR = "MA35D1"
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
IMAGE_FSTYPES ?= " sdcard ext4 tar.bz2"
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

# SD auto-resizes to Max on first boot,
# A specific disk must be selected
DISK_DRIVE ?= "mmcblk0"
DISK_NUM ?= "p1"


# Use the expected value of the ubifs filesystem's volume name in the kernel
UBI_VOLNAME ?= "rootfs"
# The biggest NANDs on current modules are 100MB.
# This sums up to 2048 LEBs available for the ubifs (-c)
MKUBIFS_ARGS ?= "-F -m 2048 -e 126976 -c 2800"
UBINIZE_ARGS ?= "-m 2048 -p 128KiB -s 2048 -O 2048"


