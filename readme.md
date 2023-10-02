# MyPostInstall

## Description

This is a script that I use to install my favorite programs on my NAS machines. It is a work in progress and will be updated as I find new programs that I like. I am currently using this on Ubuntu. Uses

## Usage

### Environment Variables

The following environment variables are used in this script:

- `$SSD_PATH` - The directory to SSD SAMBA share. Defaults to `/public/SSD
- `$JBOD_PATH` - The directory to JBOD SAMBA share. Defaults to `/public/HDD`
- `$CONFIG_PATH` - The directory to install programs to. Defaults to `$SSD_PATH/Config`
- `$MEDIA_PATH` - The directory to store media files. Defaults to `$JBOD_PATH/Media`

### Running the Script

To use this script, simply run the following command:

#### On Main Machine

``` bash
git clone https://github.com/ThePhaseless/MyPostInstall.git && cd MyPostInstall && chmod +x install.sh && ./install.sh
```

#### On Proxy Machine

``` bash
git clone https://github.com/ThePhaseless/MyPostInstall.git && cd MyPostInstall && chmod +x proxy-install.sh && ./proxy-install.sh
```
