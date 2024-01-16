#!/bin/bash

# ANSI color codes
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Remove related directories in ~/.config
rm -rf "$HOME/.config/hexchat"
rm -rf "$HOME/.config/hypnotix"
rm -rf "$HOME/.config/libreoffice-base"
rm -rf "$HOME/.config/libreoffice-impress"
rm -rf "$HOME/.config/libreoffice-math"
rm -rf "$HOME/.config/rhythmbox"
rm -rf "$HOME/.config/thunderbird"
rm -rf "$HOME/.config/transmission"

# Explicitly remove directories for hexchat, evolution, and caja
rm -rf "$HOME/.config/hexchat"
rm -rf "$HOME/.config/evolution"
rm -rf "$HOME/.config/caja"

# Remove installed applications
sudo apt-get remove --purge hexchat hypnotix libreoffice-base libreoffice-impress libreoffice-math rhythmbox thunderbird transmission -y

sudo apt-get autoremove -y
