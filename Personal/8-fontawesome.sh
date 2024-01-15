#!/bin/bash
set -e

# Define the URLs for the Font Awesome files
url1="https://use.fontawesome.com/releases/v6.5.1/fontawesome-free-6.5.1-desktop.zip"
url2="https://use.fontawesome.com/releases/v5.15.4/fontawesome-free-5.15.4-desktop.zip"

# Set the destination directory to the script's current directory
dest_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/"

# Function to check if a font is already installed
check_font_installed() {
    fc-list | grep -i "$1" &> /dev/null
}

# Function to handle errors
handle_error() {
    echo "Error: $1"
    exit 1
}

# Function to install Font Awesome
install_font_awesome() {
    # Download Font Awesome
    wget -P "$dest_dir" "$1" || handle_error "Failed to download Font Awesome archive."

    # Unzip Font Awesome
    unzip "$dest_dir/$(basename "$1")" -d "$dest_dir" || handle_error "Failed to unzip Font Awesome archive."

    # Move the fonts to /usr/share/fonts/
    sudo mv "$dest_dir/fontawesome-free-$(echo "$1" | grep -oP '(?<=releases/)[^/]+')" /usr/share/fonts/ || handle_error "Failed to move Font Awesome fonts."

    # Change ownership to $USER:$USER
    sudo chown -R $USER:$USER /usr/share/fonts/fontawesome-free-$(echo "$1" | grep -oP '(?<=releases/)[^/]+') || handle_error "Failed to change ownership for Font Awesome."

    echo "Font Awesome installed successfully."
    run_fc_cache=true
}

# Install Font Awesome 6
install_font_awesome "$url1"

# Install Font Awesome 5
install_font_awesome "$url2"

# Run fc-cache only if fonts were installed
if [ "$run_fc_cache" = true ]; then
    # Update the font cache
    fc-cache -fv || handle_error "Failed to update font cache."
fi

# Clean up unnecessary files
rm "$dest_dir/fontawesome-free-6.5.1-desktop.zip"
rm "$dest_dir/fontawesome-free-5.15.4-desktop.zip"

echo "Font Awesome 5 and 6 installation completed, and installation files removed."
