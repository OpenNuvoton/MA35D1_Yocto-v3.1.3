SUMMARY = "ma35d1-vc8000.ko for kernel & v4l2-decode application for MA35D1 VC8000"
SECTION = "modules & application"
LICENSE = "CLOSED"
inherit deploy

SRC_URI = "git://github.com/rawoul/v4l2-decode.git"
SRCREV = "ac6d2a0b785e7268460a29adaa2d4ca6dd07a1ea"

S = "${WORKDIR}/git"
B = "${WORKDIR}/build"

SRC_URI += " \
    file://ma35d1-vc8000.ko_5.4.181 \
    file://ma35d1-vc8000.ko_5.10.140 \
    file://0001-Add_VC8000.patch \
    "

do_package_qa[noexec] = "1"

do_compile () {
    cd  ${S}
    make
}

do_install() {
    install -d ${D}/${bindir}
    cp ${S}/vc8000-h264 ${D}/${bindir}/vc8000-h264
    install -d ${D}/${base_libdir}/modules/${PREFERRED_VERSION_linux-ma35d1}
    install -m 0644 ${WORKDIR}/ma35d1-vc8000.ko_${PREFERRED_VERSION_linux-ma35d1} \
		${D}/${base_libdir}/modules/${PREFERRED_VERSION_linux-ma35d1}/ma35d1-vc8000.ko
}

addtask do_install after do_compile
FILES_SOLIBSDEV = ""
FILES_${PN} = "${base_libdir}/modules/${PREFERRED_VERSION_linux-ma35d1}/ma35d1-vc8000.ko ${bindir}/vc8000-h264"
PACKAGE_ARCH = "${MACHINE_ARCH}"
COMPATIBLE_MACHINE = "(ma35d1)"

INSANE_SKIP_${PN} = " \
           dev-so \
           already-stripped \
           installed-vs-shipped \
           "
