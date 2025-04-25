#!/bin/bash

# Install dependencies
echo "Installing dependencies..."
sudo apt-get update
sudo apt-get install -y \
  python3 \
  python3-gi \
  gir1.2-wnck-3.0 \
  python3-psutil \
  python3-cairo \
  python3-distro
if [ $? -ne 0 ]; then
    echo "Error: Failed to install dependencies. Exiting."
    exit 1
fi

# Clone or update i3-logout repository
if [ -d "/home/brett/i3-logout/.git" ]; then
    echo "i3-logout repository already exists at /home/brett/i3-logout, updating..."
    cd /home/brett/i3-logout
    git pull
    if [ $? -ne 0 ]; then
        echo "Error: Failed to update i3-logout repository. Exiting."
        exit 1
    fi
else
    echo "Cloning i3-logout repository..."
    git clone git@github.com:Sugarcrisp-ui/i3-logout.git /home/brett/i3-logout
    if [ $? -ne 0 ]; then
        echo "Error: Failed to clone i3-logout repository. Exiting."
        exit 1
    fi
fi

# Extract the tarball
echo "Extracting i3-logout-files.tar.gz..."
cd /home/brett/i3-logout
tar -xzf i3-logout-files.tar.gz -C /home/brett/tmp
if [ $? -ne 0 ]; then
    echo "Error: Failed to extract i3-logout-files.tar.gz. Exiting."
    exit 1
fi

# Install config
echo "Installing config..."
sudo install -Dm644 /tmp/etc/i3-logout.conf /etc/i3-logout.conf
if [ $? -ne 0 ]; then
    echo "Error: Failed to install config to /etc/i3-logout.conf. Exiting."
    exit 1
fi

# Install binaries
echo "Installing binaries..."
sudo install -Dm755 /tmp/usr/bin/i3-logout /usr/bin/i3-logout
sudo install -Dm755 /tmp/usr/bin/betterlockscreen /usr/bin/betterlockscreen
if [ $? -ne 0 ]; then
    echo "Error: Failed to install binaries to /usr/bin/. Exiting."
    exit 1
fi

# Install desktop file
echo "Installing desktop file..."
sudo install -Dm644 /tmp/usr/share/applications/betterlockscreen.desktop /usr/share/applications/betterlockscreen.desktop
if [ $? -ne 0 ]; then
    echo "Error: Failed to install desktop file to /usr/share/applications/. Exiting."
    exit 1
fi

# Install Python files
echo "Installing Python files..."
sudo mkdir -p /usr/share/i3-logout
sudo cp -r /tmp/usr/share/i3-logout/*.py /usr/share/i3-logout/
sudo mkdir -p /usr/share/betterlockscreen
sudo cp -r /tmp/usr/share/betterlockscreen/*.py /usr/share/betterlockscreen/
if [ $? -ne 0 ]; then
    echo "Error: Failed to install Python files. Exiting."
    exit 1
fi

# Install images and wallpapers
echo "Installing images and wallpapers..."
sudo mkdir -p /usr/share/betterlockscreen/images
sudo cp -r /tmp/usr/share/betterlockscreen/images/* /usr/share/betterlockscreen/images/
sudo mkdir -p /usr/share/betterlockscreen/wallpapers
sudo cp -r /tmp/usr/share/betterlockscreen/wallpapers/* /usr/share/betterlockscreen/wallpapers/
if [ $? -ne 0 ]; then
    echo "Error: Failed to install images and wallpapers. Exiting."
    exit 1
fi

# Install themes
echo "Installing themes..."
sudo mkdir -p /usr/share/i3-logout-themes
sudo cp -r /tmp/usr/share/i3-logout-themes/* /usr/share/i3-logout-themes/
if [ $? -ne 0 ]; then
    echo "Error: Failed to install themes to /usr/share/i3-logout-themes/. Exiting."
    exit 1
fi

# Install icon
echo "Installing icon..."
sudo install -Dm644 /tmp/usr/share/icons/hicolor/scalable/apps/better-lock-screen.svg /usr/share/icons/hicolor/scalable/apps/better-lock-screen.svg
if [ $? -ne 0 ]; then
    echo "Error: Failed to install icon to /usr/share/icons/hicolor/scalable/apps/. Exiting."
    exit 1
fi

# Install documentation
echo "Installing documentation..."
sudo mkdir -p /usr/share/doc/i3-logout
sudo cp -r /tmp/usr/share/doc/i3-logout/* /usr/share/doc/i3-logout/
if [ $? -ne 0 ]; then
    echo "Error: Failed to install documentation to /usr/share/doc/i3-logout/. Exiting."
    exit 1
fi

# Clean up
rm -rf /home/brett/tmp/etc /home/brett/tmp/usr

echo "i3-logout installation complete."
