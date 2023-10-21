#!/bin/bash

current_dir=$(pwd)

cd "$PROXY_GIT_REPO"/Proxy/Traefik/config || exit

git add .
git commit -am "Traefik config update"
git push

cd "$current_dir" || exit
