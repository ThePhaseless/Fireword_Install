#!/bin/bash
#
# Post-Installation Proxy Script
# ------------------------
# This script automates the setup of a fresh proxy for server by installing and configuring Ubuntu Server
#
# Author: ThePhaseless
# Date:   September 28, 2023
#

# Check if the script from git
if [ ! -d "$PWD/.git" ]; then
    echo "Please run this script from git"
    exit
fi

# Install Tailscale
echo "Installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh
echo "Done..."
sudo tailscale up

# Install Docker
echo "Installing Docker and Docker Compose..."
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
rm get-docker.sh
echo "Done..."

# Copy proxy files
echo "Copying proxy config files..."
cp ./"Traefik Proxy"/* ~/Proxy/Traefik/config
cp ./proxy.env ~/Proxy/.env
cp ./proxy-compose.yml ~/Proxy/docker-compose.yml
echo "Done..."

# Copy upload_acme.sh and add it to crontab daily
echo "Copying upload_acme.sh..."
cp ./upload_acme.sh ~/Proxy/upload_acme.sh
echo "Done..."

echo "Adding upload_acme.sh to crontab..."
(
    crontab -l 2>/dev/null
    echo "0 0 * * * ~/Proxy/upload_acme.sh"
) | crontab -

docker-compose -f ~/Proxy/docker-compose.yml up -d
