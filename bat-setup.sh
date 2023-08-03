#!/bin/bash
bat --generate-config-file
sed -i s/#--theme='"TwoDark"'/--theme='"1337"'/g /home/$USER/.config/bat/config
sed -i s/#--italic-text=always/--italic-text=always/g /home/$USER/.config/bat/config
echo "--map-syntax "*.conf:INI"" >> /home/$USER/.config/bat/config
echo "--map-syntax "config:INI"" >> /home/$USER/.config/bat/config
sudo mkdir -p /etc/skel/.config/bat && sudo cp -v /home/$USER/.config/bat/config /etc/skel/.config/bat
sudo mkdir -p /root/.config/bat && sudo cp -v /etc/skel/.config/bat/config /root/.config/bat/config

# Setup the Catppuccin "mocha" theme for bat.
cd && git clone https://github.com/catppuccin/bat.git
cd bat
mkdir -p "$(bat --config-dir)/themes"
cp *.tmTheme "$(bat --config-dir)/themes"
bat cache --build
sed -i 's/1337/Catppuccin-mocha'/g /home/$USER/.config/bat/config
