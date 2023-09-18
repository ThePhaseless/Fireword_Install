#!/bin/bash
#
# Post-Installation Script
# ------------------------
# This script automates the setup of a fresh system by installing and configuring Ubuntu Server
#
# Author: ThePhaseless
# Date:   September 18, 2023
#

# Update the package list and upgrade existing packages
sudo apt update
sudo apt upgrade -y

# Show discs to the user and ask which discs should be formated with btrfs and prepared to be used with RAID0
lsblk
echo "Which discs should be formated and prepared to be used with RAID0? (e.g., sda sdb sdc)"
read -p "Discs: " DISCS
for DISC in $DISCS; do
    sudo mkfs.btrfs -f /dev/$DISC
    sudo mkdir -p /mnt/$DISC
    sudo mount /dev/$DISC /mnt/$DISC
done

# Install Zsh and Oh-My-Zsh
sudo apt install zsh -y
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Set Zsh as the default shell
chsh -s $(which zsh)

# Switch to the Zsh shell
zsh

# Install a nice Zsh theme (e.g., 'agnoster')
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/' ~/.zshrc

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo apt install docker-compose -y

# Pull and run Portainer
docker volume create portainer_data
docker run -d -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce

# Install Git
sudo apt install git -y

# Clean up unnecessary packages
sudo apt autoremove -y
