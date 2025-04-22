#!/bin/bash

# Install standard apt packages
sudo apt update
sudo apt install -y \
  arandr \
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
  curl

# Install Flatpak and bitwarden
sudo apt install flatpak -y
flatpak install flathub com.bitwarden.desktop -y

# Install hblock from GitHub
curl -o hblock -L https://raw.githubusercontent.com/hectorm/hblock/v3.5.1/hblock
sudo mv hblock /usr/local/bin/
sudo chmod +x /usr/local/bin/hblock

# Run hblock initially to set up ad-blocking
hblock

# Verify installations
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
