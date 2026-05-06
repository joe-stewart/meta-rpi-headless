# =============================================================================
# sudo-config.bb — Grants the sudo group full root access via sudoers.
# Any user added to the sudo group can run commands as root with a password.
# firstboot adds the new user to the sudo group during first boot setup.
# Note: root is locked after firstboot — sudo is the only path to root access.
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
