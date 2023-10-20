#!/bin/bash
#
# Post-Installation Script Installer
# ----------------------------------
git clone https://github.com/ThePhaseless/Fireword_Install.git
cd Fireword_Install
chmod +x fireword-install.sh
# Ask if this is a host or a proxy
echo "Is this a host or a proxy?"
echo "1. Host"
echo "2. Proxy"
read -p "Enter your choice: " choice
case $choice in
[1]*)
    bash ./Scripts/host-install.sh
    ;;
[2]*)
    bash ./Scripts/proxy-install.sh
    ;;
*)
    echo "Invalid choice"
    ;;
esac
