SUMMARY = "This is a python nuwriter for nua3500 tool "

LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://README;md5=01f0f27c23ca2525f860a07ca3dbfc7a"

inherit deploy native pypi setuptools3

SRCREV= "master"

SRC_URI = "git://github.com/NUA3500/nuwriter.git;protocol=https;branch=master"
S = "${WORKDIR}/git"
B =  "${WORKDIR}/build"

PACKAGES = ""

SRC_URI += " file://header.json \
             file://pack-nand.json \
             file://pack-sdcard.json \
             file://pack-spinand.json \
           "

DEPENDS += " \
    libusb1-native \
    pyinstaller-native \
    pyinstaller-hooks-contrib-native \
    python3-altgraph-native \
    python3-pyusb-native \
    python3-pycrypto-native \
    python3-crcmod-native \
    python3-tqdm-native \
    python3-crcmod-native \
    python3-ecdsa-native \
    python3-six-native \
"

BBCLASSEXTEND = "native nativesdk"

do_compile(){
    pyinstaller --clean --win-private-assemblies ${S}/nuwriter.py -D -n nuwriter -y --distpath ${B}
}

do_install(){
    install -d ${D}${bindir}
    install -d ${D}${datadir}/nuwriter
    cp ${B}/nuwriter/nuwriter ${D}${bindir}/
    cp ${WORKDIR}/header.json  ${D}${datadir}/nuwriter/
    cp ${WORKDIR}/pack-nand.json  ${D}${datadir}/nuwriter/
    cp ${WORKDIR}/pack-spinand.json  ${D}${datadir}/nuwriter/
    cp ${WORKDIR}/pack-sdcard.json  ${D}${datadir}/nuwriter/
}

do_deploy() {
    install -d ${DEPLOYDIR}/${BOOT_TOOLS}/nuwriter
    cp -rf ${B}/nuwriter/* ${DEPLOYDIR}/${BOOT_TOOLS}/nuwriter/
    cp ${WORKDIR}/header.json  ${DEPLOYDIR}/${BOOT_TOOLS}/nuwriter/
    cp ${WORKDIR}/pack-nand.json  ${DEPLOYDIR}/${BOOT_TOOLS}/nuwriter/
    cp ${WORKDIR}/pack-spinand.json  ${DEPLOYDIR}/${BOOT_TOOLS}/nuwriter/
    cp ${WORKDIR}/pack-sdcard.json  ${DEPLOYDIR}/${BOOT_TOOLS}/nuwriter/
}

FILES_${PN} = ""
addtask deploy after do_compile

INSANK_SKIP_${PN} += "already-stripped"
INSANK_SKIP_${PN}-native += "already-stripped"
INSANK_SKIP_nativesdk-${PN} += "already-stripped"

