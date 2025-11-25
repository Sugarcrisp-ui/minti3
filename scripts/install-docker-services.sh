#!/bin/bash
# install-docker-services.sh – 2025 final: ultra-clean, bullet-proof

set -euo pipefail

[[ $EUID -ne 0 ]] || { echo "Error: Do not run as root"; exit 1; }

USER_HOME="${HOME:?}"
BASE_DIR="$USER_HOME/docker-services"
LOG_DIR="$USER_HOME/log-files/install-docker-services"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_DIR/install-docker-services-$(date +%Y%m%d-%H%M%S).txt") 2>&1

# === YOUR DOCKER SERVICES (single source of truth) ===
SERVICES=(
    audiobookshelf
    calibre-web
)

echo "Deploying ${#SERVICES[@]} Docker services..."

# Install Docker + Compose plugin (official, Ubuntu Noble)
if ! command -v docker >/dev/null || ! command -v docker compose >/dev/null; then
    echo "Installing Docker Engine + Compose plugin..."
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
        https://download.docker.com/linux/ubuntu noble stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    sudo usermod -aG docker "$USER"
    newgrp docker >/dev/null 2>&1 <<'EOF'
echo "Docker group active for this session"
EOF
fi

mkdir -p "$BASE_DIR"

for service in "${SERVICES[@]}"; do
    dir="$BASE_DIR/$service"
    file="$dir/docker-compose.yml"

    if [[ -f "$file" ]]; then
        echo "$service: updating containers..."
        docker compose -f "$file" up -d --remove-orphans
        continue
    fi

    echo "$service: deploying new service..."
    mkdir -p "$dir"

    case "$service" in
        audiobookshelf)
            cat > "$file" <<EOF
services:
  audiobookshelf:
    image: ghcr.io/advplyr/audiobookshelf:latest
    container_name: audiobookshelf
    ports: [13378:80]
    volumes:
      - /mnt/data/audiobooks:/audiobooks
      - /mnt/data/audiobooks-metadata:/metadata
      - /mnt/data/audiobooks-config:/config
    restart: unless-stopped
EOF
            ;;
        calibre-web)
            cat > "$file" <<EOF
services:
  calibre-web:
    image: linuxserver/calibre-web:latest
    container_name: calibre-web
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/Chicago
    ports: [8083:8083]
    volumes:
      - /mnt/data/calibre-library:/books
      - /mnt/data/calibre-config:/config
    restart: unless-stopped
EOF
            ;;
    esac

    docker compose -f "$file" up -d
done

IP=$(hostname -I | awk '{print $1}')
echo "Docker services ready:"
echo "  • Audiobookshelf → http://$IP:13378"
echo "  • Calibre-Web     → http://$IP:8083"
