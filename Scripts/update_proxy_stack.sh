# if PROXY is not said, ask if script should continue

if [ -z "$PROXY" ]; then
    read -p "PROXY is not set, continue? (Y/n): " answer
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
docker compose up -d -f ./Proxy/proxy-compose.yml --env-file ./Proxy/proxy.env
