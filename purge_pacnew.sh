#!/bin/bash

# Checking to see if we're running as root.
if [ $(id -u) -ne 0 ]; then
    echo "Please run this script as root via 'su' or 'sudo'! Thanks."
    exit
fi

# Define the directory where the script and hook will be copied.
DEST_DIR="/usr/local/bin"
HOOK_DIR="/etc/pacman.d/hooks"

# Content of purge_pacnew script.
echo '#!/bin/bash

# Remove all .pacnew files
fd -e pacnew . /etc -X rm -rf' | tee "$DEST_DIR/purge_pacnew" > /dev/null

# Content of purge_pacnew.hook
echo '[Trigger]
Operation = Install
Type = Package
Target = *

[Action]
Description = Purging .pacnew files...
When = PostTransaction
Exec = /usr/local/bin/purge_pacnew' | tee "$HOOK_DIR/purge_pacnew.hook" > /dev/null
chmod 644 "$HOOK_DIR/purge_pacnew.hook"

# Make the script executable
chmod 744 "$DEST_DIR/purge_pacnew"

echo "Installation complete. You can now use the $DEST_DIR/purge_pacnew script and the $HOOK_DIR/purge_pacnew pacman post-install hook."
