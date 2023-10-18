#!/bin/bash
# Pull and run Portainer

# Check if running on proxy server
if [ -z "$PROXY" ]; then
    echo "PROXY not set, using host config"
    echo "Pulling and running Portainer in $CONFIG_PATH/Portainer..."
    docker run -d -p "9000:9000" --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v $CONFIG_PATH/Portainer:/data portainer/portainer-ce
    docker compose up -d -f ./fireword-compose.yml --env-file ./fireword.env
    docker compose up -d -f ./proxy-compose.yml --env-file ./proxy.env
    docker compose up -d -f ./traefik-compose.yml --env-file ./traefik.env
    echo "Done..."
    exit 1
else
    echo "PROXY set, using proxy config"
    git clone https://github.com/ThePhaseless/Fireword_Traefik.git ./Traefik/config
    docker compose up -d -f ./proxy-compose.yml --env-file ./proxy.env
    echo "Done..."
fi
