# =============================================================================
# rpi-config_git.bbappend — Strips comments and blank lines from config.txt
# at deploy time. The RPi bootloader has a file size limit that commented-out
# lines can exceed.
# Workaround: https://github.com/raspberrypi/firmware/issues/1948
# =============================================================================

do_deploy:append() {
    sed -i '/^#/d' ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt
    sed -i '/^$/d' ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt
}
