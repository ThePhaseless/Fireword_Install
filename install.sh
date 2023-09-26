#!/bin/bash
#
# Post-Installation Script
# ------------------------
# This script automates the setup of a fresh system by installing and configuring Ubuntu Server
#
# Author: ThePhaseless
# Date:   September 18, 2023
#

# Check if the script from git
if [ ! -d "$PWD/.git" ]; then
  echo "Please run this script from git"
  exit
fi

# Make sure that environment variables are set
default=False
if [ -z "$SSD_PATH" ]; then
  SSD_PATH="/public/SSD"
  default=True
fi

if [ -z "$RAID0_PATH" ]; then
  RAID0_PATH="/public/HDD"
  default=True
fi

if [ -z "$CONFIG_PATH" ]; then
  CONFIG_PATH="$SSD_PATH/Config"
  default=True
fi

if [ -z "$MEDIA_PATH" ]; then
  MEDIA_PATH="$RAID0_PATH/Media"
  default=True
fi

# Ask the user if the default environment variables should be used
if [ "$default" = True ]; then
  echo "The default environment variables are:"
  echo "SSD_PATH=$SSD_PATH"
  echo "RAID0_PATH=$RAID0_PATH"
  echo "CONFIG_PATH=$CONFIG_PATH"
  echo "MEDIA_PATH=$MEDIA_PATH"
  read -p "Do you want to use the default environment variables? (Y/n) " answer
  case $answer in
  [Nn]*)
    echo "Please set the environment variables and run the script again"
    exit
    ;;
  *) ;;
  esac
fi

# Make sure that the RAID0 directory exists
if [ ! -d "$RAID0_PATH" ]; then
  mkdir -p $RAID0_PATH
fi

# Make sure that the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root"
  exit 1
fi

# Set up Timezone
echo "Setting up Timezone..."
sudo timedatectl set-timezone Europe/Warsaw
echo "Done..."

# Update the package list and upgrade existing packages
apt update
apt upgrade -y

# Run create_raid0.sh
echo "Running create_raid0.sh..."
bash create_raid0.sh

# Install Zsh and Oh-My-Zsh
sudo apt install git zsh -y
sudo -u $USER sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Download ZSH config
echo "Downloading ZSH config..."
curl -fsSL https://raw.githubusercontent.com/ThePhaseless/MyPostInstall/main/.zshrc -o $CONFIG_PATH/.zshrc
echo "Done..."

# Set Zsh as the default shell
echo "Setting Zsh as the default shell..."
echo "Please enter your password"
sudo -u $USER chsh -s $(which zsh)

# Install and config rclone
echo "Installing rclone..."
curl https://rclone.org/install.sh | sudo bash
echo "Done..."

# Configure rclone
echo "Configuring rclone..."
echo "Please name the remote 'gdrive' and select 'Google Drive' as the storage provider"
rclone config

# Install Tailscale
echo "Installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh
echo "Done..."
tailscale up

# Install Github CLI
echo "Installing Github CLI..."
sudo apt install gh -y
echo "Done..."

gh auth login

# Turning off online wait service
echo "Turning off online wait service..."
systemctl disable systemd-networkd-wait-online.service
echo "Done..."

# Fix Wifi, add renderer: NetworkManager to /etc/netplan/00-installer-config.yaml after version: 2
echo "Fixing Wifi..."
apt install network-manager -y
sed -i 's/version: 2/version: 2\n  renderer: NetworkManager/' /etc/netplan/00-installer-config-wifi.yaml

# Add rclone to crontab daily
echo "Adding rclone to crontab..."
cp sync_backups.sh $CONFIG_PATH
# Check if rclone is already in crontab
if crontab -l | grep -q "sync_backups.sh"; then
  echo "rclone is already in crontab"
else
  echo "rclone is not in crontab"
  echo "Adding rclone to crontab..."
  echo "0 4 * * * bash $CONFIG_PATH/sync_backups.sh" | crontab -
fi
echo "Done..."

# Preparing SAMBA
echo "Preparing SAMBA..."
apt install samba wsdd -y

echo "Creating SAMBA shares..."
# Add HDD_SAMBA_SHARE to config file
HDD_SAMBA_SHARE="[HDD]\n
    path = $RAID0_PATH\n
    acl support = yes\n
    read only = no\n
    guest ok = yes\n
    browsable = yes\n
    writeable = yes\n
    public = yes\n
    "
# Check if the HDD_SAMBA_SHARE is already in the config file
if grep -Fxq "$HDD_SAMBA_SHARE" /etc/samba/smb.conf; then
  echo "HDD_SAMBA_SHARE is already in the config file"
else
  printf "$HDD_SAMBA_SHARE" | tee -a /etc/samba/smb.conf
fi

mkdir -p $RAID0_PATH
chown nobody:nogroup $RAID0_PATH
chmod 777 $RAID0_PATH

# Add SSD_SAMBA_SHARE to config file
SSD_SAMBA_SHARE="[SSD]\n
    path = \n
    acl support = yes\n
    read only = no\n
    guest ok = yes\n
    browsable = yes\n
    writeable = yes\n
    public = yes\n
    "
# Check if the SSD_SAMBA_SHARE is already in the config file
if grep -Fxq "$SSD_SAMBA_SHARE" /etc/samba/smb.conf; then
  echo "SSD_SAMBA_SHARE is already in the config file"
else
  printf "$SSD_SAMBA_SHARE" | tee -a /etc/samba/smb.conf
fi

mkdir -p /public/SSD
chown nobody:nogroup /public/SSD
chmod 777 /public/SSD

echo "Restarting SAMBA..."
systemctl restart smbd
echo "Done..."

# Add CONFIG_PATH and MEDIA_PATH to environment variables
echo "Adding CONFIG_PATH and MEDIA_PATH to environment variables..."
echo "export CONFIG_PATH=$CONFIG_PATH" >>$PWD/.zshrc
echo "export MEDIA_PATH=$MEDIA_PATH" >>$PWD/.zshrc
echo "export SSD_PATH=$SSD_PATH" >>$PWD/.zshrc
echo "export RAID0_PATH=$RAID0_PATH" >>$PWD/.zshrc
echo "Done..."

# Install dependencies
echo "Installing dependencies..."
apt install curl rsync btop -y
echo "Done..."

# Install Docker
echo "Installing Docker and Docker Compose..."
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
rm get-docker.sh
echo "Done..."

# Pull and run Portainer
echo "Pulling and running Portainer..."
docker volume create portainer_data
docker run -d -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v $CONFIG_PATH/Portainer:/data portainer/portainer-ce
echo "Done..."

# Allow for sudo without password
echo "Changing sudo settings..."
echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$USER

# Clean up unnecessary packages
echo "Cleaning up unnecessary packages..."
apt autoremove -y
echo "Done..."

# Ask the user if scirpt folder should be deleted
read -p "Do you want to delete the script folder? (Y/n) " answer
case $answer in
[Nn]*)
  echo "Skipping..."
  ;;
*)
  echo "Deleting..."
  rm -rf $PWD
  ;;
esac

echo "Post-Installation Script finished successfully!"
echo "It is recommended to reboot the system now"
