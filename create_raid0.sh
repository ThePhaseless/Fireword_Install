#!/bin/bash
lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINT
echo "Which disks should be used with RAID0? (e.g., sda sdb sdc, none)"
read -p "Disks: " DISKS
if [ "$DISKS" = "none" ]; then
    echo "Skipping RAID0 setup..."
else
    # Check if disks are specified
    if [ -z "$DISKS" ]; then
        echo "No disks specified..."
        exit 1
    fi

    # Check if disks are valid
    if [ -z "$RAID0_PATH" ]; then
        echo "RAID0_PATH not set..."
        exit 1
    fi

    echo "Setting up RAID0..."
    raid0_disks_num=0
    raid0_disks=""
    for DISK in $DISKS; do
        raid0_disks="$raid0_disks /dev/$DISK"
        raid0_disks_num=$((raid0_disks_num + 1))
    done
    # Create RAID0
    mdadm --create --verbose /dev/md0 --level=0 --raid-devices=$raid0_disks_num $raid0_disks
    # Create filesystem
    mkfs.ext4 -F /dev/md0
    # Mount RAID0
    mkdir -p $RAID0_PATH
    mount /dev/md0 $RAID0_PATH
    echo "/dev/md0 $RAID0_PATH btrfs defaults 0 0" | tee -a /etc/fstab
    # Update initramfs
    echo "Updating initramfs..."
    systemctl daemon-reload
    echo "Done..."
fi
