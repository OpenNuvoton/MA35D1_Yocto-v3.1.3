SUMMARY = "Eclipse IDE for Nuvoton"
LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://uninstall.sh;md5=5bbc99690ef3452ab8e1fc6744c1322c"

inherit native

SRC_URI = "https://www.nuvoton.com/opencms/resource-download.jsp?tp_GUID=SW1120200401185819;downloadfilename=nu-eclipse.tar.gz;name=nu-eclipse"
SRC_URI[nu-eclipse.md5sum] = "34746445962d68f6e622099b61772268"
SRC_URI[nu-eclipse.sha256sum] = "2b74bfdf414f7a8c316df41ce06d1279cc9b136e61b0692cad639a9af9755503"

S = "${WORKDIR}/NuEclipse_V1.01.017_Linux_Setup"

do_install() {
	install -d ${D}/${datadir}/nu-eclipse
	cp -r ${S}/. ${D}${datadir}/nu-eclipse
}

INSANE_SKIP_${PN} = "already-stripped file-rdeps sysroot_strip"
LLOW_EMPTY_${PN} = "1"

INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_SYSROOT_STRIP = "1"

