# MyPostInstall
## Description
This is a script that I use to install my favorite programs on my NAS machines. It is a work in progress and will be updated as I find new programs that I like. I am currently using this on Ubuntu. Uses

## Usage
### Environment Variables
The following environment variables are used in this script:
- `$CONFIG_DIR` - The directory to install programs to. Defaults to `/public/SSD/Config`
- `$MEDIA_DIR` - The directory to store media files. Defaults to `$RAID0_DIR/Media`
- `$RAID0_DIR` - The directory to store RAID0 files. Defaults to `/public/HDD`

### Running the Script
To use this script, simply run the following command:
```
curl -O https://raw.githubusercontent.com/ThePhaseless/MyPostInstall/master/install.sh && chmod +x install.sh && sudo ./install.sh
```

### General
- [x] [Git](https://git-scm.com/)