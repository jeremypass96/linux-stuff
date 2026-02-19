#!/bin/bash
# Checking to see if we're running as root.
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script as root via 'su' or 'sudo'! Thanks."
    exit
fi

mkdir -pv /etc/bat
chmod 755 /etc/bat
wcurl -o /etc/bat/config https://raw.githubusercontent.com/jeremypass96/linux-stuff/refs/heads/main/Dotfiles/config/bat/config
chmod go+r /etc/bat/config
mkdir -pv /etc/bat/themes
chmod 755 /etc/bat/themes
wget -P /etc/bat/themes https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Mocha.tmTheme
chmod go+r /etc/bat/themes/Catppuccin\ Mocha.tmTheme
bat cache --build
