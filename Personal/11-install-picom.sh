#!/bin/bash

set -e

# Download and install ExpressVPN
echo -e "\e[32mDownloading ExpressVPN\e[0m"
wget https://www.expressvpn.works/clients/linux/expressvpn_3.61.0.12-1_amd64.deb

echo -e "\e[32mInstalling ExpressVPN\e[0m"
sudo dpkg --force-confold -i expressvpn_3.61.0.12-1_amd64.deb

# Activate ExpressVPN
echo -e "\e[32mActivating ExpressVPN\e[0m"
sudo expressvpn activate

# Connect to a server (optional)
# Uncomment the line below and replace "<SERVER_LOCATION>" with the desired server location.
# sudo expressvpn connect <SERVER_LOCATION>

# Success message
echo -e "\e[32mExpressVPN has been installed and activated successfully.\e[0m"
