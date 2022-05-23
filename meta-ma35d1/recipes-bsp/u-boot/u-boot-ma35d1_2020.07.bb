
DESCRIPTION = "ma35d1 U-Boot suppporting ma35d1 ev boards."
#SECTION = "bootloaders"
require recipes-bsp/u-boot/u-boot.inc

PROVIDES += "u-boot"
DEPENDS += "dtc-native bc-native flex-native bison-native u-boot-scr-ma35d1"

unset _PYTHON_SYSCONFIGDATA_NAME

LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://Licenses/gpl-2.0.txt;md5=b234ee4d69f5fce4486a80fdaf4a4263"

UBOOT_SRC ?= "git://github.com/MA35D1/u-boot-v2020.07.git;branch=master;protocol=https"

SRCBRANCH = "2020.07"
SRC_URI = "${UBOOT_SRC}"
SRCREV = "${UBOOT_SRCREV}"

SRC_URI += " file://uEnv-spinand-ubi.cfg \
             file://uEnv-nand-ubi.cfg \
           "
PV = "${SRCBRANCH}"
S = "${WORKDIR}/git"
B = "${WORKDIR}/build"

LOCALVERSION ?= "-${SRCBRANCH}"


do_compile_append() {
        unset i j
        for config in ${UBOOT_MACHINE}; do
            i=$(expr $i + 1);
            for type in ${UBOOT_CONFIG}; do
                j=$(expr $j + 1);
                if [ $j -eq $i ]
                then
                    if [ -n "${UBOOT_INITIAL_ENV}" ]; then
			if echo ${TFA_DTB} | grep -q "512"; then
                            sed -i "s/kernelmem=256M/kernelmem=512M/1" ${B}/${config}/u-boot-initial-env-${type}
                            if ${@bb.utils.contains('MACHINE_FEATURES', 'optee', 'true', 'false', d)}; then
                                sed -i "s/kernelmem=512M/kernelmem=504M/1" ${B}/${config}/u-boot-initial-env-${type}
                            fi
			elif echo ${TFA_DTB} | grep -q "256"; then
                            if ${@bb.utils.contains('MACHINE_FEATURES', 'optee', 'true', 'false', d)}; then
                                sed -i "s/kernelmem=256M/kernelmem=248M/1" ${B}/${config}/u-boot-initial-env-${type}
                            fi
			elif echo ${TFA_DTB} | grep -q "128"; then
                            sed -i "s/kernelmem=256M/kernelmem=128M/1" ${B}/${config}/u-boot-initial-env-${type}
                            if ${@bb.utils.contains('MACHINE_FEATURES', 'optee', 'true', 'false', d)}; then
                                sed -i "s/kernelmem=128M/kernelmem=120M/1" ${B}/${config}/u-boot-initial-env-${type}
                            fi
			elif echo ${TFA_DTB} | grep -q "1g"; then
                            sed -i "s/kernelmem=256M/kernelmem=1024M/1" ${B}/${config}/u-boot-initial-env-${type}
                            if ${@bb.utils.contains('MACHINE_FEATURES', 'optee', 'true', 'false', d)}; then
                                sed -i "s/kernelmem=1024M/kernelmem=1016M/1" ${B}/${config}/u-boot-initial-env-${type}
                            fi
                        fi

                        if [ "${type}" = "sdcard" ]; then
                            if [ "${config}" = "ma35d1_sdcard0_defconfig" ]; then
                                sed -i "s/mmc_block=mmcblk1p1/mmc_block=mmcblk0p1/1" ${B}/${config}/u-boot-initial-env-${type}
                            fi
                            if echo "${MACHINE}" | grep -q "iot"; then
                                sed -i "s/mmc_block=mmcblk1p1/mmc_block=mmcblk0p1/1" ${B}/${config}/u-boot-initial-env-${type}
                            fi
                        fi

                        ${B}/${config}/tools/mkenvimage -s 0x10000 -o ${B}/${config}/u-boot-initial-env.bin-${type} ${B}/${config}/u-boot-initial-env-${type}
                    fi
                fi
            done
            unset  j
        done
        unset  i
}

do_deploy_append() {
    if [ -n "${UBOOT_CONFIG}" ]
    then
        for config in ${UBOOT_MACHINE}; do
            i=$(expr $i + 1);
            for type in ${UBOOT_CONFIG}; do
                j=$(expr $j + 1);
                if [ $j -eq $i ]
                then
                    if [ -n "${UBOOT_INITIAL_ENV}" ]; then
                        ln -sf ${UBOOT_INITIAL_ENV}-${MACHINE}-${type}-${PV}-${PR} u-boot-env-${type}
                        cp ${B}/${config}/u-boot-initial-env.bin-${type} ${DEPLOY_DIR_IMAGE}/u-boot-initial-env.bin-${type}
                    fi
                fi

                if [ "${type}" = "spinand" ]; then
                   cp ${WORKDIR}/uEnv-spinand-ubi.cfg ${DEPLOY_DIR_IMAGE}/u-boot-initial-env-spinand-ubi.cfg
                elif [ "${type}" = "nand" ]; then
                   cp ${WORKDIR}/uEnv-nand-ubi.cfg ${DEPLOY_DIR_IMAGE}/u-boot-initial-env-nand-ubi.cfg
                fi
            done
            unset  j
        done
        unset  i
    fi
}

PACKAGE_ARCH = "${MACHINE_ARCH}"
COMPATIBLE_MACHINE = "(ma35d1)"
