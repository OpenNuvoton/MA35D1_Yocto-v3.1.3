SUMMARY = "python3-ecdsa "

LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://LICENSE;md5=66ffc5e30f76cbb5358fe54b645e5a1d"

inherit native pypi setuptools3

SRCREV= "f27b20ff2a67c6b1afe473dd347c8da5c4017e34"

SRC_URI = "git://github.com/warner/python-ecdsa.git;protocol=https;branch=master"
S = "${WORKDIR}/git"
B =  "${WORKDIR}/build"

BBCLASSEXTEND = "native nativesdk"
