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
    echo "Please run this script from git repo"
    exit
fi

# Add PROXY=true to environment variables
echo "Adding PROXY=true to environment variables..."

# Install Tailscale
echo "Installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh
echo "Done..."
sudo tailscale up

# Install Docker and Docker Compose
echo "Installing Docker and Docker Compose..."
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
rm get-docker.sh
sudo usermod -aG docker $USER

# Check if upload_acme is in crontab, if not add it
echo "Checking if upload_acme.sh is in crontab..."
if crontab -l | grep -q 'upload_acme.sh'; then
    echo "upload_acme.sh already in crontab..."
else
    echo "Adding upload_acme.sh to crontab..."
    (
        crontab -l 2>/dev/null
        echo "0 4 * * * $PWD/Scripts/upload_acme.sh"
    ) | crontab -
    echo "Done..."
fi

# Install VS Code
echo "Installing VS Code..."
bash ./Scripts/setup_vscode.sh

# Install Zsh and Oh-My-Zsh
## For user
bash ./Scripts/setup_zsh.sh
## For root
sudo bash ./Scripts/setup_zsh.sh

echo "PROXY=true" >>~/.zshrc

bash ./Scripts/update_traefik_conf.sh
bash ./Scripts/update_proxy_stack.sh

echo "Done..."
echo "Proxy setup complete! Don't forget to upload your acme.json file to server after the first certificate is generated."
echo "You can do this by running the following command:"
echo "bash $PWD/Scripts/upload_acme.sh"
