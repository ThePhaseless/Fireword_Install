rclone sync local:$CONFIG_PATH/Fireword/Sonarr/Backups gDrive:Backups/$(HOSTNAME)/Sonarr
rclone sync local:$CONFIG_PATH/Fireword/Radarr/Backups gDrive:Backups/$(HOSTNAME)/Radarr
rclone sync local:$CONFIG_PATH/Fireword/Prowlarr/Backups gDrive:Backups/$(HOSTNAME)/Prowlarr
rclone sync local:$CONFIG_PATH/Fireword/Bazarr/backup gDrive:Backups/$(HOSTNAME)/Bazarr
rclone sync local:$CONFIG_PATH/Fireword/Recyclarr/configs gDrive:Backups/$(HOSTNAME)/Recyclarr
rclone sync local:$CONFIG_PATH/Fireword/qBittorrent/config gDrive:Backups/$(HOSTNAME)/qBittorrent
rclone sync local:/public/SSD gDrive:Backups/$(HOSTNAME)/Misc --exclude /Config/**
rclone sync local:/public/HDD gDrive:Backups/$(HOSTNAME)/Misc --exclude /Downloads/**
