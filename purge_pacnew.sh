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

# Content of check_pacnew script.
echo '#!/bin/bash

# Define color escape codes for output
bold_green="\e[1;32m"
bold_yellow="\e[1;33m"
reset="\e[0m"

# Search the pacman log for recent warnings about .pacnew files
log_pacnew=$(grep -P 'warning: .*\.pacnew' /var/log/pacman.log | tail -n 10)

# Verify if .pacnew files exist on the system
system_pacnew=$(fd -e pacnew . /etc > /dev/null)

# If there are matching .pacnew files in the system, run the purge script
if [[ -n "$log_pacnew" && -n "$system_pacnew" ]]; then
    echo -e "${bold_green}New .pacnew files detected. Running purge...${reset}"
    /usr/local/bin/purge_pacnew
else
    echo -e "${bold_yellow}No new .pacnew files detected.${reset}"
fi' | tee "$DEST_DIR/check_pacnew" > /dev/null

# Content of check_pacnew.hook
echo '[Trigger]
Operation = Install
Type = Package
Target = *

[Action]
Description = Checking for and purging .pacnew files...
When = PostTransaction
Exec = /usr/local/bin/check_pacnew' | tee "$HOOK_DIR/check_pacnew.hook" > /dev/null
chmod 644 "$HOOK_DIR/check_pacnew.hook"

# Make the scripts executable
chmod 744 "$DEST_DIR/purge_pacnew"
chmod 744 "$DEST_DIR/check_pacnew"

echo "Installation complete. You can now use the $DEST_DIR/purge_pacnew and $DEST_DIR/check_pacnew scripts and the $HOOK_DIR/check_pacnew pacman post-install hook."
