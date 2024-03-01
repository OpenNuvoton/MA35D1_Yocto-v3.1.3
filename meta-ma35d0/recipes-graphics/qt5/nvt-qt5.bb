#  Copyright (C) 2020 Nuvoton Technology Corp - All Rights Reserved
DESCRIPTION = "add script and material to help with directfb qt configuration"
HOMEPAGE = "www.nuvoton.com"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"
DEPENDS = ""

SRC_URI = " \
    "

S = "${WORKDIR}"

inherit allarch

do_install() {
    install -d ${D}/${sysconfdir}/profile.d
    install -d ${D}${datadir}/qt5
}

RDEPENDS_${PN} = "qtbase"
FILES_${PN} += "${datadir}/qt5"
