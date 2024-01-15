#!/bin/bash

# Install TLP
sudo apt-get update
sudo apt-get install tlp

# Enable the TLP service
sudo systemctl enable tlp.service

echo "TLP installed and service enabled successfully!"
