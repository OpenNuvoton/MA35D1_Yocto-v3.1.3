SUMMARY = "This is a python nuwriter for ma35d1 tool "

LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://LICENSE;md5=c6c9fe1e2e46a7177d5b9e8b4893f203"

inherit deploy native pypi setuptools3

SRCREV= "master"

SRC_URI = "git://github.com/OpenNuvoton/MA35D1_NuWriter.git;protocol=https;branch=master"
S = "${WORKDIR}/git"
B =  "${WORKDIR}/build"

PACKAGES = ""

SRC_URI += " file://header-nand.json \
             file://header-sdcard.json \
             file://header-spinand.json \
             file://pack-nand.json \
             file://pack-sdcard.json \
             file://pack-spinand.json \
             file://xusb.bin \
             file://ddrimg_tfa.bin \
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
    jq-native \
"

BBCLASSEXTEND = "native nativesdk"

do_compile(){
    pyinstaller --clean --win-private-assemblies ${S}/nuwriter.py -D -n nuwriter -y --distpath ${B}
}

do_install(){
    install -d ${D}${bindir}
    install -d ${D}${datadir}/nuwriter
    install -d ${D}${datadir}/nuwriter/ddrimg
    cp ${B}/nuwriter/nuwriter ${D}${bindir}/
    cp ${WORKDIR}/header-nand.json  ${D}${datadir}/nuwriter/
    cp ${WORKDIR}/header-sdcard.json  ${D}${datadir}/nuwriter/
    cp ${WORKDIR}/header-spinand.json  ${D}${datadir}/nuwriter/
    cp ${WORKDIR}/pack-nand.json  ${D}${datadir}/nuwriter/
    cp ${WORKDIR}/pack-spinand.json  ${D}${datadir}/nuwriter/
    cp ${WORKDIR}/pack-sdcard.json  ${D}${datadir}/nuwriter/
   
    cp ${S}/ddrimg/* ${D}${datadir}/nuwriter/ddrimg/ 
    cp ${WORKDIR}/xusb.bin  ${D}${datadir}/nuwriter/
    cp ${WORKDIR}/ddrimg_tfa.bin  ${D}${datadir}/nuwriter/
    cp ${WORKDIR}/xusb.bin  ${DEPLOYDIR}/${BOOT_TOOLS}/
    cp ${WORKDIR}/ddrimg_tfa.bin  ${DEPLOYDIR}/${BOOT_TOOLS}
}

do_deploy() {
    install -d ${DEPLOYDIR}/${BOOT_TOOLS}/nuwriter
    install -d ${DEPLOYDIR}/${BOOT_TOOLS}/nuwriter/ddrimg
    cp -rf ${B}/nuwriter/* ${DEPLOYDIR}/${BOOT_TOOLS}/nuwriter/
    cp ${WORKDIR}/header-nand.json  ${DEPLOYDIR}/${BOOT_TOOLS}/nuwriter/
    cp ${WORKDIR}/header-spinand.json  ${DEPLOYDIR}/${BOOT_TOOLS}/nuwriter/
    cp ${WORKDIR}/header-sdcard.json  ${DEPLOYDIR}/${BOOT_TOOLS}/nuwriter/
    cp ${WORKDIR}/pack-nand.json  ${DEPLOYDIR}/${BOOT_TOOLS}/nuwriter/
    cp ${WORKDIR}/pack-spinand.json  ${DEPLOYDIR}/${BOOT_TOOLS}/nuwriter/
    cp ${WORKDIR}/pack-sdcard.json  ${DEPLOYDIR}/${BOOT_TOOLS}/nuwriter/
    
    cp ${S}/ddrimg/* ${DEPLOYDIR}/${BOOT_TOOLS}/nuwriter/ddrimg/
    cp ${WORKDIR}/xusb.bin  ${DEPLOYDIR}/${BOOT_TOOLS}/nuwriter/
    cp ${WORKDIR}/ddrimg_tfa.bin  ${DEPLOYDIR}/${BOOT_TOOLS}/nuwriter/
    cp ${WORKDIR}/xusb.bin  ${DEPLOYDIR}/${BOOT_TOOLS}/
    cp ${WORKDIR}/ddrimg_tfa.bin  ${DEPLOYDIR}/${BOOT_TOOLS}/

}

FILES_${PN} = ""
addtask deploy after do_compile
INHIBIT_SYSROOT_STRIP = "1"
INSANK_SKIP_${PN}_append = "already-stripped"

