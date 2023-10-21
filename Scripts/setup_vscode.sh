#!/bin/bash

# Check if code is already installed
if [ -x "$(command -v code)" ]; then
    echo "VSCode CLI is already installed..."
    echo "Updating VSCode CLI..."
    sudo code update
    exit
fi

echo "Downloading VSCode CLI..."
sudo apt update
sudo apt install git -y

# Check architecture if arm or x86
echo "Checking architecture..."
if [ "$(uname -m)" = "x86_64" ]; then
    echo "Architecture is x86_64..."
    architecture="x64"

elif [ "$(uname -m)" = "aarch64" ]; then
    echo "Architecture is arm64..."
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

# Install vscode web service
echo "Copying VSCode Web Service..."
sudo cp ./vscode.service /etc/systemd/system/vscode.service

# Reload daemon
echo "Reloading daemon..."
sudo systemctl daemon-reload

# Enable vscode service
echo "Enabling VSCode Web Service..."
sudo systemctl enable --now vscode.service

# Done
echo "Done..."
