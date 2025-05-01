cd /home/brett/minti3/install-scripts
cat << 'EOF' > install-i3-apps.sh
#!/bin/bash

USER=$(whoami)

echo "Current user: $USER, USER=$USER, HOME=/home/$USER"

echo "Updating package lists..."
sudo apt-get update

echo "Installing standard apt packages..."
sudo apt-get install -y \
    feh \
    geany \
    qbittorrent \
    thunar \
    xfce4-settings \
    xfce4-power-manager \
    xfce4-panel \
    network-manager-gnome \
    network-manager-openvpn-gnome \
    arandr \
    audacity \
    bat \
    brave-browser \
    ca-certificates-java \
    color-picker \
    default-jre \
    evince \
    fonts-crosextra-caladea \
    fonts-crosextra-carlito \
    fonts-dejavu \
    fonts-dejavu-extra \
    fonts-freefont-ttf \
    fonts-liberation-sans-narrow \
    fonts-linuxlibertine \
    fonts-noto-extra \
    fonts-noto-ui-core \
    fonts-sil-gentium \
    fonts-sil-gentium-basic \
    gdm3 \
    geoclue-2.0 \
    gnome-control-center \
    gnome-remote-desktop \
    gnome-session-bin \
    gnome-settings-daemon \
    gnome-shell \
    gnome-shell-extension-appindicator \
    gnome-startup-applications \
    gnome-user-docs \
    heif-thumbnailer \
    htop \
    ibus \
    language-selector-common \
    language-selector-gnome \
    libatk-wrapper-java \
    libreoffice \
    lxpolkit \
    meld \
    numlockx \
    openjdk-21-jre \
    pipx \
    playerctl \
    python3-argcomplete \
    rygel \
    screen-resolution-extra \
    snapd \
    sublime-text \
    syncthing \
    syncthing-gtk \
    ubuntu-docs \
    ubuntu-session \
    ubuntu-wallpapers \
    ubuntu-wallpapers-noble \
    vlc \
    warp-terminal \
    whoopsie \
    xdotool \
    yaru-theme-gnome-shell \
    zim

# Install Warp Terminal
echo "Installing Warp Terminal..."
sudo apt-get install -y wget gpg

# Download and install the Warp GPG key
wget -qO- https://releases.warp.dev/linux/keys/warp.asc | sudo gpg --dearmor -o /etc/apt/keyrings/warpdotdev.gpg
if [ $? -ne 0 ]; then
    echo "Error: Failed to download or convert Warp GPG key. Exiting."
    exit 1
fi
sudo chmod 644 /etc/apt/keyrings/warpdotdev.gpg

# Remove any duplicate Warp repository entries
sudo rm -f /etc/apt/sources.list.d/warpdotdev.list

# Add the Warp repository
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/warpdotdev.gpg] https://releases.warp.dev/linux/deb stable main" | sudo tee /etc/apt/sources.list.d/warp.list
if [ $? -ne 0 ]; then
    echo "Error: Failed to add Warp repository to sources list. Exiting."
    exit 1
fi

# Update package lists and install Warp Terminal
sudo apt update
if [ $? -ne 0 ]; then
    echo "Error: Failed to update package lists after adding Warp repository. Exiting."
    exit 1
fi
sudo apt install -y warp-terminal
if [ $? -ne 0 ]; then
    echo "Error: Failed to install Warp Terminal. Exiting."
    exit 1
fi

echo "Installing ProtonVPN..."
sudo apt-get install -y curl gnupg
sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/protonvpn-stable-archive-keyring.gpg] https://repo.protonvpn.com/debian stable main" > /etc/apt/sources.list.d/protonvpn-stable.list'
sudo apt-get update
sudo apt-get install -y protonvpn

echo "Installing Bitwarden via Flatpak..."
flatpak install -y flathub com.bitwarden.desktop

echo "Installing GitHub Desktop via Flatpak..."
flatpak install -y flathub io.github.shiftey.Desktop

# Install Insync
echo "Installing Insync..."
curl -fsSL -o insync.deb https://cdn.insynchq.com/builds/linux/3.9.6.60027/insync_3.9.6.60027-noble_amd64.deb
sudo dpkg -i insync.deb
sudo apt-get install -f -y
rm insync.deb

echo "i3 apps installation complete."
EOF
