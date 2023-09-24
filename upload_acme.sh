#!/bin/bash

# Get the current day of the year

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
    echo "Done"
    sudo sshpass -p "Haslo1haslo" ssh -t kukubaorch@fireword "sudo chmod 777 /public/SSD/Config/Home/Traefik/acme.json"
    sudo sshpass -p "Haslo1haslo" scp /home/ubuntu/Proxy/Traefik/acme.json kukubaorch@fireword:/public/SSD/Config/Home/Traefik/acme.json
    sudo sshpass -p "Haslo1haslo" ssh -t kukubaorch@fireword "sudo chmod 600 /public/SSD/Config/Home/Traefik/acme.json"
    sudo chmod 600 /home/ubuntu/Proxy/Traefik/acme.json
else
    echo "Not the target day ($current_day), skipping..."
fi
