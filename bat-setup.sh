#!/bin/bash

# Prompt the user to choose a theme
echo "Select a theme for the 'bat' syntax highlighter:"
echo "1. Latte"
echo "2. Frappé"
echo "3. Macchiato"
echo "4. Mocha"
read -p "Enter the number of your choice: " theme_choice

case $theme_choice in
    1)
        selected_theme="Catppuccin Latte"
        ;;
    2)
        selected_theme="Catppuccin Frappe"
        ;;
    3)
        selected_theme="Catppuccin Macchiato"
        ;;
    4)
        selected_theme="Catppuccin Mocha"
        ;;
    *)
        echo "Invalid choice. Defaulting to 'Mocha' theme."
        selected_theme="Catppuccin Mocha"
        ;;
esac

# Generate initial configuration file for bat
bat --generate-config-file

# Modify the configuration settings for current user.
sed -i "s/#--theme=\"TwoDark\"/--theme=\"$selected_theme\"/g" "$HOME/.config/bat/config"
sed -i 's/#--italic-text=always/--italic-text=always/g' "$HOME/.config/bat/config"
echo '--map-syntax "*.conf:INI"' >> "$HOME/.config/bat/config"
echo '--map-syntax "config:INI"' >> "$HOME/.config/bat/config"

# Copy the user configuration to /etc/skel so new users get the same setup.
sudo mkdir -p /etc/skel/.config/bat
sudo cp -v $HOME/.config/bat/config /etc/skel/.config/bat/

# Copy the user configuration to root's configuration.
sudo mkdir -p /root/.config/bat
sudo cp -v $HOME/.config/bat/config /root/.config/bat/

# Setup the Catppuccin theme for bat.
cd $HOME
git clone https://github.com/catppuccin/bat.git && cd bat/themes
sh -c 'mkdir -p $(bat --config-dir)/themes; cp *.tmTheme $(bat --config-dir)/themes; bat cache --build'

# Copy themes to /etc/skel.
sudo sh -c 'mkdir -p /etc/skel/.config/bat/themes; cp *.tmTheme /etc/skel/.config/bat/themes'

# Copy themes to root's home directory.
sudo sh -c 'mkdir -p /root/.config/bat/themes; cp *.tmTheme /root/.config/bat/themes; bat cache --build'

echo "Bat syntax highlighter has been configured with the selected theme ($selected_theme) for both your user and root."
cd $HOME
rm -rf $HOME/bat
sudo rm -rf /root/bat
