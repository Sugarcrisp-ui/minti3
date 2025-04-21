#!/bin/bash

# Ensure dotfiles directory exists
if [ ! -d "~/dotfiles" ]; then
    echo "Error: ~/dotfiles directory not found. Please ensure it exists."
    exit 1
fi

# Create symlinks for files in ~/
for file in .bashrc .bashrc-personal .fehbg .gtkrc-2.0.mine sddm.conf; do
    if [ -f "~/dotfiles/$file" ]; then
        ln -sf ~/dotfiles/$file ~/$file
        echo "Created symlink for ~/$file"
    else
        echo "Warning: ~/dotfiles/$file not found, skipping"
    fi
done

# Create symlink for .fonts directory
if [ -d "~/dotfiles/.fonts" ]; then
    ln -sf ~/dotfiles/.fonts ~/.fonts
    echo "Created symlink for ~/.fonts"
else
    echo "Warning: ~/dotfiles/.fonts not found, skipping"
fi

# Create .config directory if it doesn't exist
mkdir -p ~/.config

# Create symlinks for .config subdirectories and files
for item in archlinux-betterlockscreen archlinux-logout bluetooth-connect dunst geany gtk-3.0 i3 micro paru polybar qBittorrent rofi Thunar mimeapps.list; do
    if [ -e "~/dotfiles/.config/$item" ]; then
        ln -sf ~/dotfiles/.config/$item ~/.config/$item
        echo "Created symlink for ~/.config/$item"
    else
        echo "Warning: ~/dotfiles/.config/$item not found, skipping"
    fi
done

# Create .local/share/applications directory if it doesn't exist
mkdir -p ~/.local/share/applications

# Create symlinks for .desktop files in ~/.local/share/applications/
for file in ~/dotfiles/.local/share/applications/*.desktop; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        ln -sf "$file" ~/.local/share/applications/"$filename"
        echo "Created symlink for ~/.local/share/applications/$filename"
    else
        echo "Warning: No .desktop files found in ~/dotfiles/.local/share/applications/"
        break
    fi
done

# Verify symlinks
echo "Verifying symlinks..."
ls -l ~/.bashrc ~/.bashrc-personal ~/.fehbg ~/.gtkrc-2.0.mine ~/.sddm.conf ~/.fonts ~/.config/ ~/.local/share/applications/

echo "Symlink creation complete."