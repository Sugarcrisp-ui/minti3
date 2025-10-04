#!/bin/bash

# Ensure script is run as root
if [ "$(whoami)" != "root" ]; then
    echo "Error: This script must be run as root. Use sudo."
    exit 1
fi

# Variables (pass USER as env var or arg; default to current non-root user)
USER="${USER:-$(logname)}"  # Fallback to logname if not set
DRIVE_LABEL="backup"
DRIVE_UUID=$(blkid -s UUID -o value -l -t LABEL="$DRIVE_LABEL")
MOUNT_POINT="/media/$USER/backup"
CRYPT_NAME="luks_backup"
FSTYPE="ext4"
KEY_FILE="/root/luks_backup_key"

# Check if UUID is found
if [ -z "$DRIVE_UUID" ]; then
    echo "Error: No drive with label '$DRIVE_LABEL' found."
    exit 1
fi

# Check if key file exists, create if not
if [ ! -f "$KEY_FILE" ]; then
    echo "Creating LUKS key file..."
    dd if=/dev/urandom of="$KEY_FILE" bs=32 count=1
    chmod 600 "$KEY_FILE"
    cryptsetup luksAddKey "/dev/disk/by-uuid/$DRIVE_UUID" "$KEY_FILE"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to add LUKS key."
        exit 1
    fi
fi

# Add to /etc/crypttab
CRYPTTAB_ENTRY="$CRYPT_NAME UUID=$DRIVE_UUID $KEY_FILE luks"
if ! grep -q "$CRYPT_NAME" /etc/crypttab; then
    echo "$CRYPTTAB_ENTRY" >> /etc/crypttab
    echo "Added $CRYPT_NAME to /etc/crypttab."
else
    echo "$CRYPT_NAME already in /etc/crypttab."
fi

# Create mount point
mkdir -p "$MOUNT_POINT"
chown "$USER":"$USER" "$MOUNT_POINT"
chmod 755 "$MOUNT_POINT"

# Add to /etc/fstab
FSTAB_ENTRY="/dev/mapper/$CRYPT_NAME $MOUNT_POINT $FSTYPE defaults,user,exec 0 2"
if ! grep -q "$MOUNT_POINT" /etc/fstab; then
    echo "$FSTAB_ENTRY" >> /etc/fstab
    echo "Added $MOUNT_POINT to /etc/fstab."
else
    echo "$MOUNT_POINT already in /etc/fstab."
fi

# Update cryptsetup and test decryption
cryptdisks_start "$CRYPT_NAME"
if [ $? -ne 0 ]; then
    echo "Error: Failed to open LUKS device."
    exit 1
fi

# Test mount
mount -a
if [ $? -eq 0 ]; then
    echo "Mount successful at $MOUNT_POINT."
else
    echo "Error: Failed to mount $MOUNT_POINT."
    exit 1
fi

