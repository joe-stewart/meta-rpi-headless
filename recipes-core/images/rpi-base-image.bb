# =============================================================================
# rpi-base-image.bb — Top level image recipe for RPi headless builds.
# Pulls in rpi-headless-common.inc for the shared package list, then adds
# any board-specific packages. Currently includes bcm43456 wifi firmware
# for RPi4 compatibility. CM4 ignores it — no wifi hardware present.
# Build with: bitbake rpi-base-image
# =============================================================================

SUMMARY = "Minimal headless RPi image — every package explicit"
LICENSE = "MIT"

inherit image

require rpi-headless-common.inc

deltask do_populate_sdk
deltask do_populate_sdk_ext

# --- RPi specific packages --------------------------------------------------
IMAGE_INSTALL += "\
    linux-firmware-rpidistro-bcm43456 \
"

IMAGE_FSTYPES = "ext4"
IMAGE_FSTYPES:append:rpi = " rpi-sdimg"
IMAGE_INSTALL:append:rpi = " udev-rules-rpi"
IMAGE_INSTALL += " picocom"

do_build:append() {
    bbwarn "Image built. Edit firstboot.ini and copy to the root partition before first boot."
}
