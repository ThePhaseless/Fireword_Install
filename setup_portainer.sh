#!/bin/bash
# Pull and run Portainer
echo "Pulling and running Portainer..."
docker volume create portainer_data
docker run -d -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v $CONFIG_PATH/Portainer:/data portainer/portainer-ce
echo "Done..."
