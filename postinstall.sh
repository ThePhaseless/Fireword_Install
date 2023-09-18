#!/bin/bash

# Post-Installation Script
# ------------------------
# This script automates the setup of a fresh system by installing and configuring
#
# Author: ThePhaseless
# Date:   September 18, 2023
#

# use sudo without password
sudo echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER

# Update the package list and upgrade existing packages
sudo apt update
sudo apt upgrade -y

# Install Zsh and Oh-My-Zsh
sudo apt install zsh -y
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Set Zsh as the default shell
chsh -s $(which zsh)

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
