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
  export SSD_PATH="/public/SSD"
  default=True
fi

if [ -z "$JBOD_PATH" ]; then
  export JBOD_PATH="/public/HDD"
  default=True
fi

if [ -z "$CONFIG_PATH" ]; then
  export CONFIG_PATH="$SSD_PATH/Config"
  default=True
fi

if [ -z "$MEDIA_PATH" ]; then
  export MEDIA_PATH="$JBOD_PATH/Media"
  default=True
fi

echo "Preparing directories..."
# Create directories
echo "Creating directories..."
sudo mkdir $CONFIG_PATH -p
sudo mkdir $MEDIA_PATH -p
sudo mkdir $SSD_PATH -p
sudo mkdir $JBOD_PATH -p

# Set permissions
echo "Setting permissions..."
sudo chmod 777 $CONFIG_PATH -R
sudo chmod 777 $MEDIA_PATH -R
sudo chmod 777 $SSD_PATH -R
sudo chmod 777 $JBOD_PATH -R

# Set ownership
echo "Setting ownership..."
sudo chown nobody:nogroup $MEDIA_PATH -R
sudo chown nobody:nogroup $JBOD_PATH -R
sudo chown nobody:nogroup $SSD_PATH -R
sudo chown nobody:nogroup $CONFIG_PATH -R
echo "Done..."

# Ask the user if the default environment variables should be used
if [ "$default" = True ]; then
  echo "The default environment variables are:"
  echo "SSD_PATH=$SSD_PATH"
  echo "JBOD_PATH=$JBOD_PATH"
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

# Set up Timezone
echo "Setting up Timezone..."
sudo timedatectl set-timezone Europe/Warsaw
echo "Done..."

# Update the package list and upgrade existing packages
sudo apt update
sudo apt upgrade -y

# Ask if the user wants to make a JBOD with raid0 or mergerfs or none
echo "Do you want to setup a disk array?"
echo "1) RAID0"
echo "2) MergerFS"
echo "other) None"
read -p "Choice: " choice
case $choice in
[1]*)
  sudo bash ./create_raid0.sh
  ;;
[2]*)
  sudo bash ./create_mergerfs.sh
  ;;
*)
  echo "Skipping..."
  ;;
esac

# Install Zsh and Oh-My-Zsh
sudo apt install git zsh -y
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Download ZSH config
echo "Downloading ZSH config..."
curl -fsSL https://raw.githubusercontent.com/ThePhaseless/MyPostInstall/main/.zshrc -o ~/.zshrc
echo "Done..."

# Set Zsh as the default shell
echo "Setting Zsh as the default shell..."
echo "Please enter your password"
sudo chsh -s $(which zsh) $USER

# Set ZSH as the default shell for root
echo "Setting Zsh as the default shell for root..."
sudo chsh -s $(which zsh) root

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
sudo tailscale up

# Install Github CLI
echo "Installing Github CLI..."
sudo apt install gh -y
echo "Done..."

gh auth login

# Ask to install vscode
read -p "Do you want to install vscode? (Y/n) " answer
case $answer in
[Nn]*)
  echo "Skipping..."
  ;;
*)
  ./install-vscode.sh
  ;;

esac

# Turning off online wait service
echo "Turning off online wait service..."
sudo systemctl disable systemd-networkd-wait-online.service
echo "Done..."

# Fix Wifi, add renderer: NetworkManager to /etc/netplan/00-installer-config.yaml after version: 2
echo "Fixing Wifi..."
sudo apt install network-manager -y
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
sudo apt install samba wsdd -y

echo "Creating SAMBA shares..."
# Add HDD_SAMBA_SHARE to config file
HDD_SAMBA_SHARE="[HDD]\n
    path = $JBOD_PATH\n
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

echo "Restarting SAMBA..."
sudo systemctl restart smbd
echo "Done..."

# Add CONFIG_PATH and MEDIA_PATH to environment variables
echo "Adding environment variables..."
# Check if envs are already in the config file
if grep -Fxq "CONFIG_PATH=$CONFIG_PATH" /etc/environment; then
  echo "CONFIG_PATH is already in the config file"
else
  echo "Adding CONFIG_PATH to the config file..."
  echo "CONFIG_PATH=$CONFIG_PATH" | tee -a /etc/environment
fi

if grep -Fxq "MEDIA_PATH=$MEDIA_PATH" /etc/environment; then
  echo "MEDIA_PATH is already in the config file"
else
  echo "Adding MEDIA_PATH to the config file..."
  echo "MEDIA_PATH=$MEDIA_PATH" | tee -a /etc/environment
fi

if grep -Fxq "SSD_PATH=$SSD_PATH" /etc/environment; then
  echo "SSD_PATH is already in the config file"
else
  echo "Adding SSD_PATH to the config file..."
  echo "SSD_PATH=$SSD_PATH" | tee -a /etc/environment
fi

if grep -Fxq "JBOD_PATH=$JBOD_PATH" /etc/environment; then
  echo "JBOD_PATH is already in the config file"
else
  echo "Adding JBOD_PATH to the config file..."
  echo "JBOD_PATH=$JBOD_PATH" | tee -a /etc/environment
fi
echo "Done..."

# Install dependencies
echo "Installing dependencies..."
sudo apt install curl rsync btop -y
echo "Done..."

# Check if docker is already installed
if [ -x "$(command -v docker)" ]; then
  # Install Docker
  echo "Installing Docker and Docker Compose..."
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh get-docker.sh
  rm get-docker.sh
  echo "Done..."
fi

# Add user to docker group
echo "Adding user to docker group..."
sudo groupadd docker
echo "Adding $USER to docker group..."
sudo usermod -aG docker $USER
echo "Done..."

# Pull and run Portainer
echo "Pulling and running Portainer..."
docker volume create portainer_data
docker run -d -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v $CONFIG_PATH/Portainer:/data portainer/portainer-ce
echo "Done..."

# Allow for sudo without password
echo "Removing password requirement for sudo..."
echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$USER
echo "Done..."

# Install screen_off.service
echo "Installing screen-off.service..."
sudo cp screen-off.service /etc/systemd/system
sudo cp screen-off.sh $CONFIG_PATH
sudo chmod +x $CONFIG_PATH/screen-off.sh
sudo chmod +x /etc/systemd/system/screen-off.service
sudo systemctl enable screen-off.service
echo "Done..."

# Clean up unnecessary packages
echo "Cleaning up unnecessary packages..."
sudo apt autoremove -y
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
