#!/bin/bash
mkdir /home/$USER/.config/neofetch
cp -v /home/$USER/linux-stuff/Dotfiles/config/neofetch/config.conf /home/$USER/.config/neofetch/config.conf
chown $USER:$USER /home/$USER/.config/neofetch
chown $USER:$USER /home/$USER/.config/neofetch/*
sudo mkdir -p /etc/skel/.config/neofetch
sudo cp -v /home/$USER/.config/neofetch/config.conf /etc/skel/.config/neofetch/
sudo mkdir -p /root/.config/neofetch
sudo cp -v /etc/skel/.config/neofetch/config.conf /root/.config/neofetch/
