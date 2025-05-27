#!/bin/bash

# Ensure script is run as non-root user
USER=$(whoami)
if [ "$USER" = "root" ]; then
    echo "Error: This script should not be run as root. Exiting."
    exit 1
fi

# Variables
USER_HOME=$(eval echo ~$USER)
LOG_DIR="$USER_HOME/log-files/install-i3-apps"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
OUTPUT_FILE="$LOG_DIR/install-i3-apps-$TIMESTAMP.txt"

# Redirect output to timestamped log file
mkdir -p "$LOG_DIR"
exec > >(tee -a "$OUTPUT_FILE") 2>&1
echo "Logging output to $OUTPUT_FILE"

# Preconfigure sddm as default display manager
echo "Preconfiguring sddm as default display manager..."
if [ -f "/etc/X11/default-display-manager" ]; then
    echo "/usr/sbin/sddm" | sudo tee /etc/X11/default-display-manager >/dev/null
    if [ $? -eq 0 ]; then
        echo "Set sddm as default display manager in /etc/X11/default-display-manager."
    else
        echo "Warning: Failed to set sddm as default display manager. Continuing."
    fi
else
    echo "Warning: /etc/X11/default-display-manager not found. Continuing."
fi

# Check and install dependencies
echo "Checking and installing dependencies..."
packages=(
    feh geany qbittorrent thunar xfce4-settings xfce4-power-manager xfce4-panel
    network-manager-gnome network-manager-openvpn-gnome arandr audacity brave-browser
    syncthing fonts-liberation-sans-narrow fonts-linuxlibertine fonts-noto-extra
    fonts-noto-ui-core fonts-sil-gentium fonts-sil-gentium-basic gdm3 geoclue-2.0
    ubuntu-docs ubuntu-session ubuntu-wallpapers ubuntu-wallpapers-noble vlc
    warp-terminal whoopsie xdotool yaru-theme-gnome-shell zim
)

for pkg in "${packages[@]}"; do
    if ! dpkg -l | grep -q " $pkg "; then
        if [ "$pkg" = "brave-browser" ]; then
            echo "Setting up Brave Browser repository..."
            sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
            if [ $? -ne 0 ]; then
                echo "Error: Failed to download Brave Browser keyring. Continuing."
                continue
            fi
            echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
            sudo apt-get update
            sudo apt-get install -y brave-browser

        elif [ "$pkg" = "syncthing" ]; then
            echo "Setting up Syncthing repository..."
            curl -s https://syncthing.net/release-key.txt | sudo apt-key add -
            echo "deb https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list
            sudo apt-get install -y apt-transport-https
            sudo apt-get update
            sudo apt-get install -y syncthing

            echo "Configuring Syncthing synced directories..."
            systemctl --user enable syncthing.service
            systemctl --user start syncthing.service
            sleep 10

            synced_dirs=(
                "$USER_HOME/.bin-personal"
                "$USER_HOME/.config"
                "$USER_HOME/.fonts"
                "$USER_HOME/Appimages"
                "$USER_HOME/Calibre-Library"
                "$USER_HOME/Documents"
                "$USER_HOME/Notebooks"
                "$USER_HOME/Pictures"
                "$USER_HOME/Shared"
                "$USER_HOME/Videos"
                "$USER_HOME/.local/share/applications"
                "$USER_HOME/dotfiles"
            )

            API_KEY=$(grep "<apiKey>" $USER_HOME/.config/syncthing/config.xml | sed -E 's/.*<apiKey>(.*)<\/apiKey>.*/\1/')

            for dir in "${synced_dirs[@]}"; do
                if [ -d "$dir" ]; then
                    dir_id=$(basename "$dir" | tr '[:upper:]' '[:lower:]')
                    dir_label=$(basename "$dir")

                    curl -X POST -H "X-API-Key: $API_KEY" \
                        http://localhost:8384/rest/config/folders \
                        -d "{\"id\":\"$dir_id\",\"label\":\"$dir_label\",\"path\":\"$dir\",\"type\":\"sendreceive\"}"

                    if [ $? -eq 0 ]; then
                        echo "Added $dir to Syncthing synced folders."
                        if [ "$dir" = "$USER_HOME/.config" ]; then
                            cat << 'EOF' > "$dir/.stignore"
!betterlockscreen/
!bluetooth-connect/
!dunst/
!gtk-3.0/
!i3/
!i3-logout/
!polybar/
!rofi/
!sublime-text/
!Thunar/
!warp-terminal/
!brave/
!BraveSoftware/
*
EOF
                            echo "Created .stignore for .config with specified patterns."
                        fi
                    else
                        echo "Warning: Failed to add $dir to Syncthing. Continuing."
                    fi
                else
                    echo "Warning: Directory $dir not found. Skipping."
                fi
            done

        elif [ "$pkg" = "warp-terminal" ]; then
            echo "Setting up Warp Terminal repository..."
            sudo apt-get install -y wget gpg
            wget -qO- https://releases.warp.dev/linux/keys/warp.asc | gpg --dearmor > warpdotdev.gpg
            sudo install -D -o root -g root -m 644 warpdotdev.gpg /etc/apt/keyrings/warpdotdev.gpg
            sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/warpdotdev.gpg] https://releases.warp.dev/linux/deb stable main" > /etc/apt/sources.list.d/warpdotdev.list'
            rm warpdotdev.gpg
            sudo apt-get update
            sudo apt-get install -y warp-terminal

            echo "Configuring Warp Terminal input position to Classic Mode..."
            mkdir -p "$USER_HOME/.config/warp-terminal"
            echo '{"prefs":{"InputPosition":"start_at_the_top"}}' > "$USER_HOME/.config/warp-terminal/user_preferences.json"

        elif [ "$pkg" = "gdm3" ]; then
            echo "gdm3 shared/default-x-display-manager select sddm" | sudo debconf-set-selections
            sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$pkg"

        else
            sudo apt-get install -y "$pkg"
        fi

        if [ $? -ne 0 ]; then
            echo "Error: Failed to install $pkg. Continuing."
        else
            echo "$pkg installed successfully."
        fi
    else
        echo "$pkg is already installed."
    fi
done

# Ensure SDDM remains the default display manager
echo "Ensuring SDDM is the default display manager..."
if [ -f "/etc/X11/default-display-manager" ]; then
    echo "/usr/sbin/sddm" | sudo tee /etc/X11/default-display-manager >/dev/null
    if [ $? -eq 0 ]; then
        echo "Confirmed sddm as default display manager."
    fi
fi
