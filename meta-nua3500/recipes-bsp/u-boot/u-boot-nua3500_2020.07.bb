
DESCRIPTION = "NUA3500 U-Boot suppporting nua3500 ev boards."
#SECTION = "bootloaders"
require recipes-bsp/u-boot/u-boot.inc

PROVIDES += "u-boot"
DEPENDS += "dtc-native bc-native flex-native bison-native"

LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://Licenses/gpl-2.0.txt;md5=b234ee4d69f5fce4486a80fdaf4a4263"

UBOOT_SRC ?= "git://github.com/schung1218/nua3500-u-boot-v2020.07.git;protocol=https"

SRCBRANCH = "2020.07"
SRC_URI = "${UBOOT_SRC}"
SRCREV = "master"

PV = "${SRCBRANCH}"
S = "${WORKDIR}/git"
B = "${WORKDIR}/build"

LOCALVERSION ?= "-${SRCBRANCH}"

PACKAGE_ARCH = "${MACHINE_ARCH}"
COMPATIBLE_MACHINE = "(nua3500)"
