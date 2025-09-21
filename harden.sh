#!/bin/bash

# System Hardening Script
# Run with: sudo bash harden.sh

set -e

echo "[!] This script will make major security changes. Are you sure? (yes/no)"
read answer
if [ "$answer" != "yes" ]; then
    echo "Exiting."
    exit 1
fi

BACKUP_SUFFIX=$(date +%Y%m%d_%H%M%S)
SSHD_CONFIG="/etc/ssh/sshd_config"

echo "[+] Backing up SSH config to $SSHD_CONFIG.backup_$BACKUP_SUFFIX"
cp $SSHD_CONFIG $SSHD_CONFIG.backup_$BACKUP_SUFFIX

echo "[+] Hardening SSH configuration..."
# Use sed to comment out old settings and add new ones
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' $SSHD_CONFIG
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' $SSHD_CONFIG
sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' $SSHD_CONFIG
# Add AllowUsers, you MUST change 'your_user' to the actual username you will use!
sed -i 's/^#*AllowUsers.*/AllowUsers your_user/' $SSHD_CONFIG
sed -i 's/^#*X11Forwarding.*/X11Forwarding no/' $SSHD_CONFIG
sed -i 's/^#*MaxAuthTries.*/MaxAuthTries 3/' $SSHD_CONFIG

echo "[+] Configuring firewall (firewalld) to deny all, allow only SSH and HTTP..."
firewall-cmd --permanent --remove-service=dhcpv6-client
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --permanent --add-service=ssh
# If Gitea uses a custom port, add it here (e.g., 3000)
# firewall-cmd --permanent --add-port=3000/tcp
firewall-cmd --reload

echo "[+] Restarting SSH service to apply new settings..."
systemctl restart sshd

echo "[+] Harden script complete. PLEASE VERIFY YOU CAN STILL SSH IN BEFORE LOGGING OUT!"
echo "[+] If you get locked out, use the backup file: $SSHD_CONFIG.backup_$BACKUP_SUFFIX"