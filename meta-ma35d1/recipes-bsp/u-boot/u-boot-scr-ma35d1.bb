SUMMARY = "U-boot boot scripts for Nuvoton ma35d1"
LICENSE = "CLOSED"

DEPENDS = "u-boot-mkimage-native"

SRC_URI = "file://boot-sdcard.cmd \
           file://boot-spinand.cmd \
           file://boot-nand.cmd \
          "

do_compile() {
    mkimage -A arm -T script -C none -n "Boot script" -d "${WORKDIR}/boot-sdcard.cmd" boot-sdcard.scr
    mkimage -A arm -T script -C none -n "Boot script" -d "${WORKDIR}/boot-spinand.cmd" boot-spinand.scr
    mkimage -A arm -T script -C none -n "Boot script" -d "${WORKDIR}/boot-nand.cmd" boot-nand.scr
}

inherit deploy

do_deploy() {
    install -d ${DEPLOYDIR}
    install -m 0644 boot-sdcard.scr ${DEPLOYDIR}
    install -m 0644 boot-spinand.scr ${DEPLOYDIR}
    install -m 0644 boot-nand.scr ${DEPLOYDIR}
}

addtask do_deploy after do_compile before do_build
