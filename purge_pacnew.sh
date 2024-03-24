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

# Define the directory containing .pacnew files
PACNEW_DIR="/etc"

# Remove all .pacnew files
find "$PACNEW_DIR" -name "*.pacnew" -type f -exec rm -f {} \;' | tee "$DEST_DIR/purge_pacnew.sh" > /dev/null

# Content of purge_pacnew.hook
echo '[Trigger]
Operation = Install
Type = Package
Target = *

[Action]
Description = Purging .pacnew files...
When = PostTransaction
Exec = /usr/local/bin/purge_pacnew.sh' | tee "$HOOK_DIR/purge_pacnew.hook" > /dev/null

# Make the script executable
chmod +x "$DEST_DIR/purge_pacnew.sh"

echo "Installation complete. You can now use the purge_pacnew.sh script and the purge_pacnew.hook pacman post-install hook."
