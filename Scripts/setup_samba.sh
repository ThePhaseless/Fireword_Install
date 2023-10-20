#!/bin/bash
# Run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Preparing SAMBA
echo "Preparing SAMBA..."
sudo apt install samba wsdd -y

# Check environment variables
echo "Checking environment variables..."
if [ -z "$JBOD_PATH" ]; then
    echo "JBOD_PATH is not set"
    # Ask user to set JBOD_PATH
    echo "Please enter the path to the JBOD or leave empty to /public/HDD"
    read -r JBOD_PATH
    if [ -z "$JBOD_PATH" ]; then
        JBOD_PATH="/public/HDD"
    fi
fi
if [ -z "$SSD_PATH" ]; then
    echo "SSD_PATH is not set"
    # Ask user to set SSD_PATH
    echo "Please enter the path to the SSD or leave empty to /public/SSD"
    read -r SSD_PATH
    if [ -z "$SSD_PATH" ]; then
        SSD_PATH="/public/SSD"
    fi
fi

echo "Creating SAMBA shares..."
# Add HDD_SAMBA_SHARE to config file
HDD_SAMBA_SHARE="[HDD]\n
    path = $JBOD_PATH\n
    acl support = yes\n
    read only = no\n
    guest ok = yes\n
    browsable = yes\n
    writeable = yes\n
    public = yes\n"
# Check if the HDD_SAMBA_SHARE is already in the config file and add it if not
if grep -Fxq "[HDD]" /etc/samba/smb.conf; then
    echo "HDD_SAMBA_SHARE is already in the config file"
else
    echo "Adding HDD_SAMBA_SHARE to the config file..."
    echo -e "$HDD_SAMBA_SHARE" >>/etc/samba/smb.conf
fi

# Add SSD_SAMBA_SHARE to config file
SSD_SAMBA_SHARE="[SSD]\n
    path = $SSD_PATH\n
    acl support = yes\n
    read only = no\n
    guest ok = yes\n
    browsable = yes\n
    writeable = yes\n
    public = yes\n"
# Check if the SSD_SAMBA_SHARE is already in the config file and add it if not
if grep -Fxq "[SSD]" /etc/samba/smb.conf; then
    echo "SSD_SAMBA_SHARE is already in the config file"
else
    echo "Adding SSD_SAMBA_SHARE to the config file..."
    echo -e "$SSD_SAMBA_SHARE" >>/etc/samba/smb.conf
fi

echo "Restarting SAMBA..."
sudo systemctl restart smbd
echo "Done..."
