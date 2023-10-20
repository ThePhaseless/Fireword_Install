#!/bin/bash
# Pull and run Portainer

# Import git links from setting.env
source ./setting.env

# Update git repo
git pull

# Check if running on proxy server or if --proxy flag is set
if [ -z "$PROXY" || "$PROXY" == "false" ]; then
    echo "PROXY is not set, using Host configuration"

    echo "Starting Traefik stack"
    docker compose up -d -f ./Host/traefik-compose.yml --env-file ./Traefik/traefik.env

    echo "Starting Fireword stack"
    docker compose up -d -f ./Host/fireword-compose.yml --env-file ./Fireword/fireword.env

    echo "Starting Home Services stack"
    docker compose up -d -f ./Host/home-services-compose.yml --env-file ./HomeServices/home-services.env

    echo "Done"
else
    echo "PROXY is set, using Proxy configuration"

    echo "Starting Traefik stack"
    docker compose up -d -f ./Proxy/proxy-compose.yml --env-file ./Proxy/proxy.env

    echo "Done"
fi
