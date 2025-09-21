#!/bin/bash

# Blue Team Tool Install Script
# Run with: sudo bash install.sh

set -e # Exit on any error

echo "[+] Updating system and installing dependencies..."
yum install -y epel-release
yum update -y
yum install -y wget git unzip fail2ban clamav clamav-update lynis chkrootkit

echo "[+] Starting and enabling critical services..."
systemctl enable firewalld --now
systemctl enable fail2ban --now

echo "[+] Downloading and preparing additional tools..."
# Directory for our scripts and tools
mkdir -p /opt/blue-team
cp monitor.sh /opt/blue-team/
cp harden.sh /opt/blue-team/
chmod +x /opt/blue-team/*.sh

echo "[+] Setup complete! Tools located in /opt/blue-team/"
echo "[+] Remember to:"
echo "    1. Run: sudo bash harden.sh"
echo "    2. Run: sudo bash /opt/blue-team/monitor.sh"