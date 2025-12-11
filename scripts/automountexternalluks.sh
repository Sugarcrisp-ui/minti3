#!/bin/bash
# automountexternalluks.sh – 2025 final: safe, idempotent, zero surprises

set -euo pipefail
IFS=$'\n\t'

# Must be root
[[ $EUID -eq 0 ]] || { echo "Error: Run as root (sudo)"; exit 1; }

# User who owns the mount (passed via env or fallback to whoever is logged in)
USER="${USER:-$(logname 2>/dev/null || echo brett)}"
DRIVE_LABEL="backup"
MOUNT_POINT="/media/$USER/backup"
CRYPT_NAME="luks_backup"
KEY_FILE="/root/luks_backup_key"

echo "Setting up LUKS backup drive for user '$USER'..."

# 1. Find the drive
DRIVE_UUID=$(blkid -o value -s UUID -t LABEL="$DRIVE_LABEL") || {
    echo "Error: No drive with label '$DRIVE_LABEL' found"
    exit 1
}
echo "Found drive UUID=$DRIVE_UUID"

# 2. Ensure key file exists and is added to LUKS header
if [[ ! -f "$KEY_FILE" ]]; then
    echo "Creating new LUKS key file..."
    dd if=/dev/urandom of="$KEY_FILE" bs=32 count=1 >/dev/null
    chmod 600 "$KEY_FILE"
    cryptsetup luksAddKey "/dev/disk/by-uuid/$DRIVE_UUID" "$KEY_FILE" --key-file=- <<<"" >/dev/null
fi

# 3. /etc/crypttab – idempotent
if ! grep -q "^$CRYPT_NAME[[:space:]]" /etc/crypttab; then
    echo "$CRYPT_NAME UUID=$DRIVE_UUID $KEY_FILE luks,discard" >> /etc/crypttab
    echo "Added entry to /etc/crypttab"
else
    echo "/etc/crypttab already configured"
fi

# 4. /etc/fstab – idempotent
if ! grep -q "[[:space:]]$MOUNT_POINT[[:space:]]" /etc/fstab; then
    mkdir -p "$MOUNT_POINT"
    chown "$USER:$USER" "$MOUNT_POINT"
    echo "/dev/mapper/$CRYPT_NAME $MOUNT_POINT ext4 defaults,noatime,nofail 0 2" >> /etc/fstab
    echo "Added entry to /etc/fstab"
else
    echo "/etc/fstab already configured"
fi

# 5. Open + mount (idempotent)
if ! cryptsetup status "$CRYPT_NAME" &>/dev/null; then
    echo "Opening LUKS container..."
    cryptsetup luksOpen --key-file="$KEY_FILE" "/dev/disk/by-uuid/$DRIVE_UUID" "$CRYPT_NAME"
fi

if ! mountpoint -q "$MOUNT_POINT"; then
    echo "Mounting $MOUNT_POINT..."
    mount "$MOUNT_POINT"
fi

echo "LUKS backup drive ready at $MOUNT_POINT"
