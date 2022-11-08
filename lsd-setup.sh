#!/bin/bash
mkdir -p /home/$USER/.config/lsd
cp -v /home/$USER/linux-stuff/Dotfiles/config/lsd/config.yaml /home/$USER/.config/lsd/config.yaml
chown $USER:$USER /home/$USER/.config/lsd
chown $USER:$USER /home/$USER/.config/lsd/*
sudo mkdir -p /etc/skel/.config/lsd
sudo cp -v /home/$USER/.config/lsd/config.yaml /etc/skel/.config/lsd/
sudo mkdir -p /root/.config/lsd
sudo cp -v /etc/skel/.config/lsd/config.yaml /root/.config/lsd/
