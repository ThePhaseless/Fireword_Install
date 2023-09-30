#!/bin/bash
# Preparing SAMBA
echo "Preparing SAMBA..."
sudo apt install samba wsdd -y

echo "Creating SAMBA shares..."
# Add HDD_SAMBA_SHARE to config file
HDD_SAMBA_SHARE="\n
[HDD]
    path = $JBOD_PATH
    acl support = yes
    read only = no
    guest ok = yes
    browsable = yes
    writeable = yes
    public = yes"
# Check if the HDD_SAMBA_SHARE is already in the config file and add it if not
if grep -Fxq "[HDD]" /etc/samba/smb.conf; then
    echo "HDD_SAMBA_SHARE is already in the config file"
else
    echo "Adding HDD_SAMBA_SHARE to the config file..."
    echo -e $HDD_SAMBA_SHARE | sudo tee -a /etc/samba/smb.conf
fi

# Add SSD_SAMBA_SHARE to config file
SSD_SAMBA_SHARE="\n
[SSD]
    path = $SSD_PATH
    acl support = yes
    read only = no
    guest ok = yes
    browsable = yes
    writeable = yes
    public = yes"
# Check if the SSD_SAMBA_SHARE is already in the config file and add it if not
if grep -Fxq "[SSD]" /etc/samba/smb.conf; then
    echo "SSD_SAMBA_SHARE is already in the config file"
else
    echo "Adding SSD_SAMBA_SHARE to the config file..."
    echo -e $SSD_SAMBA_SHARE | sudo tee -a /etc/samba/smb.conf
fi

echo "Restarting SAMBA..."
sudo systemctl restart smbd
echo "Done..."
