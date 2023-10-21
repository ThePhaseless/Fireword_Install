#!/bin/bash
# if PROXY is not said, ask if script should continue

if [ -z "$PROXY" ]; then
    read -r -p "PROXY is not set, continue? (Y/n): " answer
    case ${answer,,} in
    n*)
        echo "Cancelling..."
        exit
        ;;
    esac
fi

# Update repo
git pull

echo "Starting Traefik stack"
docker compose --file ./Proxy/proxy-compose.yml --env-file ./Proxy/proxy.env up -d
