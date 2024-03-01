SUMMARY = "Add directfbrc to /etc"
LICENSE = "CLOSED"

SRC_URI = "file://directfbrc \
          "

S = "${WORKDIR}"

do_install() {
    install -d ${D}${sysconfdir}
    install -m 0755 directfbrc ${D}${sysconfdir}
}

FILES_${PN} = "${sysconfdir}/directfbrc"
