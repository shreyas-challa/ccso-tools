#!/bin/bash

# Monitoring and Inspection Script
# Run with: sudo bash monitor.sh

echo "=== BLUE TEAM MONITOR ==="
echo "Running continuous checks... (Press Ctrl+C to stop)"
echo ""

while true; do
    echo ""
    echo "--- $(date) ---"
    echo ""

    # Check recent SSH login attempts (success and failure)
    echo "** Recent SSH Logins (Success): **"
    grep "Accepted" /var/log/secure | tail -5
    echo ""
    echo "** Recent SSH Failed Logins: **"
    grep "Failed" /var/log/secure | tail -5
    echo ""

    # Check for established network connections
    echo "** Established Network Connections: **"
    netstat -tulpn | grep ESTABLISHED
    echo ""

    # Check running processes
    echo "** Top 5 Processes by CPU: **"
    ps -eo pid,user,%cpu,command --sort=-%cpu | head -6
    echo ""

    # Check for newly modified files in crucial directories (in the last 10 min)
    echo "** Files modified in /etc, /var, /usr in last 10 min: **"
    find /etc /var /usr -type f -mmin -10 2>/dev/null | head -10
    echo ""

    sleep 10 # Check every 10 seconds
done