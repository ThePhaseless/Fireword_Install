#!/bin/bash
# Pull and run Portainer

# Import git links from setting.env
source ./setting.conf

# Import Category env for Traefik
source ./Host/traefik.env

# Check if running on proxy server or if --proxy flag is set
if [ -z "$PROXY" || "$PROXY" == "false" ]; then
    echo "PROXY is not set, using Host configuration"

    echo "Pulling Traefik configs"
    git clone $traefikRepo $CONFIG_PATH/$CATEGORY/config
    git pull

    echo "Done"
else
    echo "PROXY is set, using Proxy configuration"

    echo "Pulling Traefik configs"
    git clone $traefikRepo ./Proxy/Traefik/config
    git pull

    echo "Done"
fi
