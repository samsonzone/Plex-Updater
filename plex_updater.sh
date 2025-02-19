#!/bin/bash
# Plex Media Server Upgrade Script
# Developed for Ubuntu Server (tested on 24.04.1)
# Copyright (c) 2025 Brian Samson
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
PLEX_SERVICE="plexmediaserver"

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "Run this script as root (use sudo)." >&2
    exit 1
fi

# Logging function with timestamps
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Step 1: Get the current installed version
CURRENT_VERSION=$(dpkg -s plexmediaserver 2>/dev/null | grep '^Version:' | awk '{print $2}')
if [[ -z $CURRENT_VERSION ]]; then
    log "Plex Media Server is not installed or version could not be determined. Proceeding with installation."
else
    log "Current installed version: $CURRENT_VERSION"
fi

# Step 2: Fetch the latest Plex version details
log "Checking for the latest Plex Media Server version..."
JSON_DATA=$(curl -s "$PLEX_URL")

# Log raw response for debugging
echo "$JSON_DATA" > /tmp/plex_api_response.json
log "Raw API response saved to /tmp/plex_api_response.json"

if [[ -z "$JSON_DATA" || "$JSON_DATA" == "null" ]]; then
    log "Failed to fetch API response. Exiting."
    exit 1
fi

# Extracting correct version and URL
LATEST_VERSION=$(echo "$JSON_DATA" | jq -r '.computer.Linux.version')
LATEST_URL=$(echo "$JSON_DATA" | jq -r '.computer.Linux.releases[] | select(.build == "linux-x86_64" and .distro == "debian") | .url')

if [[ -z "$LATEST_VERSION" || "$LATEST_VERSION" == "null" || -z "$LATEST_URL" || "$LATEST_URL" == "null" ]]; then
    log "Failed to extract version or URL from API response. Check /tmp/plex_api_response.json. Exiting."
    exit 1
fi

log "Latest available version: $LATEST_VERSION"

# Step 3: Compare versions and decide whether to proceed
if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
    log "Plex Media Server is already up-to-date. No upgrade needed. Exiting."
    exit 0
fi

log "A new version is available. Proceeding with the upgrade..."

# Step 4: Prep temporary directory
mkdir -p "$TEMP_DIR"
log "Created temporary directory: $TEMP_DIR"

# Step 5: Download the update
log "Downloading the latest Plex Media Server version..."
curl -L -o "$PLEX_DEB" "$LATEST_URL"

if [[ ! -f $PLEX_DEB ]]; then
    log "Download failed. Exiting."
    exit 1
fi
log "Download completed."

# Step 6: Install the update
log "Installing Plex Media Server..."
dpkg -i "$PLEX_DEB" &>> "$LOG_FILE" || {
    log "Install failed—attempting dependency fix."
    apt-get -f install -y &>> "$LOG_FILE"
}

# Step 7: Cleanup
log "Removing temporary files..."
rm -rf "$TEMP_DIR"

# Step 8: Restart Plex
log "Restarting Plex Media Server..."
systemctl restart "$PLEX_SERVICE"

log "Plex Media Server upgrade completed successfully."
