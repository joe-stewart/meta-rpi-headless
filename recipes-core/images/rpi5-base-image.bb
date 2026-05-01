# =============================================================================
# rpi5-base-image.bb — RPi5 headless image
# Machine specific wrapper around rpi-headless-common.inc
# =============================================================================

SUMMARY = "Minimal headless RPi5 image — every package explicit"
LICENSE = "MIT"

inherit image

require rpi-headless-common.inc

deltask do_populate_sdk
deltask do_populate_sdk_ext

# --- RPi5 specific packages --------------------------------------------------
IMAGE_INSTALL += "\
    linux-firmware-rpidistro-bcm43456 \
"

# --- RPi5 specific files -----------------------------------------------------
SRC_URI += "\
    file://10-eth0.network \
    file://config.txt \
"

do_install:append() {
    install -d ${IMAGE_ROOTFS}/etc/systemd/network/
    install -m 0644 ${WORKDIR}/10-eth0.network \
        ${IMAGE_ROOTFS}/etc/systemd/network/

    install -d ${IMAGE_ROOTFS}/boot/
    install -m 0644 ${WORKDIR}/config.txt \
        ${IMAGE_ROOTFS}/boot/config.txt
}

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
