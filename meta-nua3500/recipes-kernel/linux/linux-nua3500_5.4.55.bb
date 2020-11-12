# Copyright (C) 2019-2020
# Copyright 2019-2020 Nuvoton
# Released under the MIT license (see COPYING.MIT for the terms)

SUMMARY = "Linux Kernel provided and supported by Nuvoton"
DESCRIPTION = "Linux Kernel provided and supported by Nuvoton nua3500"

inherit kernel

# We need to pass it as param since kernel might support more then one
# machine, with different entry points
NUA3500_KERNEL_LOADADDR = "0x80080000"
KERNEL_EXTRA_ARGS += "LOADADDR=${NUA3500_KERNEL_LOADADDR}"

LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=bbea815ee2795b2f4230826c0c6b8814"

SRCBRANCH = "linux-5.4.y"
LOCALVERSION = "-${SRCBRANCH}"
#KERNEL_SRC ?= "git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git;proctocl=git"
#SRC_URI = "${KERNEL_SRC};branch=${SRCBRANCH}"

KERNEL_SRC ?= "git://github.com/schung1218/nua3500-linux-5.4.y.git;protocol=https"
SRC_URI = "${KERNEL_SRC}"

SRCREV="${AUTOREV}"
S = "${WORKDIR}/git"
B = "${WORKDIR}/build"

DEPENDS += "openssl-native util-linux-native libyaml-native"
DEFAULT_PREFERENCE = "1"
# =========================================================================
# Kernel
# =========================================================================
# Kernel image type
KERNEL_IMAGETYPE = "Image"

do_configure_prepend() {
    bbnote "Copying defconfig"
    cp ${S}/arch/${ARCH}/configs/${KERNEL_DEFCONFIG} ${WORKDIR}/defconfig
}

COMPATIBLE_MACHINE = "(nua3500)"
