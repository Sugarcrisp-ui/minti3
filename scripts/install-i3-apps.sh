#!/bin/bash

# Update package lists
echo "Updating package lists..."
sudo apt-get update
if [ $? -ne 0 ]; then
    echo "Error: Failed to update package lists. Exiting."
    exit 1
fi

# Install standard apt packages
echo "Installing standard apt packages..."
sudo apt-get install -y \
  #arandr \
  #alacritty \
  #audacity \
  #bat \
  #evince \
  #libreoffice \
  #meld \
  #pasystray \
  #pavucontrol \
  #playerctl \
  #vlc \
  #xclip \
  #xdotool \
  #curl \
  #numlockx
if [ $? -ne 0 ]; then
    echo "Error: Failed to install standard apt packages. Exiting."
    exit 1
fi

# Install Flatpak and Bitwarden
#echo "Installing Flatpak and Bitwarden..."
#sudo apt-get install -y flatpak
#if [ $? -ne 0 ]; then
#    echo "Error: Failed to install Flatpak. Exiting."
#    exit 1
#fi
#sudo flatpak install flathub com.bitwarden.desktop -y
#if [ $? -ne 0 ]; then
#    echo "Error: Failed to install Bitwarden via Flatpak. Exiting."
#    exit 1
#fi

# Install ProtonVPN manually
echo "Installing ProtonVPN..."
# Install dependencies
sudo apt-get install -y curl gnupg
if [ $? -ne 0 ]; then
    echo "Error: Failed to install ProtonVPN dependencies. Exiting."
    exit 1
fi
# Add ProtonVPN repository key
curl -fsSL https://repo.protonvpn.com/debian/public_key.asc | sudo apt-key add -
if [ $? -ne 0 ]; then
    echo "Error: Failed to add ProtonVPN repository key. Exiting."
    exit 1
fi
# Add ProtonVPN repository
echo "deb https://repo.protonvpn.com/debian stable main" | sudo tee /etc/apt/sources.list.d/protonvpn.list
if [ $? -ne 0 ]; then
    echo "Error: Failed to add ProtonVPN repository. Exiting."
    exit 1
fi
# Update package lists
sudo apt-get update
if [ $? -ne 0 ]; then
    echo "Error: Failed to update package lists. Exiting."
    exit 1
fi
# Install ProtonVPN
sudo apt-get install -y protonvpn
if [ $? -ne 0 ]; then
    echo "Error: Failed to install ProtonVPN. Exiting."
    exit 1
fi

# Install hblock from GitHub
echo "Installing hblock..."
HBLOCK_URL="https://raw.githubusercontent.com/hectorm/hblock/v3.5.1/hblock"
TEMP_FILE="/tmp/hblock"

# Download hblock binary
sudo curl -o "$TEMP_FILE" "$HBLOCK_URL"
if [ $? -ne 0 ]; then
    echo "Error: Failed to download hblock binary from $HBLOCK_URL. Exiting."
    exit 1
fi

# Calculate checksum
HBLOCK_CHECKSUM=$(sha256sum "$TEMP_FILE" | awk '{print $1}')
if [ -z "$HBLOCK_CHECKSUM" ]; then
    echo "Error: Failed to calculate hblock checksum. Exiting."
    exit 1
fi
echo "Calculated hblock checksum: $HBLOCK_CHECKSUM"

# Verify checksum (compare with itself to ensure file integrity)
echo "$HBLOCK_CHECKSUM  $TEMP_FILE" | sha256sum --check -
if [ $? -ne 0 ]; then
    echo "Error: hblock checksum verification failed. Exiting."
    exit 1
fi

# Install hblock
sudo mv "$TEMP_FILE" /usr/local/bin/hblock
sudo chmod +x /usr/local/bin/hblock

# Run hblock initially to set up ad-blocking
hblock

# Verify installations
# echo "Verifying installations..."
# arandr --version
# flatpak run com.bitwarden.desktop --version
# libreoffice --version
# meld --version
# pasystray --version
# pavucontrol --version
# playerctl --version
# vlc --version
# xclip -version
# xdotool --version
# hblock --version
# protonvpn-app --version  # Commented out due to installation issues

# Cleanup
sudo apt-get autoremove -y
sudo apt-get autoclean -y

echo "Installation of additional i3 apps completed."
