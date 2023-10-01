#!/bin/bash

# Get the current day of the year
SSH_USERNAME="thephaseless"
SSH_HOSTNAME="litwave"
ACME_FILE="acme.json"
ACME_DIR_LOCAL="/home/ubuntu/Proxy/Traefik/cert"
ACME_DIR_EXTERNAL="/public/SSD/Config/Home/Traefik/cert"
declare -i offset=0
declare -i current_day=$(date +%j)
current_day=$((current_day - offset))

# Specify the day of the year when you want the script to run (e.g., every 60 days)
target_day=60

# Check if the current day is the target day or if "--force" was passed as an argument
if [ "$((current_day % target_day))" -eq 0 ] || [ "$1" == "--force" ]; then
    # Your script's actual commands go here
    echo "Running the script's task on day $current_day"
    echo "Last run $((current_day % target_day)) days ago"
    echo "Uploading acme.json file to $SSH_HOSTNAME..."

    # Change the permissions of the file to 777
    echo "Changing permissions of $ACME_DIR_LOCAL/$ACME_FILE to 777..."
    sudo chmod 777 $ACME_DIR_LOCAL/$ACME_FILE
    # Give it a second to change the permissions
    sleep 1

    # Create the folder if it doesn't exist
    echo "Creating $ACME_DIR_EXTERNAL if it doesn't exist..."
    ssh -t $SSH_USERNAME@$SSH_HOSTNAME "sudo mkdir -p $ACME_DIR_EXTERNAL && sudo chmod 777 $ACME_DIR_EXTERNAL"

    echo "Uploading $ACME_FILE to $SSH_HOSTNAME..."
    scp $ACME_DIR_LOCAL/$ACME_FILE $SSH_USERNAME@$SSH_HOSTNAME:$ACME_DIR_EXTERNAL

    echo "Changing permissions of $ACME_DIR_EXTERNAL/$ACME_FILE on $SSH_HOSTNAME to 600..."
    ssh -t $SSH_USERNAME@$SSH_HOSTNAME "sudo chmod 600 $ACME_DIR_EXTERNAL/$ACME_FILE"

    echo "Changing permissions of $ACME_DIR_LOCAL/$ACME_FILE back to 600..."
    sudo chmod 600 $ACME_DIR_LOCAL/$ACME_FILE

    echo "Done..."
else
    echo "Not the target day ($current_day), skipping..."
fi
