#!/bin/bash
# INVESTIGATE A USER - Run with: sudo bash investigate_user.sh

# 1. EDIT THIS VARIABLE WITH THE SUSPECT USERNAME
TARGET_USER="evil_user"

echo "[+] INVESTIGATING USER: $TARGET_USER"
echo "----------------------------------------"

# 2. CHECK IF USER EXISTS
if ! id "$TARGET_USER" &>/dev/null; then
    echo "[!] User $TARGET_USER does not exist. Exiting."
    exit 1
fi

# 3. SHOW USER'S PROCESSES
echo "[+] Processes owned by $TARGET_USER:"
ps aux | grep "^$TARGET_USER" | head -10
echo ""

# 4. SHOW USER'S CRON JOBS
echo "[+] Cron jobs for $TARGET_USER:"
crontab -l -u $TARGET_USER 2>/dev/null || echo "No cron jobs found or unable to read."
echo ""

# 5. CHECK IF USER HAS SUDO ACCESS
echo "[+] Sudo privileges for $TARGET_USER:"
sudo -l -U $TARGET_USER 2>/dev/null || echo "No sudo privileges found."
echo ""

# 6. LIST RECENT FILES IN THEIR HOME DIRECTORY
USER_HOME=$(eval echo ~$TARGET_USER 2>/dev/null)
if [ -d "$USER_HOME" ]; then
    echo "[+] Recent files in $USER_HOME:"
    find "$USER_HOME" -type f -mtime -1 -exec ls -la {} \; 2>/dev/null | head -10
else
    echo "[!] Home directory for $TARGET_USER not found."
fi
echo ""
echo "[+] Investigation complete. Review the output above for manual action."