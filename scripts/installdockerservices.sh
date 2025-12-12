#!/bin/bash
# installdockerservices.sh – 2025-12-12 FINAL: works on fresh Mint 22.1 T14 (resolves containerd conflict)

set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Error: Do not run as root"; exit 1; }

echo "Installing Docker + Audiobookshelf (Mint 22.1 clean install)"

# Remove Mint's conflicting containerd if present
sudo apt-get remove -y containerd runc 2>/dev/null || true
sudo apt-get autoremove -y 2>/dev/null || true

# Install Docker using the official Docker repo (works every time on Mint 22.1)
if ! command -v docker >/dev/null 2>&1; then
    echo "Adding official Docker repository..."
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg lsb-release

    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
else
    echo "Docker already installed – skipping"
fi

# Ensure Docker service is running and enabled
sudo systemctl enable --now docker

# Add current user to docker group (newgrp makes it immediate)
sudo usermod -aG docker "$USER"
newgrp docker <<'EOF'
echo "Docker group applied for this session"

# Pull correct Audiobookshelf image from GHCR
docker pull ghcr.io/advplyr/audiobookshelf:latest

# Run Audiobookshelf (standard paths – adjust if you use different ones later)
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

echo "Docker + Audiobookshelf installation complete"
