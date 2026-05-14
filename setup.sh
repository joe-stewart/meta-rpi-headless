#!/bin/bash
# =============================================================================
# setup.sh — rpi-headless environment setup
# Clones poky, meta-openembedded, meta-raspberrypi, and meta-custom,
# creates shared cache directories, and seeds build-cm4 with
# populated bblayers.conf and local.conf.
#
# Usage: bash setup.sh
# Assumes: git, Yocto host dependencies already installed
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# =============================================================================
# Prompt
# =============================================================================

echo ""
echo "rpi-headless environment setup"
echo "================================"
echo ""

read -rp "Base directory [${HOME}/Development]: " BASE
BASE="${BASE:-${HOME}/Development}"
BASE="${BASE%/}"

echo ""
echo "Base directory: ${BASE}"
echo ""

# =============================================================================
# Shared cache directories
# =============================================================================

mkdir -p "${BASE}/shared/downloads"
mkdir -p "${BASE}/shared/sstate-cache"

# =============================================================================
# Layers
# =============================================================================

clone_all_layers "${BASE}"

# =============================================================================
# Build directory
# =============================================================================

BUILD_DIR="${BASE}/build-cm4"
CONF_DIR="${BUILD_DIR}/conf"

if [ -d "${CONF_DIR}" ]; then
    echo ""
    echo "  build-cm4/conf already exists — skipping"
    echo "  Remove ${CONF_DIR} and rerun to regenerate"
else
    echo ""
    echo "Creating build-cm4..."
    mkdir -p "${CONF_DIR}"
    write_bblayers "${CONF_DIR}" "${BASE}"
    write_local_conf "${CONF_DIR}" "${BASE}" "${BASE}/shared/sstate-cache"
    echo "  build-cm4/conf/bblayers.conf written"
    echo "  build-cm4/conf/local.conf written"
fi

# =============================================================================
# firstboot.ini
# =============================================================================

echo ""
echo "Generating firstboot.ini..."
write_firstboot_ini "${BASE}"

# =============================================================================
# Done
# =============================================================================

echo ""
echo "========================================"
echo "Setup complete."
echo ""
echo "Directory layout:"
echo "  ${BASE}/poky"
echo "  ${BASE}/meta-openembedded"
echo "  ${BASE}/meta-raspberrypi"
echo "  ${BASE}/meta-custom"
echo "  ${BASE}/shared/downloads"
echo "  ${BASE}/shared/sstate-cache"
echo "  ${BASE}/build-cm4/conf/"
echo "  ${BASE}/firstboot.ini"
echo ""
echo "Next steps:"
echo ""
echo "  1. Review BB_NUMBER_THREADS and PARALLEL_MAKE in:"
echo "       ${CONF_DIR}/local.conf"
echo ""
echo "  2. Source the build environment:"
echo "       source ${BASE}/poky/oe-init-build-env ${BUILD_DIR}"
echo ""
echo "  3. Build:"
echo "       bitbake rpi-base-image"
echo ""
echo "  4. Edit firstboot.ini with your username, password, SSH key and hostname:"
echo "       ${BASE}/firstboot.ini"
echo ""
echo "  5. Flash and copy firstboot.ini to the card:"
echo "       sudo dd if=tmp-glibc/deploy/images/${MACHINE}/rpi-base-image-${MACHINE}.rootfs.rpi-sdimg \\"
echo "               of=/dev/sdX bs=4M status=progress conv=fsync"
echo "       sudo mkdir -p /tmp/root"
echo "       sudo mount /dev/sdX2 /tmp/root"
echo "       sudo cp ${BASE}/firstboot.ini /tmp/root/firstboot.ini"
echo "       sudo umount /tmp/root"
echo ""
echo "  6. Boot the card."
echo "========================================"
