#!/bin/bash
# =============================================================================
# firstboot.sh — RPi Headless first boot configuration
# Runs once on first boot.
# Phase 1: system defaults — applied unconditionally
# Phase 2: user config — applied from /firstboot.ini if present
# =============================================================================

STAMP=/etc/firstboot.done
INI=/firstboot.ini
LOG="logger -t firstboot"

# Already ran, exit immediately
[ -f "$STAMP" ] && exit 0

$LOG "Starting first boot configuration"

# =============================================================================
# PHASE 1 — System defaults
# Applied once unconditionally. If you modify these manually later,
# firstboot will not overwrite them — you own your changes.
# =============================================================================

# --- TERM and PATH -----------------------------------------------------------
$LOG "Setting TERM and PATH defaults"
cat > /etc/profile.d/rpi-headless.sh << 'EOF'
export TERM=xterm-256color
export PATH=$PATH:/usr/sbin
EOF
chmod 644 /etc/profile.d/rpi-headless.sh

# --- Mask ttyS0 --------------------------------------------------------------
$LOG "Masking serial-getty@ttyS0.service"
systemctl mask serial-getty@ttyS0.service

# =============================================================================
# PHASE 2 — User configuration
# Reads /firstboot.ini if present. File is deleted after processing.
# To reconfigure: copy /etc/firstboot.ini.template to /firstboot.ini,
# edit it, delete /etc/firstboot.done and reboot.
# =============================================================================

if [ ! -f "$INI" ]; then
    $LOG "FIRSTBOOT ERROR: No /firstboot.ini found — locking root and shutting down"
    $LOG "Mount the card, create /firstboot.ini from /etc/firstboot.ini.template and reboot"
    passwd -l root
    [ -w /dev/ttyS0 ] && echo -e "\n\n*** FIRSTBOOT ERROR ***\nNo /firstboot.ini found.\nRoot locked. System shutting down.\nMount card, create /firstboot.ini from /etc/firstboot.ini.template and reboot.\n***\n" > /dev/ttyS0
    sleep 5
    systemctl poweroff
    exit 1
fi

# Parse ini helper
get_value() {
    local section=$1
    local key=$2
    sed -n "/^\[$section\]/,/^\[/p" "$INI" \
        | grep "^${key}=" \
        | cut -d= -f2- \
        | tr -d '[:space:]'
}

# --- User --------------------------------------------------------------------
USERNAME=$(get_value user username)
PASSWORD=$(get_value user password)
UID_VAL=$(get_value user uid)

if [ -n "$USERNAME" ]; then
    $LOG "Creating user $USERNAME"
    UID_OPT=""
    [ -n "$UID_VAL" ] && UID_OPT="-u $UID_VAL"
    useradd -m -s /bin/bash $UID_OPT -G sudo "$USERNAME"
    if [ -n "$PASSWORD" ]; then
        echo "$USERNAME:$PASSWORD" | chpasswd
        $LOG "Password set for $USERNAME"
    fi
fi

# --- SSH ---------------------------------------------------------------------
AUTHORIZED_KEYS=$(get_value ssh authorized_keys)

if [ -n "$AUTHORIZED_KEYS" ] && [ -n "$USERNAME" ]; then
    $LOG "Installing authorized_keys for $USERNAME"
    SSH_DIR=/home/$USERNAME/.ssh
    mkdir -p "$SSH_DIR"
    echo "$AUTHORIZED_KEYS" > "$SSH_DIR/authorized_keys"
    chown -R "$USERNAME:$USERNAME" "$SSH_DIR"
    chmod 700 "$SSH_DIR"
    chmod 600 "$SSH_DIR/authorized_keys"
fi

# --- Hostname ----------------------------------------------------------------
HOSTNAME=$(get_value hostname hostname)

if [ -n "$HOSTNAME" ]; then
    $LOG "Setting hostname to $HOSTNAME"
    echo "$HOSTNAME" > /etc/hostname
    hostnamectl set-hostname "$HOSTNAME"
fi

# --- Root --------------------------------------------------------------------
if [ -n "$USERNAME" ]; then
    $LOG "Locking root account"
    passwd -l root
fi

# --- Cleanup -----------------------------------------------------------------
$LOG "Removing /firstboot.ini"
rm -f "$INI"

$LOG "First boot configuration complete"
touch "$STAMP"
exit 0
