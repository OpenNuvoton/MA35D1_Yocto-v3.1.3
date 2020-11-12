FILESEXTRAPATHS_prepend_nua3500 := "${THISDIR}/tf-a-nua3500:"

SECTION = "bootloaders"

LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://license.rst;md5=1dd070c98a281d18d9eefd938729b031"

SRC_URI = "git://github.com/NUA3500/arm-trusted-firmware-v2.3.git;protocol=https;nobranch=1"
SRCREV = "master"

TF_VERSION = "2.3"
PV = "${TF_VERSION}.r1"

S = "${WORKDIR}/git"
#B = "${WORKDIR}/build"

COMPATIBLE_MACHINE = "(nua3500)"

PACKAGE_ARCH = "${MACHINE_ARCH}"

FILESEXTRAPATHS_prepend := "${THISDIR}/tf-a-nua3500:"

inherit deploy

DEPENDS += "dtc-native"

SUMMARY = "Trusted Firmware-A for NUA3500"
LICENSE = "BSD-3-Clause"

PROVIDES += "virtual/trusted-firmware-a"

# Let the Makefile handle setting up the CFLAGS and LDFLAGS as it is
# a standalone application
CFLAGS[unexport] = "1"
LDFLAGS[unexport] = "1"
AS[unexport] = "1"
LD[unexport] = "1"

# Configure nua3500 make settings
PLATFORM = "${TFA_PLATFORM}"
export CROSS_COMPILE="${TARGET_PREFIX}"
export ARCH="arm64"
do_compile() {
	oe_runmake PLAT=${PLATFORM} -C ${S} realclean
	oe_runmake PLAT=${PLATFORM} -C ${S} all
	oe_runmake PLAT=${PLATFORM} -C ${S} fiptool
}

do_deploy() {
    install -Dm 0644 ${S}/build/${PLATFORM}/release/bl2.bin ${DEPLOYDIR}/${BOOT_TOOLS}/bl2-${PLATFORM}.bin
    install -Dm 0644 ${S}/build/${PLATFORM}/release/fdts/nua3500.dtb ${DEPLOYDIR}/${BOOT_TOOLS}/bl2-${PLATFORM}.dtb
    install -Dm 0644 ${S}/build/${PLATFORM}/release/bl31.bin ${DEPLOYDIR}/${BOOT_TOOLS}/bl31-${PLATFORM}.bin
    install -Dm 755 ${S}/tools/fiptool/fiptool  ${DEPLOYDIR}/${BOOT_TOOLS}/fiptool
}
addtask deploy after do_compile
