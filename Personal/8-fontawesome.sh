#!/bin/bash

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

# Check if Font Awesome 6 is already installed
if check_font_installed "Font Awesome 6"; then
    echo "Font Awesome 6 is already installed."
else
    # Download Font Awesome 6
    wget -P "$dest_dir" "$url1" || handle_error "Failed to download Font Awesome 6 archive."

    # Unzip Font Awesome 6
    unzip "$dest_dir/fontawesome-free-6.5.1-desktop.zip" -d "$dest_dir" || handle_error "Failed to unzip Font Awesome 6 archive."

    # Move the fonts to /usr/share/fonts/
    sudo mv "$dest_dir/fontawesome-free-6.5.1-desktop" /usr/share/fonts/ || handle_error "Failed to move Font Awesome 6 fonts."

    # Change ownership to $USER:$USER
    sudo chown -R $USER:$USER /usr/share/fonts/fontawesome-free-6.5.1-desktop || handle_error "Failed to change ownership for Font Awesome 6."

    echo "Font Awesome 6 installed successfully."
    run_fc_cache=true
fi

# Check if Font Awesome 5 is already installed
if check_font_installed "Font Awesome 5"; then
    echo "Font Awesome 5 is already installed."
else
    # Download Font Awesome 5
    wget -P "$dest_dir" "$url2" || handle_error "Failed to download Font Awesome 5 archive."

    # Unzip Font Awesome 5
    unzip "$dest_dir/fontawesome-free-5.15.4-desktop.zip" -d "$dest_dir" || handle_error "Failed to unzip Font Awesome 5 archive."

    # Move the fonts to /usr/share/fonts/
    sudo mv "$dest_dir/fontawesome-free-5.15.4-desktop" /usr/share/fonts/ || handle_error "Failed to move Font Awesome 5 fonts."

    # Change ownership to $USER:$USER
    sudo chown -R $USER:$USER /usr/share/fonts/fontawesome-free-5.15.4-desktop || handle_error "Failed to change ownership for Font Awesome 5."

    echo "Font Awesome 5 installed successfully."
    run_fc_cache=true
fi

# Run fc-cache only if fonts were installed
if [ "$run_fc_cache" = true ]; then
    # Update the font cache
    fc-cache -fv || handle_error "Failed to update font cache."
fi

echo "Font Awesome 5 and 6 installation completed."
