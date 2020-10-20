SUMMARY = "dcultrafb.ko for kernel framebuffer"
SECTION = "modules"
LICENSE = "CLOSED"

SRC_URI += " \
    file://dcultrafb.ko \
    "

do_package_qa[noexec] = "1"
do_install() {
    install -d ${D}/${libdir}/modules/
    install -m 0644 ${WORKDIR}/dcultrafb.ko ${D}/${libdir}/modules/dcultrafb.ko
}

FILES_SOLIBSDEV = ""
FILES_${PN} = "${libdir}/modules/dcultrafb.ko"
PACKAGE_ARCH = "${MACHINE_ARCH}"
COMPATIBLE_MACHINE = "(nua3500)"
