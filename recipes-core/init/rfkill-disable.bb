# =============================================================================
# rfkill-disable.bb — block all wireless radios at boot
# Belt and suspenders alongside config.txt dtoverlays
# =============================================================================

SUMMARY = "Block all wireless radios at boot via rfkill"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://rfkill-disable.service"

S = "${WORKDIR}"

inherit systemd

SYSTEMD_SERVICE:${PN} = "rfkill-disable.service"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"

do_install() {
    install -d ${D}${systemd_unitdir}/system/
    install -m 0644 ${WORKDIR}/rfkill-disable.service \
        ${D}${systemd_unitdir}/system/
}

FILES:${PN} = "${systemd_unitdir}/system/rfkill-disable.service"

RDEPENDS:${PN} = "rfkill"
