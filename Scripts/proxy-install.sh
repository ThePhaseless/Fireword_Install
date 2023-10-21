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
sudo usermod -aG docker "$USER"

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
bash ./Scripts/setup_vscode.sh

# Install Zsh and Oh-My-Zsh
## For user
bash ./Scripts/setup_zsh.sh
## For root
sudo bash ./Scripts/setup_zsh.sh

export PROXY=true
export PROXY_GIT_REPO=$PWD

# Add Proxy environment variables if they don't exist
if grep -Fxq "export PROXY=true" /etc/zsh/zprofile; then
    echo "PROXY is already in the config file"
else
    echo "Adding PROXY to the config file..."
    echo "export PROXY=true" | sudo tee -a /etc/zsh/zprofile
fi

# Add Proxy Git Repo environment variables if they don't exist
if grep -Fxq "export PROXY_GIT_REPO=$PROXY_GIT_REPO" /etc/zsh/zprofile; then
    echo "PROXY_GIT_REPO is already in the config file"
else
    echo "Adding PROXY_GIT_REPO to the config file..."
    echo "export PROXY_GIT_REPO=$PROXY_GIT_REPO" | sudo tee -a /etc/zsh/zprofile
fi

echo "Please fill out the env file with your information..."
read -r -p "Press enter to continue of CTRL+C to cancel..."
nano Proxy/proxy.env

bash ./Scripts/update_traefik_conf.sh
bash ./Scripts/update_proxy_stack.sh

echo "Done..."
echo "Proxy setup complete! Don't forget to upload your acme.json file to server after the first certificate is generated."
echo "You can do this by running the following command:"
echo "bash $PWD/Scripts/upload_acme.sh"
