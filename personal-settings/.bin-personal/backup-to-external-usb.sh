#!/bin/bash

set -e

# Define common rsync options
RSYNC_OPTS="-avh -r --exclude=.cache --mkpath --delete"
DEST="/media/brett/D8B3-FFAE/minti3/personal-settings/"

# Backup .bin-personal directory
rsync $RSYNC_OPTS /home/brett/.bin-personal/ $DEST/.bin-personal

# Backup .config directories and files
for dir in \
    Cryptomator \
    dconf \
    expressvpn \
    fish \
    gtk-3.0 \
    polybar \
    rofi \
    Thunar \
    xfce4
do
    rsync $RSYNC_OPTS /home/brett/.config/$dir/ $DEST/.config/$dir
done

for file in \
    i3/config \
    micro/settings.json \
    mimeapps.list \
    nano/nanorc \
    qBittorrent/qBittorrent.conf
do
    rsync $RSYNC_OPTS /home/brett/.config/$file $DEST/.config/$file
done

# Backup bashrc-personal directory and soft link
rsync $RSYNC_OPTS /home/brett/bash_aliases/ $DEST/bash_aliases/

# Backup usr files
#rsync $RSYNC_OPTS /usr/share/gvfs/mounts/network.mount $DEST/usr/share/gvfs/mounts/
#rsync $RSYNC_OPTS /usr/bin/autotiling $DEST/usr/bin/

# Backup .local
rsync $RSYNC_OPTS ~/.local/share/applications/ $DEST/.local/share/applications/
rsync $RSYNC_OPTS ~/.local/lib/ $DEST/.local/lib/
    #statements

# Error handling
if [ $? -ne 0 ]; then
    echo "An error occurred during the backup process."
    exit 1
fi

echo "Backup completed successfully."