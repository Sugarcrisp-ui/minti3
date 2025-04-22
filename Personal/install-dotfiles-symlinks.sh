#!/bin/bash

# Script to create symlinks for dotfiles in Linux Mint i3 setup
set -e

# Define paths (hardcoded to avoid sudo changing $HOME to /root)
DOTFILES_DIR="/home/brett/dotfiles-minti3"
USER_HOME="/home/brett"
LOG_FILE="$USER_HOME/dotfiles-symlinks-install.log"

# Log function
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
    echo "$1"
}

# Check if a path is within DOTFILES_DIR
is_within_dotfiles() {
    local path="$1"
    local real_path
    real_path=$(realpath --no-symlinks "$path" 2>/dev/null || echo "$path")
    if [[ "$real_path" == "$DOTFILES_DIR"* ]]; then
        return 0
    fi
    return 1
}

# Check dotfiles directory
if [ ! -d "$DOTFILES_DIR" ]; then
    log "Error: $DOTFILES_DIR does not exist."
    exit 1
fi

# Initialize log file
> "$LOG_FILE"
log "Starting dotfiles symlink setup"

# Function to create symlink for a file or directory
create_symlink() {
    local source="$1"
    local target="$2"
    local sudo_needed="${3:-false}"

    # Skip if source doesn't exist
    if [ ! -e "$source" ] && [ ! -d "$source" ]; then
        log "Source $source does not exist, skipping"
        return
    fi

    # Skip if target is within DOTFILES_DIR
    if is_within_dotfiles "$target"; then
        log "Target $target is within $DOTFILES_DIR, skipping to prevent overwrite"
        return
    fi

    # Check if target exists
    if [ -e "$target" ] || [ -L "$target" ]; then
        # Check if it's a symlink pointing to the correct source
        if [ -L "$target" ] && [ "$(readlink -f "$target")" = "$source" ]; then
            log "Symlink already correct: $target -> $source"
            if [ "$sudo_needed" = "true" ]; then
                sudo chmod --reference="$source" "$target"
            else
                chmod --reference="$source" "$target"
            fi
            log "Updated permissions for $target to match $source"
            return
        fi
        # Back up existing file or directory
        log "Target $target exists, backing up"
        if [ "$sudo_needed" = "true" ]; then
            sudo mv "$target" "${target}.bak"
        else
            mv "$target" "${target}.bak"
        fi
    fi

    # Create parent directory if needed
    if [ "$sudo_needed" = "true" ]; then
        sudo mkdir -p "$(dirname "$target")"
    else
        mkdir -p "$(dirname "$target")"
    fi

    # Create symlink
    if [ "$sudo_needed" = "true" ]; then
        sudo ln -sf "$source" "$target"
    else
        ln -sf "$source" "$target"
    fi
    if [ $? -eq 0 ]; then
        if [ "$sudo_needed" = "true" ]; then
            sudo chmod --reference="$source" "$target"
        else
            chmod --reference="$source" "$target"
        fi
        log "Created symlink: $target -> $source with matching permissions"
    else
        log "Failed to create symlink: $target -> $source"
        exit 1
    fi
}

# Note: Explicit file/directory lists are used instead of 'find' to ensure only
# intended files are symlinked, avoiding issues with unexpected files and ensuring
# subdirectories (e.g., .config/i3/) are handled correctly.

# Top-level files
for file in .bashrc .bashrc-personal .fehbg .gtkrc-2.0.mine sddm.conf; do
    create_symlink "$DOTFILES_DIR/$file" "$USER_HOME/$file"
done

# .fonts directory
create_symlink "$DOTFILES_DIR/.fonts" "$USER_HOME/.fonts"

# .config subdirectories and files
for item in betterlockscreen i3-logout bluetooth-connect dunst geany gtk-3.0 i3 micro polybar qBittorrent rofi Thunar mimeapps.list; do
    create_symlink "$DOTFILES_DIR/.config/$item" "$USER_HOME/.config/$item"
done

# .desktop files
for file in "$DOTFILES_DIR/.local/share/applications/"*.desktop; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        create_symlink "$file" "$USER_HOME/.local/share/applications/$filename"
    fi
done

# Touchpad config
create_symlink "$DOTFILES_DIR/etc/X11/xorg.conf.d/40-libinput.conf" "/etc/X11/xorg.conf.d/40-libinput.conf" "true"

log "Symlink creation completed."
exit 0