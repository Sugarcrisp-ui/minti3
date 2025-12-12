#!/bin/bash
# installdockerservices.sh – 2025-12 final

set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Error: Do not run as root"; exit 1; }

echo "Installing Docker + Audiobookshelf..."

sudo apt-get install -y docker.io docker-compose

# Make sure Docker is running
sudo systemctl enable --now docker

# Add current user to docker group (works immediately with newgrp)
sudo usermod -aG docker "$USER"
newgrp docker <<EOF
echo "Docker group applied for this session"

# Audiobookshelf – correct GHCR image
docker pull ghcr.io/advplyr/audiobookshelf:latest

# Replace these paths with wherever you store books on the T14
docker run -d \
  --name audiobookshelf \
  --restart unless-stopped \
  -e PUID=1000 -e PGID=1000 -e TZ=Asia/Ho_Chi_Minh \
  -p 13378:80 \
  -v ~/Audiobooks:/audiobooks \
  -v ~/audiobookshelf/config:/config \
  -v ~/audiobookshelf/metadata:/metadata \
  ghcr.io/advplyr/audiobookshelf:latest

echo "Audiobookshelf running → http://localhost:13378"
EOF

echo "Docker services installed"
