SUMMARY = "Add Qt5 bin dir to PATH"
LICENSE = "CLOSED"

SRC_URI = "file://qt5-env.sh \
           file://capture.sh \
          "

S = "${WORKDIR}"

do_install() {
    install -d ${D}${sysconfdir}/profile.d
    install -m 0755 qt5-env.sh ${D}${sysconfdir}/profile.d

    install -d ${D}/${bindir}
    install -m 0777 ${S}/capture.sh ${D}${bindir}/capture.sh
}

FILES_${PN} = "${sysconfdir} ${bindir}/capture.sh"
