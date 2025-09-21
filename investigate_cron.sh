#!/bin/bash
# LIST ALL CRON - Run with: sudo bash investigate_cron.sh

echo "[+] LISTING ALL CRON JOBS"
echo "----------------------------------------"

BACKUP_DIR="/root/cron_investigation_$(date +%Y%m%d_%H%M%S)"
mkdir -p $BACKUP_DIR

echo "[+] Backing up all cron to $BACKUP_DIR for safe keeping..."

# Backup system cron
cp -r /etc/cron* $BACKUP_DIR/ 2>/dev/null
# Backup user cron
for user in $(ls /home); do
    crontab -l -u $user > "$BACKUP_DIR/cron_$user" 2>/dev/null
done
crontab -l -u root > "$BACKUP_DIR/cron_root" 2>/dev/null

echo "[+] Displaying all user cron jobs:"
echo ""

# Show the contents of each backup file (i.e., each user's cron)
for cron_file in $BACKUP_DIR/cron_*; do
    echo "--- Crontab for: $(basename $cron_file | sed 's/cron_//') ---"
    cat $cron_file
    echo ""
done

echo "[+] Displaying system cron files (/etc/cron.d/):"
ls -la /etc/cron.d/
echo ""
cat /etc/cron.d/* 2>/dev/null || echo "No files in /etc/cron.d/ or unable to read."

echo "[+] Investigation complete. Review the output above."
echo "[+] Backups saved to: $BACKUP_DIR"