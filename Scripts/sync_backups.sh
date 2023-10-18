echo "Syncing Backups..."
echo "Backing up Sonarr"
rclone sync $CONFIG_PATH/Fireword/Sonarr/Backups gDrive:Backups/$HOSTNAME/Fireword/Sonarr
echo "Backing up Radarr"
rclone sync $CONFIG_PATH/Fireword/Radarr/Backups gDrive:Backups/$HOSTNAME/Fireword/Radarr
echo "Backing up Prowlarr"
rclone sync $CONFIG_PATH/Fireword/Prowlarr/Backups gDrive:Backups/$HOSTNAME/Fireword/Prowlarr
echo "Backing up Bazarr"
rclone sync $CONFIG_PATH/Fireword/Bazarr/backup gDrive:Backups/$HOSTNAME/Fireword/Bazarr
echo "Backing up Recyclarr"
rclone sync $CONFIG_PATH/Fireword/Recyclarr/configs gDrive:Backups/$HOSTNAME/Fireword/Recyclarr
echo "Backing up qBittorrent"
rclone sync $CONFIG_PATH/Fireword/qBittorrent/config gDrive:Backups/$HOSTNAME/Fireword/qBittorrent
echo "Backing up SSD"
rclone sync $SSD_PATH gDrive:Backups/$HOSTNAME/Misc --exclude /Config/**
echo "Backing up HDD"
rclone sync $JBOD_PATH gDrive:Backups/$HOSTNAME/Misc --exclude /Downloads/**
