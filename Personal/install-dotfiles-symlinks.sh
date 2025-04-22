#!/bin/bash

# Set paths
DOTFILES_DIR="/home/brett/dotfiles-minti3"
USER_HOME="/home/brett"

# Check dotfiles directory
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Error: $DOTFILES_DIR does not exist."
    exit 1
fi

# Create symlinks in home directory
for file in .bashrc .bashrc-personal .fehbg .gtkrc-2.0.mine sddm.conf; do
    if [ -f "$DOTFILES_DIR/$file" ]; then
        target="$USER_HOME/$file"
        if [ -L "$target" ] && [ "$(readlink "$target")" = "$DOTFILES_DIR/$file" ]; then
            echo "Symlink for $target already exists and is correct, skipping"
        else
            ln -sf "$DOTFILES_DIR/$file" "$target"
            echo "Created symlink for $target"
        fi
    fi
done

# Symlink .fonts directory
if [ -d "$DOTFILES_DIR/.fonts" ]; then
    target="$USER_HOME/.fonts"
    if [ -L "$target" ] && [ "$(readlink "$target")" = "$DOTFILES_DIR/.fonts" ]; then
        echo "Symlink for $target already exists and is correct, skipping"
    else
        ln -sf "$DOTFILES_DIR/.fonts" "$target"
        echo "Created symlink for $target"
    fi
fi

# Ensure .config exists
mkdir -p "$USER_HOME/.config"

# Symlink each .config item
for item in betterlockscreen i3-logout bluetooth-connect dunst geany gtk-3.0 i3 micro polybar qBittorrent rofi Thunar mimeapps.list; do
    if [ -e "$DOTFILES_DIR/.config/$item" ]; then
        target="$USER_HOME/.config/$item"
        if [ -L "$target" ] && [ "$(readlink "$target")" = "$DOTFILES_DIR/.config/$item" ]; then
            echo "Symlink for $target already exists and is correct, skipping"
        else
            ln -sf "$DOTFILES_DIR/.config/$item" "$target"
            echo "Created symlink for $target"
        fi
    fi
done

# Ensure local applications dir exists
mkdir -p "$USER_HOME/.local/share/applications"

# Symlink .desktop files
for file in "$DOTFILES_DIR/.local/share/applications/"*.desktop; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        target="$USER_HOME/.local/share/applications/$filename"
        if [ -L "$target" ] && [ "$(readlink "$target")" = "$file" ]; then
            echo "Symlink for $target already exists and is correct, skipping"
        else
            ln -sf "$file" "$target"
            echo "Created symlink for $target"
        fi
    fi
done

# Ensure X11 config dir exists and symlink touchpad config
sudo mkdir -p /etc/X11/xorg.conf.d
if [ -f "$DOTFILES_DIR/etc/X11/xorg.conf.d/40-libinput.conf" ]; then
    target="/etc/X11/xorg.conf.d/40-libinput.conf"
    if [ -L "$target" ] && [ "$(readlink "$target")" = "$DOTFILES_DIR/etc/X11/xorg.conf.d/40-libinput.conf" ]; then
        echo "Symlink for $target already exists and is correct, skipping"
    else
        sudo ln -sf "$DOTFILES_DIR/etc/X11/xorg.conf.d/40-libinput.conf" "$target"
        echo "Created symlink for $target"
    fi
fi

echo "Symlinks set up successfully."