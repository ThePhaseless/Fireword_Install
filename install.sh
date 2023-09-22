#!/bin/bash
#
# Post-Installation Script
# ------------------------
# This script automates the setup of a fresh system by installing and configuring Ubuntu Server
#
# Author: ThePhaseless
# Date:   September 18, 2023
#

# Make sure that environment variables are set

default=0
if [ -z "$RAID0_DIR" ]; then
  RAID0_DIR="/public/HDD"
  default=True
fi

if [ -z "$CONFIG_DIR" ]; then
  CONFIG_DIR="/public/SSD/Config"
  default=True
fi

if [ -z "$MEDIA_DIR" ]; then
  MEDIA_DIR="$RAID0_DIR/Media"
  default=True
fi

# Ask the user if the default environment variables should be used
if [ "$default" = True ]; then
  echo "The default environment variables are:"
  echo "RAID0_DIR=$RAID0_DIR"
  echo "CONFIG_DIR=$CONFIG_DIR"
  echo "MEDIA_DIR=$MEDIA_DIR"
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
if [ ! -d "$RAID0_DIR" ]; then
  mkdir -p $RAID0_DIR
fi

# Make sure that the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root"
  exit 1
fi

# Update the package list and upgrade existing packages
apt update
apt upgrade -y

# Turning off online wait service
echo "Turning off online wait service..."
systemctl disable systemd-networkd-wait-online.service
echo "Done..."

# Turn off screen after 5 mins of inactivity
echo "Adding GRUB screen timeout..."
sed -i 's/GRUB_TIMEOUT=0/GRUB_TIMEOUT=300/' /etc/default/grub
update-grub
echo "Done..."

# Show disks to the user and ask which disks should be formated with btrfs and prepared to be used with RAID0 mounted to RAID0_DIR environment variable
# Don't worry, it will be backed up daily to the cloud
lsblk
echo "Which disks should be formated and prepared to be used with RAID0? (e.g., sda sdb sdc, none)"
read -p "Disks: " DISKS
for DISK in $DISKS; do
  if [ "$DISK" = "none" ]; then
    break
  fi
  mkfs.btrfs -f /dev/$DISK
  mkdir -p $RAID0_DIR
  mount /dev/$DISK $RAID0_DIR
done

# Install and config rclone
echo "Installing rclone..."
sudo -v
curl https://rclone.org/install.sh | sudo bash

# Configure rclone
rclone config create gdrive drive

# Add rclone to crontab daily
echo "Adding rclone to crontab..."
crontab -l | {
  cat
  echo "0 0 * * * rclone sync/public gdrive:Backup"
} | crontab -

# Preparing SAMBA
echo "Preparing SAMBA..."
apt install samba -y

echo "Creating SAMBA shares..."
printf "[HDD]\n
    path = $RAID0_DIR\n
    acl support = yes\n
    read only = no\n
    guest ok = yes\n
    browsable = yes\n
    writeable = yes\n
    public = yes\n
    " | tee -a /etc/samba/smb.conf
mkdir -p $RAID0_DIR
chown nobody:nogroup $RAID0_DIR
chmod 777 $RAID0_DIR

printf "[SSD]\n
    path = /public/SSD\n
    acl support = yes\n
    read only = no\n
    guest ok = yes\n
    browsable = yes\n
    writeable = yes\n
    public = yes\n
    " | tee -a /etc/samba/smb.conf
mkdir -p /public/SSD
chown nobody:nogroup /public/SSD
chmod 777 /public/SSD

echo "Restarting SAMBA..."
systemctl restart smbd
echo "Done..."

# Install dependencies
echo "Installing dependencies..."
apt install curl git rsync gh -y
echo "Done..."

# Install Tailscale
echo "Installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh
echo "Done..."

tailscale up

# Install Zsh and Oh-My-Zsh
apt install zsh -y
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Set Zsh as the default shell
chsh -s $(which zsh)

# Configure Zsh
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="refined"/' ~/.zshrc
sed -i 's/plugins=(git)/plugins=(git docker docker-compose catimg colored-man-pages colorize command-not-found compleat cp extract gh zsh-interactive-cd vscode ubuntu timer themes last-working-dir thefuck systemadmin screen safe-paste python pip)/' ~/.zshrc
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
docker run -d -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v $CONFIG_DIR/Portainer:/data portainer/portainer-ce
echo "Done..."

# Clean up unnecessary packages
echo "Cleaning up unnecessary packages..."
apt autoremove -y
echo "Done..."

echo "Post-Installation Script finished successfully!"
echo "The system will reboot in 5 seconds..."
sleep 5
reboot
