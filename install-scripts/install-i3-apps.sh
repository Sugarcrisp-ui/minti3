#!/bin/bash

# Update package lists
echo "Updating package lists..."
apt-get update
if [ $? -ne 0 ]; then
    echo "Error: Failed to update package lists. Exiting."
    exit 1
fi

# Install standard apt packages
echo "Installing standard apt packages..."
apt-get install -y \
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
apt-get install -y flatpak
if [ $? -ne 0 ]; then
    echo "Error: Failed to install Flatpak. Exiting."
    exit 1
fi
flatpak install flathub com.bitwarden.desktop -y
if [ $? -ne 0 ]; then
    echo "Error: Failed to install Bitwarden via Flatpak. Exiting."
    exit 1
fi

# Install ProtonVPN using the .deb file
echo "Installing ProtonVPN..."
if [ -f "/home/brett/dotfiles-minti3/protonvpn-stable-release.deb" ]; then
    dpkg -i /home/brett/dotfiles-minti3/protonvpn-stable-release.deb
    if [ $? -ne 0 ]; then
        echo "Error: Failed to install ProtonVPN .deb package. Exiting."
        exit 1
    fi
    # Update package lists after adding the ProtonVPN repository via .deb
    apt-get update
    if [ $? -ne 0 ]; then
        echo "Error: Failed to update package lists after adding ProtonVPN .deb. Exiting."
        exit 1
    fi
    # Install ProtonVPN
    apt-get install -y protonvpn
    if [ $? -ne 0 ]; then
        echo "Error: Failed to install ProtonVPN. Exiting."
        exit 1
    fi
else
    echo "Error: ProtonVPN .deb file not found at /home/brett/dotfiles-minti3/protonvpn-stable-release.deb. Exiting."
    exit 1
fi

# Install hblock from GitHub
echo "Installing hblock..."
curl -o /tmp/hblock https://raw.githubusercontent.com/hectorm/hblock/v3.5.1/hblock
echo "c68a0b8dad58ab75080eed7cb989e5634fc88fca051703139c025352a6ee19ad /tmp/hblock" | sha256sum --check -
if [ $? -ne 0 ]; then
    echo "Error: hblock checksum verification failed. Exiting."
    exit 1
fi
mv /tmp/hblock /usr/local/bin/hblock
chmod +x /usr/local/bin/hblock

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
protonvpn-app --version

# Cleanup
apt-get autoremove -y
apt-get autoclean -y

echo "Installation of additional i3 apps completed."
