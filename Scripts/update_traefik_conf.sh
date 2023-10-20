#!/bin/bash
# Pull and run Portainer

# Import git links from setting.env
source ./settings.conf

# Import Category env for Traefik
source ./Host/traefik.env

# Check if running on proxy server or if --proxy flag is set
if [ -z "$PROXY" || "$PROXY" == "false" ]; then

    echo "PROXY is not set, using Host configuration"
    echo "Pulling Traefik configs to $CONFIG_PATH/$CATEGORY/config"
    git clone $traefikRepo $CONFIG_PATH/$CATEGORY/config
    git pull $CONFIG_PATH/$CATEGORY/config

    echo "Done"
else
    echo "PROXY is set, using Proxy configuration"

    echo "Pulling Traefik configs from $traefikRepo to ./Proxy/Traefik/config"
    git clone $traefikRepo ./Proxy/Traefik/config
    git pull ./Proxy/Traefik/config

    echo "Done"
fi
