#!/bin/bash

# Check if RealVNC Viewer is installed
if ! command -v vncviewer &> /dev/null
then
    # Download and install RealVNC Viewer
    wget https://downloads.realvnc.com/download/file/viewer.files/VNC-Viewer-7.9.0-Linux-x64.deb -O realvnc-viewer.deb

    # Check if the download was successful
    if [ -e realvnc-viewer.deb ]
    then
        sudo dpkg -i -y realvnc-viewer.deb
        sudo apt install -f

        echo "RealVNC Viewer installation completed."
    else
        echo "Failed to download RealVNC Viewer. Please check the URL or try again later."
    fi

    # Clean up downloaded files
    rm realvnc-viewer.deb
else
    echo "RealVNC Viewer is already installed."
fi

# Check if RealVNC Server is installed
if ! command -v vncserver &> /dev/null
then
    # Download and install RealVNC Server
    wget https://downloads.realvnc.com/download/file/vnc.files/VNC-Server-7.9.0-Linux-x64.deb -O realvnc-server.deb

    # Check if the download was successful
    if [ -e realvnc-server.deb ]
    then
        sudo dpkg -i -y realvnc-server.deb
        sudo apt install -f

        echo "RealVNC Server installation completed."
    else
        echo "Failed to download RealVNC Server. Please check the URL or try again later."
    fi

    # Clean up downloaded files
    rm realvnc-server.deb
else
    echo "RealVNC Server is already installed."
fi

# Notify the user
echo "RealVNC Viewer and Server check completed. You can now use RealVNC Viewer and configure RealVNC Server on your system."
