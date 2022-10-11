SUMMARY = "dcultrafb.ko for kernel framebuffer"
SECTION = "modules"
LICENSE = "CLOSED"

SRC_URI += " \
    file://dcultrafb.ko_5.4.181 \
    file://dcultrafb.ko_5.10.140 \
    "
do_package_qa[noexec] = "1"
do_install() {
    install -d ${D}/${base_libdir}/modules/${PREFERRED_VERSION_linux-ma35d1}
    install -m 0644 ${WORKDIR}/dcultrafb.ko_${PREFERRED_VERSION_linux-ma35d1} \
		${D}/${base_libdir}/modules/${PREFERRED_VERSION_linux-ma35d1}/dcultrafb.ko
}

FILES_SOLIBSDEV = ""
FILES_${PN} = "${base_libdir}/modules/${PREFERRED_VERSION_linux-ma35d1}/dcultrafb.ko"
PACKAGE_ARCH = "${MACHINE_ARCH}"
COMPATIBLE_MACHINE = "(ma35d1)"
