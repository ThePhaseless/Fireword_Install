# MyPostInstall
## Description
This is a script that I use to install my favorite programs on my NAS machines. It is a work in progress and will be updated as I find new programs that I like. I am currently using this on Ubuntu. Uses

## Usage
### Environment Variables
The following environment variables are used in this script:
- `$SSD_DIR` - The directory to SSD SAMBA share. Defaults to `/public/SSD
- `$RAID0_DIR` - The directory to RAID0 SAMBA share. Defaults to `/public/HDD`
- `$CONFIG_DIR` - The directory to install programs to. Defaults to `$SSD_DIR/Config`
- `$MEDIA_DIR` - The directory to store media files. Defaults to `$RAID0_DIR/Media`


### Running the Script
To use this script, simply run the following command:
```
git clone https://github.com/ThePhaseless/MyPostInstall.git && cd MyPostInstall && sudo ./install.sh
```

### General
- [x] [Git](https://git-scm.com/)