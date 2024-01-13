#!/bin/bash
set -e

# Get the directory of the script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

declare -a personalDirs=(
  "$HOME/.bin-personal"
  "$HOME/.ssh"
  "$HOME/Appimages"
  "$HOME/Calibre-Library"
  "$HOME/Shared"
  "$HOME/Trading"
  "$HOME/bashrc-personal"
  "$HOME/Github"
  "$HOME/Insync"
  "$ROOT/personal"
  "$ROOT/personal/.config"
  "$ROOT/var/spool/cron"
  "$ROOT/usr/share/sddm/themes/arcolinux-sugar-candy/Backgrounds"
)

declare -a configDirs=(
  "$SCRIPT_DIR/.bin-personal"
  "$SCRIPT_DIR/.config"
  "$SCRIPT_DIR/.local"
  "$SCRIPT_DIR/.bashrc-personal"
)

tput setaf 11;
echo "################################################################"
echo "Creating private folders we use later"
echo "################################################################"
tput sgr0

for dir in "${personalDirs[@]}"; do
  [ -d "$dir" ] || mkdir -p "$dir"
done

tput setaf 11;
echo "################################################################"
echo "Copying bash_aliases and .gtkrc-2.0.mine"
echo "################################################################"
tput sgr0

cp "$SCRIPT_DIR/bash_aliases" ~
cp "$SCRIPT_DIR/.gtkrc-2.0.mine" ~

tput setaf 11;
echo "################################################################"
echo "Copying .bin-personal"
echo "################################################################"
tput sgr0

cp -Rf "${configDirs[0]}" ~

tput setaf 11;
echo "################################################################"
echo "Copying .config"
echo "################################################################"
tput sgr0

cp -Rf "${configDirs[1]}" ~

tput setaf 11;
echo "################################################################"
echo "Copying .local/share/applications/webapp files"
echo "################################################################"
tput sgr0

cp -Rf "${configDirs[2]}" ~

tput setaf 11;
echo "################################################################"
echo "Copying .bashrc-personal"
echo "################################################################"
tput sgr0

cp "${configDirs[3]}" ~

# tput setaf 11;
# echo "################################################################"
# echo "Copying systemd files to /etc/systemd/system/"
# echo "################################################################"
# tput sgr0

# sudo chown -R root:root "$SCRIPT_DIR/etc/"
# sudo rsync -avz "$SCRIPT_DIR/etc/systemd/system/"* /etc/systemd/system/

tput setaf 11;
echo "################################################################"
echo "Copying vconsole files to /etc/systemd/system/"
echo "################################################################"
tput sgr0

# This makes the font size bigger in tty
sudo chown -R root:root /etc/vconsole.conf
sudo rsync -avz "$SCRIPT_DIR/etc/vconsole.conf" /etc/

tput setaf 11;
echo "################################################################"
echo "Copying rc.local files to /etc/systemd/system/"
echo "################################################################"
tput sgr0

sudo chown -R root:root /etc/rc.local
sudo rsync -avz "$SCRIPT_DIR/etc/rc.local" /etc/

tput setaf 11;
echo "################################################################"
echo "Copying selected files to /usr/"
echo "################################################################"
tput sgr0

sudo chown -R root:root /usr/
sudo rsync -avz "$SCRIPT_DIR/usr/share/gvfs/mounts/network.mount" /usr/share/gvfs/mounts/network.mount

tput setaf 11;
echo "################################################################"
echo "Copying crontab files for user and root"
echo "################################################################"
tput sgr0

sudo chown -R root:root  "$SCRIPT_DIR/var/spool/cron/root"
sudo rsync -avz "$SCRIPT_DIR/var/spool/cron/" /var/spool/cron

echo "################################################################"
echo "#########            folders created            ################"
echo "################################################################"
