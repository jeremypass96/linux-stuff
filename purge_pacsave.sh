#!/bin/bash

# Checking to see if we're running as root.
if [ $(id -u) -ne 0 ]; then
    echo "Please run this script as root via 'su' or 'sudo'! Thanks."
    exit
fi

# Define the directory where the script and hook will be copied.
DEST_DIR="/usr/local/bin"
HOOK_DIR="/etc/pacman.d/hooks"

# Content of purge_pacnew.sh
echo '#!/bin/bash

# Remove all .pacsave files
fd -e pacsave . /etc -X rm -rf' | tee "$DEST_DIR/purge_pacsave.sh" > /dev/null

# Content of purge_pacnew.hook
echo '[Trigger]
Operation = Install
Type = Package
Target = *

[Action]
Description = Purging .pacsave files...
When = PostTransaction
Exec = /usr/local/bin/purge_pacsave.sh' | tee "$HOOK_DIR/purge_pacsave.hook" > /dev/null
chmod 644 "$HOOK_DIR/purge_pacsave.hook"

# Make the script executable and fix permissions.
chmod 744 "$DEST_DIR/purge_pacsave.sh"

echo "Installation complete. You can now use the $DEST_DIR/purge_pacsave script and the $HOOK_DIR/purge_pacsave pacman post-install hook."
