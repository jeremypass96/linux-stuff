#!/bin/bash

# Checking to see if we're running as root.
if [ $(id -u) -ne 0 ]; then
    echo "Please run this script as root via 'su' or 'sudo'! Thanks."
    exit
fi

# Define the directory where the script and hook will be copied.
DEST_DIR="/usr/local/bin"
HOOK_DIR="/etc/pacman.d/hooks"

# Content of purge_pacsave.sh
echo '#!/bin/bash

# Remove all .pacsave files
fd -e pacsave . /etc -X rm -rf' | tee "$DEST_DIR/purge_pacsave" > /dev/null

# Content of check_pacsave script.
echo '#!/bin/bash

# Search the pacman log for recent warnings about .pacsave files
log_pacsave=$(grep -P 'warning: .*\.pacsave' /var/log/pacman.log | tail -n 10)

# Verify if .pacnew files exist on the system
system_pacsave=$(fd -e pacsave . /etc -X rm -rf)

# If there are matching .pacsave files in the system, run the purge script
if [[ -n "$log_pacsave" && -n "$system_pacsave" ]]; then
    echo "New .pacsave files detected. Running purge..."
    /usr/local/bin/purge_pacsave
else
    echo "No new .pacsave files detected."
fi' | tee "$DEST_DIR/check_pacsave" > /dev/null

# Content of purge_pacsave.hook
echo '[Trigger]
Operation = Install
Type = Package
Target = *

[Action]
Description = Purging .pacsave files...
When = PostTransaction
Exec = /usr/local/bin/purge_pacsave' | tee "$HOOK_DIR/check_pacsave.hook" > /dev/null
chmod 644 "$HOOK_DIR/check_pacsave.hook"

# Make the script executable and fix permissions.
chmod 744 "$DEST_DIR/purge_pacsave"
chmod 744 "$DEST_DIR/check_pacsave"

echo "Installation complete. You can now use the $DEST_DIR/purge_pacsave script and the $HOOK_DIR/purge_pacsave pacman post-install hook."
