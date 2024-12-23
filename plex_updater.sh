#!/bin/bash
# Plex Media Server Upgrade Script
# Developed for Ubuntu Server (tested on 24.04.1)
# Copyright (c) 2024 Brian Samson
#
# License: GNU General Public License v3.0 (GPL-3.0)
# See LICENSE for details.
#
# Requires sudo privileges

# Variables
PLEX_URL="https://plex.tv/api/downloads/5.json"
TEMP_DIR="/tmp/plex_upgrade"
PLEX_DEB="$TEMP_DIR/plexmediaserver.deb"
LOG_FILE="/var/log/plex_upgrade.log"

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "Run this script as root (use sudo)." >&2
    exit 1
fi

# Logging function with timestamps
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Step 1: Prep temporary directory
mkdir -p "$TEMP_DIR"
log "Created temporary directory: $TEMP_DIR"

# Step 2: Fetch latest Plex version URL
log "Checking for the latest Plex Media Server version..."
LATEST_URL=$(curl -s "$PLEX_URL" | jq -r '.computer.Linux.releases[] | select(.build == "linux-x86_64") | .url')

if [[ -z $LATEST_URL ]]; then
    log "Failed to fetch Plex version info. Exiting."
    exit 1
fi

log "Latest version found: $LATEST_URL"

# Step 3: Download the update
log "Downloading Plex Media Server..."
curl -L -o "$PLEX_DEB" "$LATEST_URL"

if [[ ! -f $PLEX_DEB ]]; then
    log "Download failed. Exiting."
    exit 1
fi
log "Download completed."

# Step 4: Install the update
log "Installing Plex Media Server..."
dpkg -i "$PLEX_DEB" &>> "$LOG_FILE" || {
    log "Install failed—attempting dependency fix."
    apt-get -f install -y &>> "$LOG_FILE"
}

# Step 5: Cleanup
log "Removing temporary files..."
rm -rf "$TEMP_DIR"

# Step 6: Restart Plex
log "Restarting Plex Media Server..."
systemctl restart plexmediaserver

log "Plex Media Server upgrade completed successfully."
