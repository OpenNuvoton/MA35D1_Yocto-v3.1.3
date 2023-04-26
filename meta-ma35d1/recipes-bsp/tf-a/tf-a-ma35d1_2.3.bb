FILESEXTRAPATHS_prepend_ma35d1 := "${THISDIR}/tf-a-ma35d1:"

SECTION = "bootloaders"

LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://license.rst;md5=1dd070c98a281d18d9eefd938729b031"

SRC_URI = "git://github.com/OpenNuvoton/MA35D1_arm-trusted-firmware-v2.3.git;branch=master;protocol=https"
SRC_URI += "file://${TFA_DDR_HEADER}"
SRCREV = "${TFA_SRCREV}"

TF_VERSION = "2.3"
PV = "${TF_VERSION}.r1"

S = "${WORKDIR}/git"
#B = "${WORKDIR}/build"

COMPATIBLE_MACHINE = "(ma35d1)"

PACKAGE_ARCH = "${MACHINE_ARCH}"

FILESEXTRAPATHS_prepend := "${THISDIR}/tf-a-ma35d1:"

inherit deploy

DEPENDS += "dtc-native"

SUMMARY = "Trusted Firmware-A for ma35d1"
LICENSE = "BSD-3-Clause"

PROVIDES += "virtual/trusted-firmware-a"

# Let the Makefile handle setting up the CFLAGS and LDFLAGS as it is
# a standalone application
CFLAGS[unexport] = "1"
LDFLAGS[unexport] = "1"
AS[unexport] = "1"
LD[unexport] = "1"

# Configure ma35d1 make settings
PLATFORM = "${TFA_PLATFORM}"
export CROSS_COMPILE="${TARGET_PREFIX}"
export ARCH="arm64"
do_compile() {

    TFA_OPT=" NEED_BL31=yes NEED_BL33=yes MA35D1_PMIC=${TFA_PMIC} MA35D1_CPU_CORE=${TFA_CPU_VOLTAGE}"
    if [ "${SECURE_BOOT}" = "yes" ]; then
        TFA_OPT="${TFA_OPT} FIP_DE_AES=1"
    fi
    if [ "${TFA_LOAD_M4}" = "yes" ]; then
        TFA_OPT="${TFA_OPT} NEED_SCP_BL2=yes"
    fi
    if ${@bb.utils.contains('MACHINE_FEATURES', 'optee', 'true', 'false', d)}; then
        TFA_OPT="${TFA_OPT} NEED_BL32=yes"
	if echo ${TFA_DTB} | grep -q "256"; then
            oe_runmake PLAT=${PLATFORM} ${TFA_OPT} -C ${S} realclean
            oe_runmake PLAT=${PLATFORM} ${TFA_OPT} -C ${S} all
            oe_runmake PLAT=${PLATFORM} ${TFA_OPT} -C ${S} fiptool
	elif echo ${TFA_DTB} | grep -q "128"; then
            oe_runmake PLAT=${PLATFORM} ${TFA_OPT} \
                MA35D1_DRAM_SIZE=0x07800000 \
                MA35D1_DDR_MAX_SIZE=0x8000000 \
                MA35D1_DRAM_S_BASE=0x87800000 \
                MA35D1_BL32_BASE=0x87800000 -C ${S} realclean
            oe_runmake PLAT=${PLATFORM} ${TFA_OPT} \
                MA35D1_DRAM_SIZE=0x07800000 \
                MA35D1_DDR_MAX_SIZE=0x8000000 \
                MA35D1_DRAM_S_BASE=0x87800000 \
                MA35D1_BL32_BASE=0x87800000 -C ${S} all
            oe_runmake PLAT=${PLATFORM} ${TFA_OPT} \
                MA35D1_DRAM_SIZE=0x07800000 \
                MA35D1_DDR_MAX_SIZE=0x8000000 \
                MA35D1_DRAM_S_BASE=0x87800000 \
                MA35D1_BL32_BASE=0x87800000-C ${S} fiptool
	elif echo ${TFA_DTB} | grep -q "512"; then
            oe_runmake PLAT=${PLATFORM} ${TFA_OPT} \
                MA35D1_DRAM_SIZE=0x1F800000 \
                MA35D1_DDR_MAX_SIZE=0x20000000 \
                MA35D1_DRAM_S_BASE=0x9F800000 \
                MA35D1_BL32_BASE=0x9F800000 -C ${S} realclean
            oe_runmake PLAT=${PLATFORM} ${TFA_OPT} \
                MA35D1_DRAM_SIZE=0x1F800000 \
                MA35D1_DDR_MAX_SIZE=0x20000000 \
                MA35D1_DRAM_S_BASE=0x9F800000 \
                MA35D1_BL32_BASE=0x9F800000 -C ${S} all
            oe_runmake PLAT=${PLATFORM} ${TFA_OPT} \
                MA35D1_DRAM_SIZE=0x1F800000 \
                MA35D1_DDR_MAX_SIZE=0x20000000 \
                MA35D1_DRAM_S_BASE=0x9F800000 \
                MA35D1_BL32_BASE=0x9F800000-C ${S} fiptool
	elif echo ${TFA_DTB} | grep -q "1g"; then
            oe_runmake PLAT=${PLATFORM} ${TFA_OPT} \
                MA35D1_DRAM_SIZE=0x3F800000 \
                MA35D1_DDR_MAX_SIZE=0x40000000 \
                MA35D1_DRAM_S_BASE=0xBF800000 \
                MA35D1_BL32_BASE=0xBF800000 -C ${S} realclean
            oe_runmake PLAT=${PLATFORM} ${TFA_OPT} \
                MA35D1_DRAM_SIZE=0x3F800000 \
                MA35D1_DDR_MAX_SIZE=0x40000000 \
                MA35D1_DRAM_S_BASE=0xBF800000 \
                MA35D1_BL32_BASE=0xBF800000 -C ${S} all
            oe_runmake PLAT=${PLATFORM} ${TFA_OPT} \
                MA35D1_DRAM_SIZE=0x3F800000 \
                MA35D1_DDR_MAX_SIZE=0x40000000 \
                MA35D1_DRAM_S_BASE=0xBF800000 \
                MA35D1_BL32_BASE=0xBF800000-C ${S} fiptool
	elif echo ${TFA_DTB} | grep -q "custom"; then
            DSIZE=$(expr $(printf "%d\n" ${TFA_DDR_SIZE}) \- $(printf "%d\n" 0x800000))
            SBASE=$(expr $(printf "%d\n" ${TFA_DDR_SIZE}) \+ $(printf "%d\n" 0x7F800000))
            oe_runmake PLAT=${PLATFORM} ${TFA_OPT} \
                MA35D1_DRAM_SIZE=${DSIZE} \
                MA35D1_DDR_MAX_SIZE=${TFA_DDR_SIZE} \
                MA35D1_DRAM_S_BASE=${SBASE} \
                MA35D1_BL32_BASE=${SBASE} -C ${S} realclean
            oe_runmake PLAT=${PLATFORM} ${TFA_OPT} \
                MA35D1_DRAM_SIZE=${DSIZE} \
                MA35D1_DDR_MAX_SIZE=${TFA_DDR_SIZE} \
                MA35D1_DRAM_S_BASE=${SBASE} \
                MA35D1_BL32_BASE=${SBASE} -C ${S} all
            oe_runmake PLAT=${PLATFORM} ${TFA_OPT} \
                MA35D1_DRAM_SIZE=${DSIZE} \
                MA35D1_DDR_MAX_SIZE=${TFA_DDR_SIZE} \
                MA35D1_DRAM_S_BASE=${SBASE} \
                MA35D1_BL32_BASE=${SBASE} -C ${S} fiptool
	fi
    else
       oe_runmake PLAT=${PLATFORM} ${TFA_OPT} -C ${S} realclean
       oe_runmake PLAT=${PLATFORM} ${TFA_OPT} -C ${S} all
       oe_runmake PLAT=${PLATFORM} ${TFA_OPT} -C ${S} fiptool
    fi
}

do_compile_prepend() {
    if echo ${TFA_DTB} | grep -q "custom"; then
        cp ${WORKDIR}/${TFA_DDR_HEADER} ${S}/plat/nuvoton/ma35d1/include/custom_ddr.h
    fi
}

do_deploy() {
    install -Dm 0644 ${S}/build/${PLATFORM}/release/bl2.bin ${DEPLOYDIR}/${BOOT_TOOLS}/bl2-${PLATFORM}.bin
    install -Dm 0644 ${S}/build/${PLATFORM}/release/fdts/${TFA_DTB}.dtb ${DEPLOYDIR}/${BOOT_TOOLS}/bl2-${PLATFORM}.dtb
    install -Dm 0644 ${S}/build/${PLATFORM}/release/bl31.bin ${DEPLOYDIR}/${BOOT_TOOLS}/bl31-${PLATFORM}.bin
    install -Dm 755 ${S}/tools/fiptool/fiptool  ${DEPLOYDIR}/${BOOT_TOOLS}/fiptool
}
addtask deploy after do_compile
