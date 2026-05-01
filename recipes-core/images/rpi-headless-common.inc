# =============================================================================
# rpi-headless-common.inc — shared package list for all RPi headless builds
# Included by rpi5-base-image.bb and eventually rpi4-base-image.bb
# =============================================================================

# No image features — we don't use the feature/package-group abstraction
IMAGE_FEATURES = ""

IMAGE_INSTALL = "\
    \
    base-files \
    base-passwd \
    shadow \
    shadow-base \
    \
    systemd \
    systemd-conf \
    systemd-serialgetty \
    \
    kernel-modules \
    linux-firmware \
    linux-firmware-rpidistro-bcm43455 \
    raspberrypi-firmware \
    raspberrypi-firmware-dt \
    \
    coreutils \
    util-linux \
    util-linux-fsck \
    util-linux-mount \
    e2fsprogs \
    e2fsprogs-e2fsck \
    e2fsprogs-resize2fs \
    \
    bash \
    bash-completion \
    \
    iproute2 \
    iproute2-ss \
    iproute2-tc \
    iptables \
    systemd-networkd \
    systemd-resolved \
    iputils-ping \
    \
    openssh \
    openssh-sshd \
    openssh-sftp-server \
    \
    systemd-timesyncd \
    \
    glibc \
    glibc-utils \
    libgcc \
    libstdc++ \
    \
    python3 \
    python3-core \
    python3-modules \
    python3-pip \
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
    parted \
    \
    rfkill \
    rfkill-disable \
    \
    tzdata \
"

# --- Filesystem --------------------------------------------------------------
IMAGE_ROOTFS_SIZE = "524288"
IMAGE_ROOTFS_EXTRA_SPACE = "524288"
IMAGE_FSTYPES = "ext4 rpi-sdimg"

# --- Root access -------------------------------------------------------------
inherit extrausers
EXTRA_USERS_PARAMS = "usermod -P '' root;"

# --- systemd units to enable -------------------------------------------------
SYSTEMD_AUTO_ENABLE:pn-systemd-networkd = "enable"
SYSTEMD_AUTO_ENABLE:pn-systemd-resolved = "enable"
SYSTEMD_AUTO_ENABLE:pn-openssh = "enable"
