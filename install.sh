#!/bin/bash
# install.sh – minti3 full system setup + restore (2025-12 FINAL)

USER=$(whoami)
if [ "$USER" = "root" ]; then
    echo "Error: This script should not be run as root. Exiting."
    exit 1
fi

USER_HOME=$(eval echo ~$USER)
GITHUB_REPOS_DIR="$USER_HOME/github-repos"
LOG_DIR="$USER_HOME/log-files/install"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
OUTPUT_FILE="$LOG_DIR/install-$TIMESTAMP.txt"
SCRIPTS_DIR="$GITHUB_REPOS_DIR/minti3/scripts"

mkdir -p "$LOG_DIR"
exec > >(tee -a "$OUTPUT_FILE") 2>&1
echo "=== minti3 install started: $TIMESTAMP ==="

# Cache sudo
echo "Caching sudo credentials..."
sudo -v || exit 1

# Load SSH key immediately – epub_to_audiobook is private
if [[ -f "$USER_HOME/.ssh/id_ed25519" ]]; then
    eval "$(ssh-agent -s)" >/dev/null 2>&1
    ssh-add "$USER_HOME/.ssh/id_ed25519" 2>/dev/null || true
fi

# ------------------------------------------------------------------
# (everything else in your install.sh stays exactly the same below)
# ------------------------------------------------------------------
