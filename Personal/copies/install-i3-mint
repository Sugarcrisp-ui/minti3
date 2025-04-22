#!/bin/bash

# Install i3 and core dependencies
sudo apt install i3 i3status rofi dunst xfce4-terminal micro -y

# Install Polybar and dependencies
sudo apt install polybar build-essential cmake libjsoncpp-dev libxcb-randr0-dev libxcb-xinerama0-dev libxcb-util-dev libxcb-icccm4-dev libiw-dev -y

# Install autostart apps
sudo apt install copyq blueman pasystray -y

# Install ProtonVPN
wget https://protonvpn.com/download/protonvpn-stable-release_1.0.3-3_all.deb
sudo apt install ./protonvpn-stable-release_1.0.3-3_all.deb -y
sudo apt update
sudo apt install protonvpn -y

# Symlink dotfiles (adjust paths as needed)
mkdir -p ~/.config/{i3,polybar,rofi,dunst}
ln -s ~/dotfiles/.config/i3/config ~/.config/i3/config
ln -s ~/dotfiles/.config/polybar ~/.config/polybar
ln -s ~/dotfiles/.config/rofi/config.rasi ~/.config/rofi/config.rasi
ln -s ~/dotfiles/.config/dunst/dunstrc ~/.config/dunst/dunstrc
mkdir -p ~/.bin-personal
ln -s ~/dotfiles/.bin-personal/* ~/.bin-personal/
chmod +x ~/.bin-personal/*

# Verify installations
i3 --version
polybar --version
rofi --version
dunst --version