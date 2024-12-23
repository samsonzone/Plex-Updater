
# Plex Updater

**Plex Updater** is a set of scripts designed to automatically download and install the latest version of **Plex Media Server** on **Ubuntu Server**. It supports both **Bash** and **Python** implementations, giving you flexibility based on your preference.

---

## Features
- Automatically fetches the latest Plex Media Server version.  
- Downloads and installs the update.  
- Logs installation details for troubleshooting.  
- Cleans up temporary files after installation.  
- Restarts Plex Media Server to apply the update.

---

## Tested Environment
- **OS:** Ubuntu Server 24.04.1  
- **Scripts:**  
  - **Bash Version:** `plex_updater.sh`  
  - **Python Version:** `plex_updater.py`  

---

## Requirements

### **Bash Version Requirements:**
- **sudo/root privileges**  
- **jq** installed for JSON parsing:  
```bash
sudo apt-get install jq -y
```

---

### **Python Version Requirements:**
- **sudo/root privileges**  
- **Python 3.x** installed:  
```bash
sudo apt install python3 python3-pip -y
```

- **Requests library** for API calls:  
```bash
pip install requests
```

---

## Usage

### **Bash Script Usage**
1. Clone this repository:
```bash
git clone https://github.com/bmsam/Plex-Updater.git
cd Plex-Updater
```

2. Make the Bash script executable:
```bash
chmod +x plex_updater.sh
```

3. Run the script as root or with sudo:
```bash
sudo ./plex_updater.sh
```

---

### **Python Script Usage**
1. Ensure Python 3 and required libraries are installed:
```bash
sudo apt install python3 python3-pip -y
pip install requests
```

2. Run the Python script as root or with sudo:
```bash
sudo python3 plex_updater.py
```

---

## Logs
Installation logs are stored in:
```
/var/log/plex_upgrade.log
```

---

## License
This project is licensed under the **GNU General Public License v3.0**.  
See the [LICENSE](https://github.com/bmsam/Plex-Updater/blob/main/license) file for details.  

---

## Contributions
Contributions and improvements are welcome!  
Feel free to **submit a pull request** or **open an issue** if you find any bugs.

---

## Disclaimer
This script is provided **as-is** without any warranties.  
**Use it at your own risk.**
