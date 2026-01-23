# Copyright (C) 2019-2022
# Copyright 2019-2022 Nuvoton
# Released under the MIT license (see COPYING.MIT for the terms)

SUMMARY = "Linux Kernel provided and supported by Nuvoton"
DESCRIPTION = "Linux Kernel provided and supported by Nuvoton ma35h0"

inherit kernel

# We need to pass it as param since kernel might support more then one
# machine, with different entry points
ma35h0_KERNEL_LOADADDR = "0x80080000"
KERNEL_EXTRA_ARGS += "LOADADDR=${ma35h0_KERNEL_LOADADDR}"

LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=6bc538ed5bd9a7fc9398086aedcd7e46"

SRCBRANCH = "linux-5.10.y"
LOCALVERSION = "-${SRCBRANCH}"

KERNEL_SRC ?= "git://github.com/OpenNuvoton/MA35D1_linux-5.10.y.git;protocol=https"
SRC_URI = "${KERNEL_SRC}"

SRC_URI += " \
    file://optee.config \
    file://dts-reserve \
    file://ampipi.sh \
    file://cfg80211.config \
    "


SRC_URI += "${@bb.utils.contains('DISTRO_FEATURES', '88x2bu', ' file://88x2bu.ko', '', d)}"
SRC_URI += "${@bb.utils.contains('DISTRO_FEATURES', 'rt-patch', ' file://patch-5.10.140-rt73.patch', '', d)}"

SRCREV="${KERNEL_SRCREV}"
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
    cat ${WORKDIR}/cfg80211.config >> ${WORKDIR}/defconfig

    if [ "${TFA_LOAD_CORE1}" = "yes" ]; then
        for dtbf in ${KERNEL_DEVICETREE}; do
	    dt=$(echo $dtbf | sed 's/\.dtb/\.dts/')
            if [ "${TFA_CORE1_IPI}" = "yes" ]; then
                ${WORKDIR}/ampipi.sh ${S}/arch/${ARCH}/boot/dts/nuvoton/${TFA_PLATFORM}.dtsi
            fi
            ${WORKDIR}/dts-reserve ${S}/arch/${ARCH}/boot/dts/${dt} ${TFA_CORE1_BASE} ${TFA_CORE1_LEN}
        done
    fi

    if ${@bb.utils.contains('MACHINE_FEATURES', 'optee', 'true', 'false', d)}; then
        cat ${WORKDIR}/optee.config >> ${WORKDIR}/defconfig
    fi
}

do_deploy_append() {
    for dtbf in ${KERNEL_DEVICETREE}; do
        dtb=`normalize_dtb "$dtbf"`
        dtb_ext=${dtb##*.}
        dtb_base_name=`basename $dtb .$dtb_ext`
	ln -sf $dtb_base_name.dtb ${DEPLOYDIR}/Image.dtb
    done
}

do_install_append() {
    if [ -e ${WORKDIR}/88x2bu.ko ]; then
        install -d ${D}/${base_libdir}/modules/${PV}
        install -m 0644 ${WORKDIR}/88x2bu.ko ${D}/${base_libdir}/modules/${PV}/88x2bu.ko
    fi
}

FILES_${PN} += "${base_libdir}/modules/${PV}/${@bb.utils.contains('DISTRO_FEATURES', '88x2bu', '88x2bu.ko', '', d)}"
COMPATIBLE_MACHINE = "(ma35h0)"

