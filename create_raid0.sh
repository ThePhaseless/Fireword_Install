#!/bin/bash
lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINT
echo "Which disks should be used with JBOD? (e.g., sda sdb sdc, none)"
read -p "Disks: " DISKS
if [ "$DISKS" = "none" ]; then
    echo "Skipping JBOD setup..."
else
    # Check if disks are specified
    if [ -z "$DISKS" ]; then
        echo "No disks specified..."
        exit 1
    fi

    # Check if disks are valid
    if [ -z "$JBOD_PATH" ]; then
        echo "JBOD_PATH = $JBOD_PATH"
        echo "JBOD_PATH not set..."
        exit 1
    fi

    echo "Setting up JBOD..."
    JBOD_disks_num=0
    JBOD_disks=""
    for DISK in $DISKS; do
        JBOD_disks="$JBOD_disks /dev/$DISK"
        JBOD_disks_num=$((JBOD_disks_num + 1))
    done
    # Create JBOD
    mdadm --create --verbose /dev/md0 --level=0 --raid-devices=$JBOD_disks_num $JBOD_disks
    # Create filesystem
    mkfs.ext4 -F /dev/md0
    # Mount JBOD
    mkdir -p $JBOD_PATH
    mount /dev/md0 $JBOD_PATH

    # Check if JBOD is already in fstab
    if grep -q "$JBOD_PATH" /etc/fstab; then
        echo "JBOD already in fstab..."
    else
        echo "Adding JBOD to fstab..."
        # Add JBOD to fstab
        echo "/dev/md0 $JBOD_PATH ext4 defaults 0 0" | tee -a /etc/fstab
        # Update initramfs
        echo "Updating initramfs..."
        systemctl daemon-reload
    fi

    echo "Done..."
fi
