#!/bin/bash

# Generate initial configuration file for bat
bat --generate-config-file

# Modify the configuration settings for current user.
sed -i "s/#--theme=\"TwoDark\"/--theme=\"1337\"/g" "$HOME/.config/bat/config"
sed -i '/--theme=/a --style=\"numbers,changes,header,grid\"' "$HOME/.config/bat/config"
sed -i 's/#--italic-text=always/--italic-text=always/g' "$HOME/.config/bat/config"
echo '--map-syntax "*.conf:INI"' >> "$HOME/.config/bat/config"
echo '--map-syntax "config:INI"' >> "$HOME/.config/bat/config"

# Copy the user configuration to /etc/skel so new users get the same setup.
sudo mkdir -p /etc/skel/.config/bat
sudo cp -v $HOME/.config/bat/config /etc/skel/.config/bat/

# Copy the user configuration to root's configuration.
sudo mkdir -p /root/.config/bat
sudo cp -v $HOME/.config/bat/config /root/.config/bat/

echo "Bat syntax highlighter has been configured with the OneHalfDark theme for both your user and root."
cd $HOME