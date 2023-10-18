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

script_dir=$PWD

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
    sudo sh get-docker.sh
    rm get-docker.sh
    echo "Done..."
else
    echo "Docker already installed..."
fi

# Check if upload_acme is in crontab, if not add it
echo "Checking if upload_acme.sh is in crontab..."
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

# Install VS Code
echo "Installing VS Code..."
./vscode-install.sh

# Make upload_acme.sh executable
chmod +x ~/Proxy/upload_acme.sh

cd ~/Proxy

# Ask user to fill out proxy.env
echo "Please fill out the proxy.env file in ~/Proxy/.env"
echo "You can press CTRL+Z to exit the editor and continue the script with fg and pressing enter"
echo "Press any key to continue..."

# Start proxy
sudo docker compose up -d -f proxy-compose.yml -e proxy.env

echo "Done..."
echo "Proxy setup complete! Don't forget to upload your acme.json file to server after the first certificate is generated."
echo "You can do this by running the following command:"
echo "~/Proxy/upload_acme.sh --force"
