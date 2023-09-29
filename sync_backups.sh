rclone sync local:$CONFIG_PATH/Fireword/Sonarr/Backups gDrive:Backups/$(HOSTNAME)/Fireword/Sonarr
rclone sync local:$CONFIG_PATH/Fireword/Radarr/Backups gDrive:Backups/$(HOSTNAME)/Fireword/Radarr
rclone sync local:$CONFIG_PATH/Fireword/Prowlarr/Backups gDrive:Backups/$(HOSTNAME)/Fireword/Prowlarr
rclone sync local:$CONFIG_PATH/Fireword/Bazarr/backup gDrive:Backups/$(HOSTNAME)/Fireword/Bazarr
rclone sync local:$CONFIG_PATH/Fireword/Recyclarr/configs gDrive:Backups/$(HOSTNAME)/Fireword/Recyclarr
rclone sync local:$CONFIG_PATH/Fireword/qBittorrent/config gDrive:Backups/$(HOSTNAME)/Fireword/qBittorrent
rclone sync local:$SSD_PATH gDrive:Backups/$(HOSTNAME)/Misc --exclude /Config/**
rclone sync local:$JBOD_PATH gDrive:Backups/$(HOSTNAME)/Misc --exclude /Downloads/**
