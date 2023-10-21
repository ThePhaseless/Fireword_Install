#!/bin/bash

current_dir=$(pwd)

cd "$PROXY_GIT_REPO"/Proxy/Traefik/config || exit

git commit -am "Traefik config update"

cd "$current_dir" || exit
