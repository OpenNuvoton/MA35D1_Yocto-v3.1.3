SUMMARY = " pyinstaller_4.00 "

LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://COPYING.txt;md5=702f886187082d5370323fae257c8523"

inherit native pypi setuptools3

SRCREV= "19fb799a11d2d796fc8758808f873c40e2bf5118"

SRC_URI = "git://github.com/pyinstaller/pyinstaller.git;protocol=https;branch=master"
S = "${WORKDIR}/git"
B =  "${WORKDIR}/build"

BBCLASSEXTEND = "native nativesdk"

INHIBIT_SYSROOT_STRIP = "1"
INSANK_SKIP_${PN}_append = "already-stripped"
