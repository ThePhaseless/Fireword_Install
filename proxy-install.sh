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

# Test if TailScale is installed, if not install
if ! [ -x "$(command -v tailscale)" ]; then
    # Install Tailscale
    echo "Installing Tailscale..."
    curl -fsSL https://tailscale.com/install.sh | sh
    echo "Done..."
    sudo tailscale up
else
    echo "Tailscale already installed..."
fi

# Test if Docker is installed, if not install
if ! [ -x "$(command -v docker)" ]; then
    # Install Docker
    echo "Installing Docker and Docker Compose..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    echo "Done..."
else
    echo "Docker already installed..."
fi

# Copy proxy files
echo "Copying proxy config files..."
mkdir -p ~/Proxy/Traefik/config
cp ./"Traefik Proxy"/* ~/Proxy/Traefik/config
cp ./proxy.env ~/Proxy/.env
cp ./proxy-compose.yml ~/Proxy/docker-compose.yml
echo "Done..."

# Copy upload_acme.sh and add it to crontab daily
echo "Copying upload_acme.sh..."
cp ./upload_acme.sh ~/Proxy/upload_acme.sh
echo "Done..."

# Check if upload_acme is in crontab, if not add it
if crontab -l | grep -q 'upload_acme.sh'; then
    echo "upload_acme.sh already in crontab..."
else
    echo "Adding upload_acme.sh to crontab..."
    (
        crontab -l 2>/dev/null
        echo "0 4 * * * ~/Proxy/upload_acme.sh"
    ) | crontab -
    echo "Done..."
fi

# Make upload_acme.sh executable
chmod +x ~/Proxy/upload_acme.sh

# Start proxy
docker-compose -f ~/Proxy/docker-compose.yml up -d

echo "Done..."
echo "Proxy setup complete! Don't forget to upload your acme.json file to server after the first certificate is generated."
echo "You can do this by running the following command:"
echo "~/Proxy/upload_acme.sh --force"
