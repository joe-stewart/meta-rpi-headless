#!/bin/bash
# =============================================================================
# test.sh — rpi-headless clean build test
# Clones or verifies all layers, creates an isolated build-test directory
# with a clean sstate, runs a full build, and validates the output image.
#
# Intended to catch layer bugs before pushing. Downloads are shared with the
# dev environment to avoid re-fetching. sstate is kept separate so the test
# reflects a clean build from scratch.
#
# Usage: bash test.sh
# Assumes: git, Yocto host dependencies already installed
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

BUILD_NAME="build-test"
IMAGE="rpi-base-image"

# =============================================================================
# Prompt
# =============================================================================

echo ""
echo "rpi-headless clean build test"
echo "=============================="
echo ""

read -rp "Base directory [${HOME}/Development]: " BASE
BASE="${BASE:-${HOME}/Development}"
BASE="${BASE%/}"

echo ""
echo "Base directory: ${BASE}"
echo "Build directory: ${BASE}/${BUILD_NAME}"
echo "sstate: ${BASE}/shared/sstate-test  (isolated)"
echo "downloads: ${BASE}/shared/downloads  (shared)"
echo ""
read -rp "Continue? [y/N]: " CONFIRM
[[ "${CONFIRM}" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }

# =============================================================================
# Shared cache directories
# =============================================================================

mkdir -p "${BASE}/shared/downloads"
mkdir -p "${BASE}/shared/sstate-test"

# =============================================================================
# Layers
# =============================================================================

clone_all_layers "${BASE}"

echo ""
echo "Verifying layers..."
if ! check_layers "${BASE}"; then
    echo ""
    echo "ERROR: Missing layers — cannot continue"
    exit 1
fi
echo "  All layers present"

# =============================================================================
# Build directory
# =============================================================================

BUILD_DIR="${BASE}/${BUILD_NAME}"
CONF_DIR="${BUILD_DIR}/conf"

if [ -d "${CONF_DIR}" ]; then
    echo ""
    echo "  ${BUILD_NAME}/conf already exists — reusing"
    echo "  Remove ${CONF_DIR} to regenerate conf files"
else
    echo ""
    echo "Creating ${BUILD_NAME}..."
    mkdir -p "${CONF_DIR}"
    write_bblayers "${CONF_DIR}" "${BASE}"
    write_local_conf "${CONF_DIR}" "${BASE}" "${BASE}/shared/sstate-test"
    echo "  ${BUILD_NAME}/conf/bblayers.conf written"
    echo "  ${BUILD_NAME}/conf/local.conf written"
fi

# =============================================================================
# Build
# =============================================================================

echo ""
echo "Initialising build environment..."
# shellcheck disable=SC1091
source "${BASE}/poky/oe-init-build-env" "${BUILD_DIR}" > /dev/null

echo "Starting build: bitbake ${IMAGE}"
echo ""

START=$(date +%s)
bitbake "${IMAGE}"
END=$(date +%s)

ELAPSED=$(( END - START ))
MINUTES=$(( ELAPSED / 60 ))
SECONDS=$(( ELAPSED % 60 ))

# =============================================================================
# Validate
# =============================================================================

echo ""
echo "Validating output..."

IMAGE_PATH="${BUILD_DIR}/tmp-glibc/deploy/images/${MACHINE}/${IMAGE}-${MACHINE}.rootfs.rpi-sdimg"

if [ -f "${IMAGE_PATH}" ]; then
    SIZE=$(du -h "${IMAGE_PATH}" | cut -f1)
    echo ""
    echo "========================================"
    echo "PASS — image found"
    echo "  ${IMAGE_PATH}"
    echo "  Size: ${SIZE}"
    echo "  Build time: ${MINUTES}m ${SECONDS}s"
    echo "========================================"
    exit 0
else
    echo ""
    echo "========================================"
    echo "FAIL — image not found at expected path:"
    echo "  ${IMAGE_PATH}"
    echo "========================================"
    exit 1
fi
