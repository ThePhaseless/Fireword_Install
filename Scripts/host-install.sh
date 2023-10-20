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

# Check if not running as root
if [ "$EUID" -eq 0 ]; then
  echo "Please do not run this script as root"
  exit
fi

# Exit immediately if any command fails
set -e

# Function to set permissions and ownership
set_permissions_ownership() {
  sudo chmod 755 "$1" -R
  sudo chown nobody:nogroup "$1" -R
}

# Set default values for environment variables from fireword.env
if [ -f fireword.env ]; then
  echo "Using environment variables from fireword.env"
  export $(cat fireword.env | grep -v '#' | awk '/=/ {print $1}')
else
  echo "fireword.env not found, using default values"
fi

# Display default environment variables
echo "Using these environment variables:"
echo "SSD_PATH=$SSD_PATH"
echo "JBOD_PATH=$JBOD_PATH"
echo "CONFIG_PATH=$CONFIG_PATH"
echo "MEDIA_PATH=$MEDIA_PATH"

# Ask the user if the default environment variables should be used
read -p "Continue? (Y/n): " answer
case ${answer,,} in
n*)
  echo "Please set the environment variables and run the script again."
  exit
  ;;
esac

# Apply sudo patch
bash ./Scripts/setup_sudo_patch.sh

# Create directories
echo "Creating directories..."
for directory in "$CONFIG_PATH" "$MEDIA_PATH" "$SSD_PATH" "$JBOD_PATH"; do
  sudo mkdir -p "$directory"
  set_permissions_ownership "$directory"
done
echo "Directories created and permissions set."

# Set up Timezone
echo "Setting up Timezone..."
sudo timedatectl set-timezone $TIMEZONE
echo "Timezone set."

# Update the package list and upgrade existing packages
sudo apt update
sudo apt fully-upgrade
sudo apt dist-upgrade
sudo unattended-upgrades -d

# Ask if the user wants to make a JBOD with raid0 or mergerfs or none
echo "Do you want to setup a disk array?"
echo "1) RAID0"
echo "2) MergerFS"
echo "other) None"
read -p "Choice: " choice
case $choice in
[1]*)
  sudo bash ./Scripts/setup_RAID0.sh
  ;;
[2]*)
  sudo bash ./Scripts/setup_mergerfs.sh
  ;;
*)
  echo "Skipping..."
  ;;
esac

# Install Zsh and Oh-My-Zsh
## For user
bash ./Scripts/setup_zsh.sh

## For root
sudo bash ./Scripts/setup_zsh.sh

# Add CONFIG_PATH and MEDIA_PATH to environment variables
echo "Adding environment variables to /etc/zsh/zprofile..."

## Check if envs are already in the config file
if grep -Fxq "CONFIG_PATH=$CONFIG_PATH" /etc/zsh/zprofile; then
  echo "CONFIG_PATH is already in the config file"
else
  echo "Adding CONFIG_PATH to the config file..."
  echo "CONFIG_PATH=$CONFIG_PATH" | sudo tee -a /etc/zsh/zprofile
fi

if grep -Fxq "HOSTNAME=$HOSTNAME" /etc/zsh/zprofile; then
  echo "HOSTNAME is already in the config file"
else
  echo "Adding HOSTNAME to the config file..."
  echo "HOSTNAME=$HOSTNAME" | sudo tee -a /etc/zsh/zprofile
fi

if grep -Fxq "MEDIA_PATH=$MEDIA_PATH" /etc/zsh/zprofile; then
  echo "MEDIA_PATH is already in the config file"
else
  echo "Adding MEDIA_PATH to the config file..."
  echo "MEDIA_PATH=$MEDIA_PATH" | sudo tee -a /etc/zsh/zprofile
fi

if grep -Fxq "SSD_PATH=$SSD_PATH" /etc/zsh/zprofile; then
  echo "SSD_PATH is already in the config file"
else
  echo "Adding SSD_PATH to the config file..."
  echo "SSD_PATH=$SSD_PATH" | sudo tee -a /etc/zsh/zprofile
fi

if grep -Fxq "JBOD_PATH=$JBOD_PATH" /etc/zsh/zprofile; then
  echo "JBOD_PATH is already in the config file"
else
  echo "Adding JBOD_PATH to the config file..."
  echo "JBOD_PAT=$JBOD_PATH" | sudo tee -a /etc/zsh/zprofile
fi
echo "Done..."

bash ./Scripts/setup_rclone.sh

# Install Tailscale
echo "Installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh
echo "Done..."
sudo tailscale up

# Install Github CLI
echo "Installing Github CLI..."
sudo apt install gh -y
echo "Done..."
gh auth login

# Ask to install vscode
read -p "Do you want to install Visual Studio Code as a Web Service? (Y/n) " answer
case $answer in
[Nn]*)
  echo "Skipping..."
  ;;
*)
  bash ./Scripts/setup_vscode.sh
  ;;

esac

# Turning off online wait service
echo "Turning off online wait service..."
sudo systemctl disable systemd-networkd-wait-online.service
echo "Done..."

# Fix Wifi, add check comment, renderer: NetworkManager to /etc/netplan/00-installer-config.yaml after version: 2 and end comment
echo "Fixing Wifi..."
sudo apt install network-manager -y

# Check if the file is already modified
if grep -Fxq "# INSTALLATION SCRIPT DO NOT MODIFY" /etc/netplan/00-installer-config-wifi.yaml; then
  echo "File is already modified"
else
  echo "# INSTALLATION SCRIPT DO NOT MODIFY" | sudo tee /etc/netplan/00-installer-config-wifi.yaml
  sudo sed -i 's/version: 2/version: 2\n  renderer: NetworkManager/' /etc/netplan/00-installer-config-wifi.yaml
  echo "# END OF INSTALLATION SCRIPT" | sudo tee -a /etc/netplan/00-installer-config-wifi.yaml
fi

# Install samba
sudo bash ./setup_samba.sh

# Install dependencies
echo "Installing dependencies..."
sudo apt install curl rsync btop -y
echo "Done..."

echo "Installing docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
rm get-docker.sh
sudo usermod -aG docker $USER
echo "Done..."

# Install screen_off.service
echo "Installing screen-off.service..."
sudo cp ./Scripts/screen-off.service /etc/systemd/system/screen-off.service
sudo chmod +x /etc/systemd/system/screen-off.service

sudo systemctl enable screen-off.service
sudo systemctl start screen-off.service
echo "Done..."

# Clean up unnecessary packages
echo "Cleaning up unnecessary packages..."
sudo apt autoremove -y
echo "Done..."

echo "Do not remove this folder, it is used by the post-installation script."
echo "Post-Installation Script finished successfully!"
echo "It is recommended to reboot the system now."
echo "To configure containers, run"
echo "./Scripts/run_containers.sh"

echo "Refreshing groups..."
newgrp docker
