#!/bin/bash

# ANSI color codes
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Remove installed applications
sudo apt-get remove --purge hexchat hypnotix libreoffice-base libreoffice-impress libreoffice-math rhythmbox thunderbird transmission -y
sudo apt-get autoremove -y
