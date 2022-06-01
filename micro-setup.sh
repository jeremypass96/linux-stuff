#!/bin/bash
mkdir /home/$USER/.config/micro
cp -v /home/$USER/linux-stuff/Dotfiles/config/micro/settings.json /home/$USER/.config/micro/settings.json
chown $USER:$USER /home/$USER/.config/micro
chown $USER:$USER /home/$USER/.config/micro/*
sudo mkdir -p /etc/skel/.config/micro
Sudo cp -v /home/$USER/.config/micro/settings.json /etc/skel/.config/micro/
