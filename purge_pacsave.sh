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

# Define color escape codes for output
bold_green="\e[1;32m"
bold_yellow="\e[1;33m"
reset="\e[0m"

# Search the pacman log for recent warnings about .pacsave files
log_pacsave=$(grep -P 'warning: .*\.pacsave' /var/log/pacman.log | tail -n 10)

# Verify if .pacsave files exist on the system
system_pacsave=$(fd -e pacsave . /etc > /dev/null)

# If there are matching .pacsave files in the system, run the purge script
if [[ -n "$log_pacsave" && -n "$system_pacsave" ]]; then
    echo -e "${bold_green}New .pacsave files detected. Running purge...${reset}"
    /usr/local/bin/purge_pacsave
else
    echo -e "${bold_yellow}No new .pacsave files detected.${reset}"
fi' | tee "$DEST_DIR/check_pacsave" > /dev/null

# Content of purge_pacsave.hook
echo '[Trigger]
Operation = Install
Type = Package
Target = *

[Action]
Description = Checking for and purging .pacsave files...
When = PostTransaction
Exec = /usr/local/bin/check_pacsave' | tee "$HOOK_DIR/check_pacsave.hook" > /dev/null
chmod 644 "$HOOK_DIR/check_pacsave.hook"

# Make the script executable and fix permissions.
chmod 744 "$DEST_DIR/purge_pacsave"
chmod 744 "$DEST_DIR/check_pacsave"

echo "Installation complete. You can now use the $DEST_DIR/purge_pacsave script and the $HOOK_DIR/purge_pacsave pacman post-install hook."
