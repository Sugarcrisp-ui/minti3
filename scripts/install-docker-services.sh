#!/bin/bash
# install-docker-services.sh – your approved Docker services only (2025 version)

USER=$(whoami)
if [ "$USER" = "root" ]; then
    echo "Error: This script should not be run as root. Exiting."
    exit 1
fi

USER_HOME=$(eval echo ~$USER)
LOG_DIR="$USER_HOME/log-files/install-docker-services"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
OUTPUT_FILE="$LOG_DIR/install-docker-services-$TIMESTAMP.txt"

mkdir -p "$LOG_DIR"
exec > >(tee -a "$OUTPUT_FILE") 2>&1
echo "Logging output to $OUTPUT_FILE"

# === YOUR DOCKER SERVICES LIST (single source of truth) ===
SERVICES=(
    "audiobookshelf"
    "calibre-web"
    # Add future ones here: "uptime-kuma" "changedetection.io" etc.
)

echo "Deploying ${#SERVICES[@]} approved Docker services..."

# Install Docker + Compose plugin if missing (official Docker repo, Ubuntu Noble)
if ! command -v docker >/dev/null || ! command -v docker-compose >/dev/null; then
    echo "Installing Docker Engine + Compose plugin..."
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu noble stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    sudo usermod -aG docker "$USER"
    newgrp docker <<'ENDDOCKER'
        echo "Docker group membership applied for this session."
ENDDOCKER
fi

# Base directory for all services
BASE_DIR="$USER_HOME/docker-services"
mkdir -p "$BASE_DIR"

# Deploy each service
for service in "${SERVICES[@]}"; do
    SERVICE_DIR="$BASE_DIR/$service"
    COMPOSE_FILE="$SERVICE_DIR/docker-compose.yml"

    if [ -f "$COMPOSE_FILE" ]; then
        echo "$service already exists → pulling latest images and restarting..."
        docker compose -f "$COMPOSE_FILE" up -d --remove-orphans
        continue
    fi

    echo "Deploying new $service service..."
    mkdir -p "$SERVICE_DIR"

    case "$service" in
        audiobookshelf)
            cat > "$COMPOSE_FILE" <<'EOF'
services:
  audiobookshelf:
    image: ghcr.io/advplyr/audiobookshelf:latest
    container_name: audiobookshelf
    ports:
      - "13378:80"
    volumes:
      - /mnt/data/audiobooks:/audiobooks
      - /mnt/data/audiobooks-metadata:/metadata
      - /mnt/data/audiobooks-config:/config
    restart: unless-stopped
EOF
            ;;
        calibre-web)
            cat > "$COMPOSE_FILE" <<'EOF'
services:
  calibre-web:
    image: linuxserver/calibre-web:latest
    container_name: calibre-web
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/Chicago
    ports:
      - "8083:8083"
    volumes:
      - /mnt/data/calibre-library:/books
      - /mnt/data/calibre-config:/config
    restart: unless-stopped
EOF
            ;;
        *)
            echo "Warning: No compose template for '$service' – skipping."
            continue
            ;;
    esac

    echo "Starting $service..."
    docker compose -f "$COMPOSE_FILE" up -d
done

echo "Docker services deployment complete."
echo "   • Audiobookshelf → http://$(hostname -I | awk '{print $1}'):13378"
echo "   • Calibre-Web     → http://$(hostname -I | awk '{print $1}'):8083"
