# Plex Auto Updater

**Plex Auto Updater** is a Bash script designed to automatically download and install the latest version of Plex Media Server on Ubuntu Server.  

## Tested Environment
- **OS:** Ubuntu Server 24.04.1  
- **Script Name:** `plex_auto_updater.sh`  

## Features
- Fetches the latest Plex Media Server version from the official API.  
- Downloads and installs the update automatically.  
- Logs installation details for troubleshooting.  
- Cleans up temporary files after installation.  
- Restarts Plex Media Server to apply the update.  

## Requirements
- **sudo/root privileges** to install packages and restart services.  
- **jq** package installed for JSON parsing.  

### Install `jq`:
```bash
sudo apt-get install jq -y
