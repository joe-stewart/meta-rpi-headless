# =============================================================================
# qemu-base-image.bb — Top level image recipe for QEMU development builds.
# Pulls in rpi-headless-common.inc for the shared package list, then adds
# QEMU-specific configuration. Used to iterate on rootfs changes (firstboot,
# systemd, packages) without flashing hardware.
# Build with: bitbake qemu-base-image
# Run with: runqemu qemuarm64
# =============================================================================

SUMMARY = "Minimal headless image for QEMU development"
LICENSE = "MIT"

inherit image
inherit qemuboot

require rpi-headless-common.inc

deltask do_populate_sdk
deltask do_populate_sdk_ext

# --- QEMU specifics ----------------------------------------------------------
IMAGE_FSTYPES = "ext4"
