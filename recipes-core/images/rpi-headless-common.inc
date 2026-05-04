# =============================================================================
# rpi-headless-common.inc — shared package list for all RPi headless builds
# Included by rpi-base-image.bb
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
    \
    systemd \
    systemd-conf \
    systemd-serialgetty \
    \
	kernel-modules \
	linux-firmware \
	udev-rules-rpi \
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
    iptables \
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
MACHINE_HOSTNAME = "serial"

# --- Filesystem --------------------------------------------------------------
IMAGE_ROOTFS_SIZE = "524288"
IMAGE_ROOTFS_EXTRA_SPACE = "524288"
IMAGE_FSTYPES = "ext4 rpi-sdimg"

# --- Root access -------------------------------------------------------------
inherit extrausers
EXTRA_USERS_PARAMS = "\
    usermod -L root; \
    useradd -m -s /bin/bash -G sudo joe; \
    usermod -p '\$6\$g0sD6J4nAB9Zvzpj\$DEbLp35iGebt7jOcdhgZnMqxZpYYgNjluWVzKP10t7sEYRvYLVvjGtP64IbTQQZSt4Ed.QaT3hYmmN8u8GkME.' joe; \
"

# --- systemd units to enable -------------------------------------------------
SYSTEMD_AUTO_ENABLE:pn-systemd-networkd = "enable"
SYSTEMD_AUTO_ENABLE:pn-systemd-resolved = "enable"
SYSTEMD_AUTO_ENABLE:pn-openssh = "enable"
