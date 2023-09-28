#!/bin/bash
echo "Downloading VSCode CLI..."
sudo apt update
sudo apt install git -y

# Check architecture if arm or x86
echo "Checking architecture..."
if [ "$(uname -m)" = "x86_64" ]; then
    echo "Architecture is x86_64..."
    architecture="x64"

elif [ "$(uname -m)" = "aarch64" ]; then
    echo "Architecture is armv7l..."
    architecture="arm64"

else
    echo "Architecture is not supported..."
    exit
fi

curl -o vscode_cli.tar.gz "$(curl -s -L -I -o /dev/null -w '%{url_effective}' "https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-$architecture")"
tar -xvzf vscode_cli.tar.gz
rm vscode_cli.tar.gz

# Move to bin
echo "Moving VSCode CLI to /usr/local/bin..."
sudo mv ./code /usr/local/bin/code

# Set permissions
echo "Setting permissions..."
sudo chmod 777 /usr/local/bin/code

# Install service
echo "Installing VSCode service..."
sudo cp ./code.service /etc/systemd/system/code.service

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
