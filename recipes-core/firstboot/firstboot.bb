# =============================================================================
# firstboot.bb — First boot configuration service
# Processes /firstboot.ini on first boot, then removes it
# =============================================================================
SUMMARY = "First boot configuration service"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "\
    file://firstboot.sh \
    file://firstboot.ini.template \
    file://firstboot.service \
"

S = "${WORKDIR}"

inherit systemd

SYSTEMD_SERVICE:${PN} = "firstboot.service"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"

do_install() {
    # Install script
    install -d ${D}${sbindir}
    install -m 0755 ${WORKDIR}/firstboot.sh ${D}${sbindir}/firstboot.sh

    # Install template
    install -d ${D}${sysconfdir}
    install -m 0644 ${WORKDIR}/firstboot.ini.template ${D}${sysconfdir}/firstboot.ini.template

    # Install systemd unit
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/firstboot.service ${D}${systemd_system_unitdir}/firstboot.service
}

RDEPENDS:${PN} = "bash"

FILES:${PN} = "\
    ${sbindir}/firstboot.sh \
    ${sysconfdir}/firstboot.ini.template \
    ${systemd_system_unitdir}/firstboot.service \
"
