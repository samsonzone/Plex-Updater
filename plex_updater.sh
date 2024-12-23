#!/bin/bash
# Plex Media Server Upgrade Script
# Developed for Ubuntu Server (tested on 24.04.1)
# Copyright (c) 2024 Brian Samson
#
# License: GNU General Public License v3.0 (GPL-3.0)
# This script is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, 
# either version 3 of the License, or (at your option) any later version.
#
# This script is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
# See the GNU General Public License for more details: https://www.gnu.org/licenses/gpl-3.0.html
#
# Requires sudo privileges

# Variables
PLEX_URL="https://plex.tv/api/downloads/5.json"
TEMP_DIR="/tmp/plex_upgrade"
PLEX_DEB="$TEMP_DIR/plexmediaserver.deb"

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "Run this script as root (use sudo)." >&2
    exit 1
fi

# Step 1: Prep temporary directory
mkdir -p "$TEMP_DIR"

# Step 2: Fetch latest Plex version URL
echo "Checking for the latest Plex Media Server version..."
LATEST_URL=$(curl -s "$PLEX_URL" | jq -r '.computer.Linux.releases[] | select(.build == "linux-x86_64") | .url')

if [[ -z $LATEST_URL ]]; then
    echo "Failed to fetch Plex version info. Exiting." >&2
    exit 1
fi

echo "Latest version found: $LATEST_URL"

# Step 3: Download the update
echo "Downloading Plex Media Server..."
curl -L -o "$PLEX_DEB" "$LATEST_URL"

if [[ ! -f $PLEX_DEB ]]; then
    echo "Download failed. Exiting." >&2
    exit 1
fi

# Step 4: Install the update
echo "Installing Plex Media Server..."
dpkg -i "$PLEX_DEB" >> /var/log/plex_upgrade.log 2>&1 || {
    echo "Install failed—attempting dependency fix." >&2
    apt-get -f install -y
}

# Step 5: Cleanup
echo "Removing temporary files..."
rm -rf "$TEMP_DIR"

# Step 6: Restart Plex
echo "Restarting Plex Media Server..."
systemctl restart plexmediaserver

echo "Plex Media Server upgrade completed."
