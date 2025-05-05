#!/bin/bash

# Ensure script is run as non-root user
USER=$(whoami)
if [ "$USER" = "root" ]; then
    echo "Error: This script should not be run as root. Exiting."
    exit 1
fi

# Variables
USER_HOME="$HOME"
OUTPUT_FILE="$USER_HOME/log-files/install-i3-apps/install-i3-apps-output.txt"

# Redirect output to file
mkdir -p ~/log-files/install-i3-apps
exec > >(tee -a "$OUTPUT_FILE") 2>&1
echo "Logging output to $OUTPUT_FILE"

# Preconfigure sddm as default display manager
echo "Preconfiguring sddm as default display manager..."
echo "sddm shared/default-x-display-manager select sddm" | sudo debconf-set-selections
if [ $? -ne 0 ]; then
    echo "Warning: Failed to preconfigure sddm via debconf. Continuing."
fi
# Fallback: directly set default display manager
sudo mkdir -p /etc/X11
echo "/usr/sbin/sddm" | sudo tee /etc/X11/default-display-manager >/dev/null
if [ $? -ne 0 ]; then
    echo "Warning: Failed to set sddm as default display manager. Continuing."
else
    echo "Set sddm as default display manager in /etc/X11/default-display-manager."
fi

# Check and install dependencies
echo "Checking and installing dependencies..."
packages=(
    feh
    geany
    qbittorrent
    thunar
    xfce4-settings
    xfce4-power-manager
    xfce4-panel
    network-manager-gnome
    network-manager-openvpn-gnome
    arandr
    audacity
    bat
    brave-browser
    ca-certificates-java
    default-jre
    evince
    fonts-crosextra-caladea
    fonts-crosextra-carlito
    fonts-dejavu
    fonts-dejavu-extra
    fonts-freefont-ttf
    gnome-control-center
    gnome-remote-desktop
    gnome-session-bin
    gnome-settings-daemon
    gnome-shell
    gnome-shell-extension-appindicator
    gnome-startup-applications
    gnome-user-docs
    heif-thumbnailer
    htop
    ibus
    language-selector-common
    language-selector-gnome
    libatk-wrapper-java
    libreoffice
    lxpolkit
    meld
    numlockx
    openjdk-21-jre
    pipx
    playerctl
    python3-argcomplete
    rygel
    screen-resolution-extra
    snapd
    sublime-text
    syncthing
    syncthing-gtk
    flatpak
    curl
    gnupg
    wget
)
unavailable_packages=(
    fonts-liberation-sans-narrow
    fonts-linuxlibertine
    fonts-noto-extra
    fonts-noto-ui-core
    fonts-sil-gentium
    fonts-sil-gentium-basic
    gdm3
    geoclue-2.0
    ubuntu-docs
    ubuntu-session
    ubuntu-wallpapers
    ubuntu-wallpapers-noble
    vlc
    warp-terminal
    whoopsie
    xdotool
    yaru-theme-gnome-shell
    zim
)

for pkg in "${unavailable_packages[@]}"; do
    echo "Warning: Package $pkg is not available in Linux Mint repositories. Skipping."
done

for pkg in "${packages[@]}"; do
    if ! dpkg -l | grep -q " $pkg "; then
        echo "Installing $pkg..."
        sudo apt-get install -y "$pkg"
        if [ $? -ne 0 ]; then
            echo "Error: Failed to install $pkg. Exiting."
            exit 1
        fi
    else
        echo "$pkg is already installed."
    fi
done

# Install Warp Terminal
echo "Installing Warp Terminal repository..."
if [ ! -f "/etc/apt/keyrings/warpdotdev.gpg" ]; then
    for attempt in {1..3}; do
        wget -qO- https://releases.warp.dev/linux/keys/warp.asc | gpg --dearmor > warpdotdev.gpg
        if [ $? -eq 0 ]; then
            sudo install -D -o root -g root -m 644 warpdotdev.gpg /etc/apt/keyrings/warpdotdev.gpg
            rm -f warpdotdev.gpg
            break
        fi
        echo "Warning: Failed to download Warp GPG key (attempt $attempt/3). Retrying..."
        sleep 2
    done
    if [ ! -f "/etc/apt/keyrings/warpdotdev.gpg" ]; then
        echo "Warning: Failed to download or install Warp GPG key after 3 attempts. Skipping Warp installation."
    fi
fi

if [ -f "/etc/apt/keyrings/warpdotdev.gpg" ]; then
    # Remove any existing Warp repository files to avoid duplicates
    sudo rm -f /etc/apt/sources.list.d/warp.list /etc/apt/sources.list.d/warpdotdev.list
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/warpdotdev.gpg] https://releases.warp.dev/linux/deb stable main" | sudo tee /etc/apt/sources.list.d/warpdotdev.list
    if [ $? -ne 0 ]; then
        echo "Error: Failed to add Warp repository to sources list. Exiting."
        exit 1
    fi

    echo "Updating package lists for Warp repository..."
    sudo apt-get update
    if [ $? -ne 0 ]; then
        echo "Warning: Failed to update package lists for Warp repository. Continuing."
    else
        echo "Installing Warp Terminal..."
        if ! dpkg -l | grep -q " warp-terminal "; then
            sudo apt-get install -y warp-terminal
            if [ $? -ne 0 ]; then
                echo "Warning: Failed to install warp-terminal. Continuing."
            else
                echo "warp-terminal installed successfully."
            fi
        else
            echo "warp-terminal is already installed."
        fi
    fi
else
    echo "Warning: Warp repository not configured due to earlier failure. Skipping Warp installation."
fi

# Install ProtonVPN
echo "Installing ProtonVPN repository..."
PROTONVPN_DEB_URL="https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.8_all.deb"
PROTONVPN_DEB_FILE="$USER_HOME/tmp/protonvpn-stable-release_1.0.8_all.deb"
if [ ! -f "/etc/apt/sources.list.d/protonvpn-stable.list" ]; then
    curl -fsSL -o "$PROTONVPN_DEB_FILE" "$PROTONVPN_DEB_URL"
    if [ $? -ne 0 ] || [ ! -f "$PROTONVPN_DEB_FILE" ]; then
        echo "Warning: Failed to download ProtonVPN repository DEB package. Skipping ProtonVPN installation."
    else
        echo "Verifying ProtonVPN DEB checksum..."
        echo "0b14e71586b22e498eb20926c48c7b434b751149b1f2af9902ef1cfe6b03e180 $PROTONVPN_DEB_FILE" | sha256sum --check -
        if [ $? -ne 0 ]; then
            echo "Warning: ProtonVPN DEB checksum verification failed. Skipping ProtonVPN installation."
            rm -f "$PROTONVPN_DEB_FILE"
        else
            sudo dpkg -i "$PROTONVPN_DEB_FILE"
            if [ $? -ne 0 ]; then
                echo "Attempting to fix dependencies for ProtonVPN repository..."
                sudo apt-get install -f -y
                if [ $? -ne 0 ]; then
                    echo "Warning: Failed to install ProtonVPN repository DEB or fix dependencies. Skipping ProtonVPN installation."
                fi
            fi
            rm -f "$PROTONVPN_DEB_FILE"
            sudo apt-get update
            if [ $? -ne 0 ]; then
                echo "Warning: Failed to update package lists for ProtonVPN repository. Continuing."
            fi
        fi
    fi
fi

if [ -f "/etc/apt/sources.list.d/protonvpn-stable.list" ]; then
    echo "Installing ProtonVPN..."
    if ! dpkg -l | grep -q " proton-vpn-gnome-desktop "; then
        sudo apt-get install -y proton-vpn-gnome-desktop
        if [ $? -ne 0 ]; then
            echo "Warning: Failed to install proton-vpn-gnome-desktop. Continuing."
        else
            echo "proton-vpn-gnome-desktop installed successfully."
        fi
    else
        echo "proton-vpn-gnome-desktop is already installed."
    fi
else
    echo "Warning: ProtonVPN repository not configured. Skipping ProtonVPN installation."
fi

# Install Flatpak applications
echo "Checking Flatpak environment..."
if [ -f "/proc/1/cgroup" ] && grep -qE "docker|containerd|kubepods|libpod" /proc/1/cgroup; then
    echo "Warning: Running in a containerized environment (Docker). Flatpak installations may fail due to sandboxing restrictions. Skipping."
else
    echo "Installing Bitwarden via Flatpak..."
    if ! flatpak list | grep -q "com.bitwarden.desktop"; then
        sudo flatpak install -y flathub com.bitwarden.desktop
        if [ $? -ne 0 ]; then
            echo "Warning: Failed to install Bitwarden via Flatpak. Continuing."
        else
            echo "Bitwarden installed successfully via Flatpak."
        fi
    else
        echo "Bitwarden is already installed via Flatpak."
    fi

    echo "Installing GitHub Desktop via Flatpak..."
    if ! flatpak list | grep -q "io.github.shiftey.Desktop"; then
        sudo flatpak install -y flathub io.github.shiftey.Desktop
        if [ $? -ne 0 ]; then
            echo "Warning: Failed to install GitHub Desktop via Flatpak. Continuing."
        else
            echo "GitHub Desktop installed successfully via Flatpak."
        fi
    else
        echo "GitHub Desktop is already installed via Flatpak."
    fi
fi

# Skip Insync due to incompatible libc6 dependency
echo "Warning: Insync requires libc6 (>= 2.39), but system has 2.35. Skipping Insync installation."

# Verify installations
echo "Verifying installations..."
verified_commands=(
    feh
    geany
    qbittorrent
    thunar
    brave-browser
    libreoffice
    meld
    syncthing
)
for cmd in "${verified_commands[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "$cmd is installed."
    else
        echo "Warning: $cmd is not installed."
    fi
done

if [ ! -f "/proc/1/cgroup" ] || ! grep -qE "docker|containerd|kubepods|libpod" /proc/1/cgroup; then
    if flatpak list | grep -q "com.bitwarden.desktop"; then
        echo "Bitwarden is installed via Flatpak."
    else
        echo "Warning: Bitwarden is not installed via Flatpak."
    fi

    if flatpak list | grep -q "io.github.shiftey.Desktop"; then
        echo "GitHub Desktop is installed via Flatpak."
    else
        echo "Warning: GitHub Desktop is not installed via Flatpak."
    fi
fi

if dpkg -l | grep -q " proton-vpn-gnome-desktop "; then
    echo "proton-vpn-gnome-desktop is installed."
else
    echo "Warning: proton-vpn-gnome-desktop is not installed."
fi

if dpkg -l | grep -q " warp-terminal "; then
    echo "warp-terminal is installed."
else
    echo "Warning: warp-terminal is not installed."
fi

echo "i3 apps installation complete."
