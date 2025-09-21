#!/bin/bash
# CHECK SSH KEYS FOR USERS - Run with: sudo bash investigate_ssh_keys.sh

echo "[+] CHECKING SSH AUTHORIZED KEYS FOR USERS"
echo "----------------------------------------"

# List of users to check. ADD OR REMOVE USERS HERE AS NEEDED.
USERS_TO_CHECK=("root" "git" "ec2-user" "centos" "ubuntu")

for TARGET_USER in "${USERS_TO_CHECK[@]}"; do
    echo "--- Checking user: $TARGET_USER ---"

    USER_HOME=$(eval echo ~$TARGET_USER 2>/dev/null)
    AUTH_KEYS_FILE="$USER_HOME/.ssh/authorized_keys"

    if [ -f "$AUTH_KEYS_FILE" ]; then
        echo "[+] Authorized keys for $TARGET_USER:"
        cat "$AUTH_KEYS_FILE"
        echo ""
    else
        echo "[!] No authorized_keys file found for $TARGET_USER."
        echo ""
    fi
done
echo "[+] Investigation complete. Look for unfamiliar keys in the output above."