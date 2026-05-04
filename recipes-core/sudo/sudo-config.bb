# =============================================================================
# sudo-config.bb — configure sudo group permissions
# =============================================================================
SUMMARY = "sudoers configuration granting sudo group full access"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

S = "${WORKDIR}"

ALLOW_EMPTY:${PN} = "1"

pkg_postinst:${PN}() {
    echo "%sudo ALL=(ALL:ALL) ALL" > $D${sysconfdir}/sudoers.d/sudo-group
    chmod 0440 $D${sysconfdir}/sudoers.d/sudo-group
}

RDEPENDS:${PN} = "sudo"
