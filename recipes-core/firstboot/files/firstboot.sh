#!/bin/bash
# =============================================================================
# firstboot.sh — RPi Headless first boot configuration script
# Runs once on first boot, processes firstboot.ini from boot partition
# =============================================================================

STAMP=/etc/firstboot.done
INI=/firstboot.ini
LOG="logger -t firstboot"

# Already ran, exit immediately
[ -f "$STAMP" ] && exit 0

$LOG "Starting first boot configuration"

# No ini file — log and exit cleanly
if [ ! -f "$INI" ]; then
    $LOG "No /firstboot.ini found — skipping. See /etc/firstboot.ini.template to configure"
    touch "$STAMP"
    exit 0
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
$LOG "Removing firstboot.ini"
rm -f "$INI"

$LOG "First boot configuration complete"
touch "$STAMP"
exit 0
