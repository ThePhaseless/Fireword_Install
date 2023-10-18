#!/bin/bash
# Install and config rclone
echo "Installing rclone..."
curl https://rclone.org/install.sh | sudo bash
echo "Done..."

# Configure rclone
echo "Configuring rclone..."
echo "Please name the remote 'gdrive' and select 'Google Drive' as the storage provider"
rclone config

# Add rclone to crontab daily
echo "Adding rclone to crontab..."
cp sync_backups.sh $CONFIG_PATH
# Check if rclone is already in crontab
if crontab -l | grep -q "sync_backups.sh"; then
    echo "rclone is already in crontab"
else
    echo "rclone is not in crontab"
    echo "Adding rclone to crontab..."
    echo "0 4 * * * bash $CONFIG_PATH/sync_backups.sh" | crontab -
fi
echo "Done..."
