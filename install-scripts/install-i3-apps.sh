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
  arandr \
  alacritty \
  audacity \
  bat \
  evince \
  libreoffice \
  meld \
  pasystray \
  pavucontrol \
  playerctl \
  vlc \
  xclip \
  xdotool \
  curl \
  numlockx
if [ $? -ne 0 ]; then
    echo "Error: Failed to install standard apt packages. Exiting."
    exit 1
fi

# Install Flatpak and Bitwarden
echo "Installing Flatpak and Bitwarden..."
sudo apt-get install -y flatpak
if [ $? -ne 0 ]; then
    echo "Error: Failed to install Flatpak. Exiting."
    exit 1
fi
sudo flatpak install flathub com.bitwarden.desktop -y
if [ $? -ne 0 ]; then
    echo "Error: Failed to install Bitwarden via Flatpak. Exiting."
    exit 1
fi

# Install ProtonVPN using the .deb file (commented out due to issues)
# echo "Installing ProtonVPN..."
# PROTONVPN_DEB="/home/brett/dotfiles-minti3/protonvpn-stable-release_1.0.8_all.deb"
# echo "Checking for ProtonVPN .deb file at $PROTONVPN_DEB..."
# if [ -f "$PROTONVPN_DEB" ]; then
#     echo "Found ProtonVPN .deb file. Installing..."
#     dpkg -i "$PROTONVPN_DEB"
#     if [ $? -ne 0 ]; then
#         echo "Error: Failed to install ProtonVPN .deb package. Exiting."
#         exit 1
#     fi
#     # Update package lists after adding the ProtonVPN repository via .deb
#     apt-get update
#     if [ $? -ne 0 ]; then
#         echo "Error: Failed to update package lists after adding ProtonVPN .deb. Exiting."
#         exit 1
#     fi
#     # Install ProtonVPN
#     apt-get install -y protonvpn
#     if [ $? -ne 0 ]; then
#         echo "Error: Failed to install ProtonVPN. Exiting."
#         exit 1
#     fi
# else
#     echo "Error: ProtonVPN .deb file not found at $PROTONVPN_DEB. Exiting."
#     exit 1
# fi

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
echo "Verifying installations..."
arandr --version
audacity --version
batcat --version
flatpak run com.bitwarden.desktop --version
evince --version
libreoffice --version
meld --version
pasystray --version
pavucontrol --version
playerctl --version
vlc --version
xclip -version
xdotool --version
hblock --version
# protonvpn-app --version  # Commented out due to installation issues

# Cleanup
sudo apt-get autoremove -y
sudo apt-get autoclean -y

echo "Installation of additional i3 apps completed."
