#!/bin/bash

USER=$(whoami)
USER_HOME="/home/$USER"

# Update package lists
sudo apt-get update

# Install i3 and core dependencies
sudo apt-get install -y \
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

# Create directories as the user
mkdir -p "$USER_HOME/.config/i3" "$USER_HOME/.config/polybar" "$USER_HOME/.config/rofi" "$USER_HOME/.config/dunst" "$USER_HOME/.bin-personal"

# Symlink dotfiles as the user
rm -f "$USER_HOME/.config/i3/config"
ln -sf "$USER_HOME/dotfiles-minti3/.config/i3/config" "$USER_HOME/.config/i3/config"
rm -rf "$USER_HOME/.config/polybar"
ln -sf "$USER_HOME/dotfiles-minti3/.config/polybar" "$USER_HOME/.config/polybar"
rm -f "$USER_HOME/.config/rofi/config.rasi"
ln -sf "$USER_HOME/dotfiles-minti3/.config/rofi/config.rasi" "$USER_HOME/.config/rofi/config.rasi"
rm -f "$USER_HOME/.config/dunst/dunstrc"
ln -sf "$USER_HOME/dotfiles-minti3/.config/dunst/dunstrc" "$USER_HOME/.config/dunst/dunstrc"

# Verify installations
i3 --version
polybar --version
rofi --version
dunst --version#!/bin/bash

USER=$(whoami)
USER_HOME="/home/$USER"

# Update package lists
sudo apt-get update

# Install i3 and core dependencies
sudo apt-get install -y \
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

# Create directories as the user
mkdir -p "$USER_HOME/.config/i3" "$USER_HOME/.config/polybar" "$USER_HOME/.config/rofi" "$USER_HOME/.config/dunst" "$USER_HOME/.bin-personal"

# Symlink dotfiles as the user
rm -f "$USER_HOME/.config/i3/config"
ln -sf "$USER_HOME/dotfiles-minti3/.config/i3/config" "$USER_HOME/.config/i3/config"
rm -rf "$USER_HOME/.config/polybar"
ln -sf "$USER_HOME/dotfiles-minti3/.config/polybar" "$USER_HOME/.config/polybar"
rm -f "$USER_HOME/.config/rofi/config.rasi"
ln -sf "$USER_HOME/dotfiles-minti3/.config/rofi/config.rasi" "$USER_HOME/.config/rofi/config.rasi"
rm -f "$USER_HOME/.config/dunst/dunstrc"
ln -sf "$USER_HOME/dotfiles-minti3/.config/dunst/dunstrc" "$USER_HOME/.config/dunst/dunstrc"

# Verify installations
i3 --version
polybar --version
rofi --version
dunst --version
