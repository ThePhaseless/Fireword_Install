#!/bin/bash
echo "Downloading VSCode CLI..."
sudo apt update
sudo apt install git -y
curl -o vscode_cli_alpine_x64_cli.tar.gz "$(curl -s -L -I -o /dev/null -w '%{url_effective}' "https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64")"
tar -xvzf vscode_cli_alpine_x64_cli.tar.gz
rm vscode_cli_alpine_x64_cli.tar.gz

# Move to bin
echo "Moving VSCode CLI to /usr/local/bin..."
sudo mv ./code /usr/local/bin/code

# Set permissions
echo "Setting permissions..."
sudo chmod 777 /usr/local/bin/code

# Install service
echo "Installing VSCode service..."
cp ./code.service /etc/systemd/system/code.service

# Reload services
echo "Reloading services..."
sudo systemctl daemon-reload

# Enable service
echo "Enabling VSCode service..."
sudo systemctl enable code.service

# Start service
echo "Starting VSCode service..."
sudo systemctl start code.service

# Done
echo "Done..."
