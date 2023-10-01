rclone sync $CONFIG_PATH/Fireword/Sonarr/Backups gDrive:Backups/$HOSTNAME/Fireword/Sonarr
rclone sync $CONFIG_PATH/Fireword/Radarr/Backups gDrive:Backups/$HOSTNAME/Fireword/Radarr
rclone sync $CONFIG_PATH/Fireword/Prowlarr/Backups gDrive:Backups/$HOSTNAME/Fireword/Prowlarr
rclone sync $CONFIG_PATH/Fireword/Bazarr/backup gDrive:Backups/$HOSTNAME/Fireword/Bazarr
rclone sync $CONFIG_PATH/Fireword/Recyclarr/configs gDrive:Backups/$HOSTNAME/Fireword/Recyclarr
rclone sync $CONFIG_PATH/Fireword/qBittorrent/config gDrive:Backups/$HOSTNAME/Fireword/qBittorrent
rclone sync $SSD_PATH gDrive:Backups/$HOSTNAME/Misc --exclude /Config/**
rclone sync $JBOD_PATH gDrive:Backups/$HOSTNAME/Misc --exclude /Downloads/**
