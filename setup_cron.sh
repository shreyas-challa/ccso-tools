#!/bin/bash
# SETUP HELPFUL MONITORING CRON JOBS - Run with: sudo bash setup_guardian_cron.sh

echo "[+] Setting up guardian cron jobs for continuous monitoring..."

# Temporary file to hold our new cron jobs
CRON_TEMP=$(mktemp)

# 1. CRON JOB: Check if critical services (SSH, Gitea) are running every 5 minutes.
#    If a service is down, it will log the failure and attempt a restart.
echo "*/5 * * * * root systemctl is-active --quiet sshd || echo \"[CRITICAL] Service sshd is down on \$(hostname) at \$(date)\" >> /var/log/blue-team.log && systemctl restart sshd" >> "$CRON_TEMP"
echo "*/5 * * * * root systemctl is-active --quiet gitea || echo \"[CRITICAL] Service gitea is down on \$(hostname) at \$(date)\" >> /var/log/blue-team.log && systemctl restart gitea" >> "$CRON_TEMP"

# 2. CRON JOB: Run a rootkit check every hour. It runs quietly and only logs if something is found.
echo "0 * * * * root if [ -x \"\$(command -v chkrootkit)\" ]; then (chkrootkit | grep -E \"INFECTED|Warning\") >> /var/log/blue-team.log; fi" >> "$CRON_TEMP"

# 3. CRON JOB: Run a Lynis audit once a day to look for new hardening opportunities.
echo "0 0 * * * root if [ -x \"\$(command -v lynis)\" ]; then lynis audit system --cronjob >> /var/log/lynis.log; fi" >> "$CRON_TEMP"

# 4. CRON JOB: Check disk space every 6 hours to avoid getting filled up.
echo "0 */6 * * * root df -h | grep -E '(/dev/sda1|/dev/vda1|/)$' >> /var/log/blue-team.log" >> "$CRON_TEMP"

# 5. CRON JOB: Monitor user additions every minute. Critical for catching red team creating users.
echo "* * * * * root tail -n 10 /etc/passwd > /tmp/passwd.tail; if ! diff /tmp/passwd.tail /tmp/passwd.prev 2>/dev/null; then echo \"[WARNING] /etc/passwd was modified at \$(date)\" >> /var/log/blue-team.log; fi; cp /tmp/passwd.tail /tmp/passwd.prev" >> "$CRON_TEMP"

# 6. CRON JOB: Check for large numbers of failed SSH attempts every 2 minutes, a sign of brute force.
echo "*/2 * * * * root if [ \$(grep \"Failed password\" /var/log/secure | tail -n 20 | wc -l) -ge 15 ]; then echo \"[ALERT] High number of failed SSH logins detected at \$(date)\" >> /var/log/blue-team.log; fi" >> "$CRON_TEMP"

# Install the new cron jobs from the temp file
echo "[+] Installing new cron jobs to /etc/cron.d/blue-team-guardian"
cat "$CRON_TEMP" > /etc/cron.d/blue-team-guardian

# Set the correct permissions for the cron file
chmod 600 /etc/cron.d/blue-team-guardian

# Clean up the temporary file
rm -f "$CRON_TEMP"

# Create the log file for our jobs to write to
touch /var/log/blue-team.log
chmod 644 /var/log/blue-team.log

echo "[+] Guardian cron jobs installed successfully!"
echo "[+] Monitoring logs will be written to: /var/log/blue-team.log"
echo "[+] View live log output with: sudo tail -f /var/log/blue-team.log"