SUMMARY = "GC520 library for DirectFB"
DEPENDS = "directfb"
SECTION = "libs"
LICENSE = "CLOSED"

RV = "1.7-7"

SRC_URI += " \
    file://libdirectfb_gal.so \
    file://libGAL.so \
    "
#do_package[noexec] = "1"
do_package_qa[noexec] = "1"
do_install() {
    install -d ${D}/${libdir}/directfb-${RV}/gfxdrivers/
    install -d ${D}/${libdir}/
    install -m 0755 ${WORKDIR}/libdirectfb_gal.so ${D}/${libdir}/directfb-${RV}/gfxdrivers/libdirectfb_gal.so
    install -m 0755 ${WORKDIR}/libGAL.so ${D}/${libdir}/libGAL.so
}

FILES_${PN} = "${libdir}/directfb-${RV}/gfxdrivers/libdirectfb_gal.so ${libdir}/libGAL.so"
PACKAGE_ARCH = "${MACHINE_ARCH}"
COMPATIBLE_MACHINE = "(nua3500)"
