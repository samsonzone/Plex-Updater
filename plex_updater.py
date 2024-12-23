#!/usr/bin/env python3
"""
Plex Media Server Upgrade Script
Developed for Ubuntu Server (tested on 24.04.1)
Copyright (c) 2024 Brian Samson

License: GNU General Public License v3.0 (GPL-3.0)
See LICENSE for details.

Requires sudo privileges
"""

import os
import sys
import json
import requests
import subprocess
from datetime import datetime
import shutil

# Variables
PLEX_URL = "https://plex.tv/api/downloads/5.json"
TEMP_DIR = "/tmp/plex_upgrade"
PLEX_DEB = os.path.join(TEMP_DIR, "plexmediaserver.deb")
LOG_FILE = "/var/log/plex_upgrade.log"


# Logging function with timestamps
def log(message):
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    log_message = f"{timestamp} - {message}"
    print(log_message)
    with open(LOG_FILE, "a") as log_file:
        log_file.write(log_message + "\n")


# Ensure the script is run as root
def check_root():
    if os.geteuid() != 0:
        log("Run this script as root (use sudo).")
        sys.exit(1)


# Create temporary directory
def create_temp_dir():
    os.makedirs(TEMP_DIR, exist_ok=True)
    log(f"Created temporary directory: {TEMP_DIR}")


# Fetch the latest Plex version URL
def get_latest_plex_url():
    try:
        log("Checking for the latest Plex Media Server version...")
        response = requests.get(PLEX_URL)
        response.raise_for_status()
        data = response.json()
        releases = data['computer']['Linux']['releases']
        latest_url = next(
            r['url'] for r in releases if r['build'] == 'linux-x86_64' and r['distro'] == 'debian'
        )
        log(f"Latest version URL: {latest_url}")
        return latest_url
    except Exception as e:
        log(f"Failed to fetch Plex version info. Error: {e}")
        sys.exit(1)


# Download the Plex update
def download_plex(url):
    try:
        log("Downloading the latest Plex Media Server version...")
        response = requests.get(url, stream=True)
        response.raise_for_status()
        with open(PLEX_DEB, "wb") as file:
            for chunk in response.iter_content(chunk_size=8192):
                file.write(chunk)
        log("Download completed.")
    except Exception as e:
        log(f"Download failed. Error: {e}")
        sys.exit(1)


# Install the Plex update
def install_plex():
    try:
        log("Installing Plex Media Server...")
        subprocess.run(["dpkg", "-i", PLEX_DEB], check=True, stderr=subprocess.PIPE, stdout=subprocess.PIPE)
    except subprocess.CalledProcessError:
        log("Install failed—attempting dependency fix.")
        subprocess.run(["apt-get", "-f", "install", "-y"], check=True, stderr=subprocess.PIPE, stdout=subprocess.PIPE)


# Cleanup temporary files
def cleanup():
    log("Removing temporary files...")
    shutil.rmtree(TEMP_DIR, ignore_errors=True)


# Restart Plex Media Server
def restart_plex():
    try:
        log("Restarting Plex Media Server...")
        subprocess.run(["systemctl", "restart", "plexmediaserver"], check=True)
        log("Plex Media Server upgrade completed successfully.")
    except subprocess.CalledProcessError as e:
        log(f"Failed to restart Plex Media Server. Error: {e}")
        sys.exit(1)


# Main function
def main():
    check_root()
    create_temp_dir()
    latest_url = get_latest_plex_url()
    download_plex(latest_url)
    install_plex()
    cleanup()
    restart_plex()


if __name__ == "__main__":
    main()