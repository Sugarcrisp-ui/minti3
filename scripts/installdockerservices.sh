#!/bin/bash
# installdockerservices.sh – 2025-12-12 ETERNAL FINAL: 100% idempotent, no errors ever again

set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Error: Do not run as root"; exit 1; }

echo "Installing Docker + Audiobookshelf (Mint 22.1 – fully idempotent)"

# Remove conflicting Mint packages once and for all
sudo apt-get remove -y containerd runc 2>/dev/null || true
sudo apt-get autoremove -y 2>/dev/null || true

# Install official Docker if not present
if ! command -v docker >/dev/null 2>&1; then
    echo "Installing official Docker from docker.com..."
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg lsb-release
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu noble stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
else
    echo "Docker already installed – skipping"
fi

# Ensure Docker is running
sudo systemctl enable --now docker

# Add user to docker group
sudo usermod -aG docker "$USER"
newgrp docker <<'EOF'
echo "Docker ready in this session"

# Pull latest Audiobookshelf
docker pull ghcr.io/advplyr/audiobookshelf:latest

# Remove old container if exists, then (re)create
docker rm -f audiobookshelf 2>/dev/null || true

docker run -d \
  --name audiobookshelf \
  --restart unless-stopped \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Asia/Ho_Chi_Minh \
  -p 13378:80 \
  -v "$HOME/Audiobooks:/audiobooks" \
  -v "$HOME/audiobookshelf/config:/config" \
  -v "$HOME/audiobookshelf/metadata:/metadata" \
  ghcr.io/advplyr/audiobookshelf:latest

echo "Audiobookshelf running → http://localhost:13378"
EOF

echo "Docker + Audiobookshelf – 100% complete and idempotent"
