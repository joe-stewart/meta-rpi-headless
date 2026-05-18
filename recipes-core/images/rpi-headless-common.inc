# =============================================================================
# rpi-headless-common.inc — Shared package list included by rpi-base-image.bb.
# Defines every package explicitly — no packagegroup abstraction.
# No busybox — replaced by coreutils, util-linux, bash and standard tools.
# User creation and hostname are handled by firstboot at runtime, not here.
# =============================================================================

# No image features — we don't use the feature/package-group abstraction
IMAGE_FEATURES = ""

IMAGE_INSTALL = "\
    \
    base-files \
    base-passwd \
    shadow \
    shadow-base \
    sudo \
    sudo-config \
    firstboot \
    \
    systemd \
    systemd-conf \
    systemd-serialgetty \
    \
    kernel-modules \
    linux-firmware \
    \
    coreutils \
    util-linux \
    util-linux-fsck \
    util-linux-mount \
    e2fsprogs \
    e2fsprogs-e2fsck \
    e2fsprogs-resize2fs \
    ncurses-terminfo-base \
    \
    bash \
    bash-completion \
    \
    iproute2 \
    iproute2-ss \
    iproute2-tc \
    iputils-ping \
    \
    openssh \
    openssh-sshd \
    openssh-sftp-server \
    \
    glibc \
    glibc-utils \
    libgcc \
    libstdc++ \
    \
    python3 \
    python3-core \
    python3-modules \
    \
    vim \
    vim-syntax \
    \
    procps \
    psmisc \
    strace \
    less \
    grep \
    sed \
    gawk \
    findutils \
    diffutils \
    file \
    which \
    \
    dosfstools \
    \
    tzdata \
"

# --- Filesystem --------------------------------------------------------------
IMAGE_ROOTFS_SIZE = "524288"
IMAGE_ROOTFS_EXTRA_SPACE = "524288"
IMAGE_FSTYPES = "ext4 rpi-sdimg"

# --- systemd units to enable -------------------------------------------------
SYSTEMD_AUTO_ENABLE:pn-systemd-networkd = "enable"
SYSTEMD_AUTO_ENABLE:pn-systemd-resolved = "enable"
SYSTEMD_AUTO_ENABLE:pn-openssh = "enable"
