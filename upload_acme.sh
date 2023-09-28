#!/bin/bash

# Get the current day of the year
export $SSH_USERNAME="kukubaorch"
export $SSH_HOSTNAME="litwave"
declare -i offset=236
declare -i current_day=$(date +%j)
current_day=$((current_day - offset))

# Specify the day of the year when you want the script to run (e.g., every 60 days)
target_day=60

# Check if the current day is the target day
if [ "$((current_day % target_day))" -eq 0 ]; then
    # Your script's actual commands go here
    echo "Running the script's task on day $current_day"
    sudo chmod 777 /home/ubuntu/Proxy/Traefik/acme.json
    ssh -t $SSH_USERNAME@$SSH_HOSTNAME "sudo chmod 777 /public/SSDonfig/Home/Traefik/acme.json"
    scp /home/ubuntu/Proxy/Traefik/acme.json $SSH_USERNAME@$SSH_HOSTNAME:/public/SSD/Config/Home/Traefik/acme.json
    ssh -t $SSH_USERNAME@$SSH_HOSTNAME "sudo chmod 600 /public/SSD/Config/Home/Traefik/acme.json"
    sudo chmod 600 /home/ubuntu/Proxy/Traefik/acme.json
    echo "Done..."
else
    echo "Not the target day ($current_day), skipping..."
fi
