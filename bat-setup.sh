#!/bin/bash

# Generate initial configuration file for bat
bat --generate-config-file

# Modify the configuration settings
sed -i 's/#--theme="TwoDark"/--theme="1337"/g' "$HOME/.config/bat/config"
sed -i 's/#--italic-text=always/--italic-text=always/g' "$HOME/.config/bat/config"
echo '--map-syntax "*.conf:INI"' >> "$HOME/.config/bat/config"
echo '--map-syntax "config:INI"' >> "$HOME/.config/bat/config"

# Copy the user configuration to /etc/skel so new users get the same setup
sudo mkdir -p /etc/skel/.config/bat
sudo cp -v "$HOME/.config/bat/config" /etc/skel/.config/bat/

# Copy the user configuration to root's configuration
sudo mkdir -p /root/.config/bat
sudo cp -v "$HOME/.config/bat/config" /root/.config/bat/

# Setup the Catppuccin "mocha" theme for bat
cd "$HOME" || exit
git clone https://github.com/catppuccin/bat.git
cd bat
sudo sh -c 'mkdir -p "$(bat --config-dir)/themes"; cp *.tmTheme "$(bat --config-dir)/themes"; bat cache --build; sed -i "s/1337/Catppuccin-mocha/g" "$HOME/.config/bat/config"'

echo "Bat syntax highlighter has been configured with the Catppuccin 'mocha' theme for both your user and root."
rm -rf $HOME/bat
sudo rm -rf root/bat
