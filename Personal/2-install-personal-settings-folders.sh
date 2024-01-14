#!/bin/bash

# Source and destination directories
source_directories=( "/etc" "/usr" "/var" )
destination_directories=( "/" "/" "/" )

# Files to copy from each directory
files_to_copy=(
    "/etc/rc.local"
    "/etc/vconsole.conf"
    "/var/spool/cron/brett"
    "/var/spool/cron/root"
    "/usr/share/gvfs/mounts/network.mount"
)

# Iterate through source directories and copy specified files to the destination
for ((i=0; i<${#source_directories[@]}; i++)); do
    source_directory="${source_directories[i]}"
    destination_directory="${destination_directories[i]}"

    for file in "${files_to_copy[@]}"; do
        source_path="$source_directory$file"
        destination_path="$destination_directory$file"

        if [ -e "$source_path" ]; then
            mkdir -p "$(dirname "$destination_path")"
            cp "$source_path" "$destination_path"
            echo "Copied $file to $destination_directory"

            # Set correct permissions and ownership
            if [[ "$file" == "/etc/rc.local" || "$file" == "/etc/vconsole.conf" ]]; then
                chmod 644 "$destination_path"
                chown root:root "$destination_path"
                echo "Set permissions and ownership for $file"
            elif [[ "$file" == "/var/spool/cron/brett" || "$file" == "/var/spool/cron/root" ]]; then
                chmod 600 "$destination_path"
                chown root:root "$destination_path"
                echo "Set permissions and ownership for $file"
            elif [[ "$file" == "/usr/share/gvfs/mounts/network.mount" ]]; then
                mkdir -p "$(dirname "$destination_path")"
                cp "$source_path" "$destination_path"
                chmod 644 "$destination_path"
                chown root:root "$destination_path"
                echo "Set permissions and ownership for $file"
            fi
        else
            echo "$file not found in $source_directory"
        fi
    done
done
