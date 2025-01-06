#!/bin/bash

# Checking to see if we're running as root.
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script as root via 'su' or 'sudo'! Thanks."
    exit
fi

# Define the directory where the script and hook will be copied.
DEST_DIR="/usr/local/bin"
HOOK_DIR="/etc/pacman.d/hooks"

# Make pacman.d hooks directory and fix permissions.
sudo mkdir -p /etc/pacman.d/hooks
sudo chmod 755 /etc/pacman.d/hooks

# Content of restore_pacsave script.
tee "$DEST_DIR/restore_pacsave" > /dev/null << EOF
#!/bin/bash

# Define bold color escape codes for output
bold_blue="\e[1;34m"
bold_green="\e[1;32m"
bold_yellow="\e[1;33m"
bold_red="\e[1;31m"
reset="\e[0m"

# Find all .pacsave files and restore them
pacsave_files=$(fd -e pacsave . /etc)

if [[ -n "$pacsave_files" ]]; then
    echo -e "${bold_blue}Restoring .pacsave files...${reset}"
    for pacsave in $pacsave_files; do
        # Construct the original file path by removing .pacsave suffix
        original_file="${pacsave%.pacsave}"

        # Check if the original file exists
        if [[ -e "$original_file" ]]; then
            echo -e "${bold_red}Backing up existing file: $original_file${reset}"
            mv "$original_file" "$original_file.bak"
        fi

        # Restore the .pacsave file to its original location
        mv "$pacsave" "$original_file"
        echo -e "${bold_green}Restored $pacsave to $original_file${reset}"
    done
else
    echo -e "${bold_yellow}No .pacsave files found.${reset}"
fi
EOF

# Content of restore_pacsave.hook
tee "$HOOK_DIR/restore_pacsave.hook" > /dev/null << EOF
[Trigger]
Operation = Install
Type = Package
Target = *

[Action]
Description = Checking for and restoring .pacsave files...
When = PostTransaction
Exec = /usr/local/bin/restore_pacsave
EOF

# Fix permissions for pacman hook.
chmod 644 "$HOOK_DIR/restore_pacsave.hook"

# Make the script executable and fix permissions.
chmod 744 "$DEST_DIR/restore_pacsave"

echo "Installation complete. You can now use the $DEST_DIR/restore_pacsave script and the $HOOK_DIR/restore_pacsave pacman post-install hook."