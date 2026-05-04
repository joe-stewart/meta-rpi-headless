# =============================================================================
# rpi-base-image.bb — RPi headless image
# Machine specific wrapper around rpi-headless-common.inc
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
