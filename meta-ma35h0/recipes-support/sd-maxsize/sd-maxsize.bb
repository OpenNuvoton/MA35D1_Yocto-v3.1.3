SUMMARY = "SD Auto Expand Size To Max."
LICENSE = "CLOSED"

inherit systemd
SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE_${PN} = "resize.service"
SRC_URI += "file://resize.service \
           file://resize.sh \
          "
S = "${WORKDIR}"

do_install() {
    install -d ${D}/etc
    install -m 0755 ${S}/resize.sh ${D}/etc/resize.sh
    install -d ${D}${systemd_unitdir}/system
    install -m 0644 ${S}/resize.service ${D}${systemd_unitdir}/system
    sed -i -e 's#@DISKDRIVE@#${DISK_DRIVE}#g' \
           -e 's#@DISKNUM@#${DISK_NUM}#g' \
           ${D}${systemd_unitdir}/system/resize.service
}

FILES_${PN} = "${systemd_unitdir}/system/resize.service /etc/resize.sh"
