#!/bin/bash

# Install i3 and core dependencies
sudo apt install -y \
  i3 \
  i3status \
  rofi \
  dunst \
  xfce4-terminal \
  micro \
  polybar \
  build-essential \
  cmake \
  libjsoncpp-dev \
  libxcb-randr0-dev \
  libxcb-xinerama0-dev \
  libxcb-util-dev \
  libxcb-icccm4-dev \
  libiw-dev \
  copyq \
  blueman \
  pasystray

# Install ProtonVPN if not already installed
if ! dpkg -l | grep -q protonvpn-stable-release; then
    wget https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.3-3_all.deb -O protonvpn-stable-release.deb
    sudo apt install --allow-downgrades ./protonvpn-stable-release.deb -y
    sudo apt update
    sudo apt install protonvpn -y
    rm -f protonvpn-stable-release.deb
else
    echo "ProtonVPN stable release already installed, skipping."
fi

# Variables
USER="brett"
USER_HOME="/home/$USER"

# Symlink dotfiles
sudo -u "$USER" bash -c "mkdir -p $USER_HOME/.config/i3 $USER_HOME/.config/polybar $USER_HOME/.config/rofi $USER_HOME/.config/dunst"
sudo -u "$USER" bash -c "ln -sf $USER_HOME/dotfiles/.config/i3/config $USER_HOME/.config/i3/config"
sudo -u "$USER" bash -c "ln -sf $USER_HOME/dotfiles/.config/polybar $USER_HOME/.config/polybar"
sudo -u "$USER" bash -c "ln -sf $USER_HOME/dotfiles/.config/rofi/config.rasi $USER_HOME/.config/rofi/config.rasi"
sudo -u "$USER" bash -c "ln -sf $USER_HOME/dotfiles/.config/dunst/dunstrc $USER_HOME/.config/dunst/dunstrc"
sudo -u "$USER" bash -c "mkdir -p $USER_HOME/.bin-personal"
sudo -u "$USER" bash -c "ln -sf $USER_HOME/dotfiles/.bin-personal/* $USER_HOME/.bin-personal/"
sudo -u "$USER" bash -c "chmod +x $USER_HOME/.bin-personal/*"

# Verify installations
i3 --version
polybar --version
rofi --version
dunst --version
