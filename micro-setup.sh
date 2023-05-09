#!/bin/bash
mkdir -p /home/$USER/.config/micro
cp -v /home/$USER/linux-stuff/Dotfiles/config/micro/settings.json /home/$USER/.config/micro/settings.json
chown $USER:$USER /home/$USER/.config/micro
chown $USER:$USER /home/$USER/.config/micro/*
sudo mkdir -p /etc/skel/.config/micro
sudo cp -v /home/$USER/.config/micro/settings.json /etc/skel/.config/micro/
sudo mkdir -p /root/.config/micro
sudo cp -v /etc/skel/.config/micro/settings.json /root/.config/micro

# Setup Catppuccin colors.
cd
git clone https://github.com/catppuccin/micro.git
mkdir -p ~/.config/micro/colorschemes
sudo mkdir -p /etc/skel/.config/micro/colorschemes
sudo mkdir -p /root/.config/micro/colorschemes
cp -v micro/src/*.micro ~/.config/micro/colorschemes
sudo cp -v micro/src/*.micro /etc/skel/.config/micro/colorschemes
sudo cp -v micro/src/*.micro /root/.config/micro/colorschemes
rm -rf micro/
