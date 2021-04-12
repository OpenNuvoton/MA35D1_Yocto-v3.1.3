SUMMARY = "dcultrafb.ko for kernel framebuffer"
SECTION = "modules"
LICENSE = "CLOSED"

SRC_URI += " \
    file://dcultrafb.ko \
    "
do_package_qa[noexec] = "1"
do_install() {
    install -d ${D}/${base_libdir}/modules/${KV}
    install -m 0644 ${WORKDIR}/dcultrafb.ko ${D}/${base_libdir}/modules/${KV}/dcultrafb.ko
}

FILES_SOLIBSDEV = ""
FILES_${PN} = "${base_libdir}/modules/${KV}/dcultrafb.ko"
PACKAGE_ARCH = "${MACHINE_ARCH}"
COMPATIBLE_MACHINE = "(ma35d1)"
