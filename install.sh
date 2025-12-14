#!/bin/bash
# install.sh – FINAL 2025-12-14 – Syncthing skip on non-desktop

USER=$(whoami)
if [ "$USER" = "root" ]; then
    echo "Error: This script should not be run as root. Exiting."
    exit 1
fi

# Set Git identity – consistent authorship on every machine
git config --global user.name "Sugarcrisp-ui"
git config --global user.email "brettcrisp2@gmail.com"

USER_HOME=$(eval echo ~$USER)
GITHUB_REPOS_DIR="$USER_HOME/github-repos"
LOG_DIR="$USER_HOME/log-files/install"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
OUTPUT_FILE="$LOG_DIR/install-$TIMESTAMP.txt"
SCRIPTS_DIR="$GITHUB_REPOS_DIR/minti3/scripts"

mkdir -p "$LOG_DIR"
exec > >(tee -a "$OUTPUT_FILE") 2>&1
echo "=== minti3 install started: $TIMESTAMP ==="

sudo -v || exit 1

# Load SSH key early
[[ -f "$USER_HOME/.ssh/id_ed25519" ]] && eval "$(ssh-agent -s)" >/dev/null 2>&1 && ssh-add "$USER_HOME/.ssh/id_ed25519" 2>/dev/null

# Clone minti3 repo if missing
[ ! -d "$GITHUB_REPOS_DIR/minti3" ] && mkdir -p "$GITHUB_REPOS_DIR" && git clone https://github.com/Sugarcrisp-ui/minti3.git "$GITHUB_REPOS_DIR/minti3"
cd "$GITHUB_REPOS_DIR/minti3" || exit 1

# Backup detection
ULTIMATE_PATH=$(find /media/$USER -maxdepth 4 -type d -name "ULTIMATE*" -print 2>/dev/null | head -n 1)
[ -z "$ULTIMATE_PATH" ] && { echo "ERROR: No backup found"; exit 1; }
LATEST_BACKUP=$(find "$(dirname "$ULTIMATE_PATH")" -type d -name "ULTIMATE*" 2>/dev/null | sort -r | head -n 1)
CONFIG_SRC="$LATEST_BACKUP/user/home/brett"

echo "Found backup → $LATEST_BACKUP"

# Run all scripts
scripts=(
    "installi3mint.sh"
    "installi3apps.sh"
    "installflatpaks.sh"
    "installdockerservices.sh"
    "installepubtoaudiobook.sh"
    "installi3lockcolor.sh"
    "installbetterlockscreen.sh"
    "installi3logout.sh"
    "installautotiling.sh"
    "installsddmsimplicity.sh"
    "installxfcetheme.sh"
    "installrealvnc.sh"
    "setupcronjobs.sh"
    "updatei3ipc.sh"
    "setdpi.sh"
    "setcodecsbc.sh"
)

for script in "${scripts[@]}"; do
    [ -f "$SCRIPTS_DIR/$script" ] && bash "$SCRIPTS_DIR/$script" || echo "Warning: $script missing"
done

# FULL RESTORE
echo "=== RESTORING ALL YOUR FILES FROM BACKUP ==="
rsync -ah --delete --info=progress2 "$CONFIG_SRC"/. "$USER_HOME"/

# SYNCTHING CLEANUP – only on non-desktop
CURRENT_HOSTNAME=$(hostname)
if [[ "$CURRENT_HOSTNAME" != "brett-ms-7d82" ]]; then
    echo "Non-desktop detected — removing Syncthing folders"
    SYNCTHING_DIRS=(
        ".bin-personal"
        ".config"
        ".fonts"
        "Appimages"
        "Calibre-Library"
        "Documents"
        "Pictures"
        ".local/share/applications"
        "Shared"
        "Videos"
        ".local/share/ice/firefox"
    )
    for dir in "${SYNCTHING_DIRS[@]}"; do
        rm -rf "$USER_HOME/$dir/.stfolder" 2>/dev/null || true
    done
fi

echo "=== minti3 installation + full restore complete! ==="
echo "Reboot → choose i3 → perfection"