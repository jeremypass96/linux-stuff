#!/bin/bash
mkdir -p $HOME/.config/neofetch
cp -v $HOME/linux-stuff/Dotfiles/config/neofetch/config.conf $HOME/.config/neofetch/config.conf
chown $USER:$USER $HOME/.config/neofetch
chown $USER:$USER $HOME/.config/neofetch/*
sudo mkdir -p /etc/skel/.config/neofetch
sudo cp -v $HOME/.config/neofetch/config.conf /etc/skel/.config/neofetch/
sudo mkdir -p /root/.config/neofetch
sudo cp -v /etc/skel/.config/neofetch/config.conf /root/.config/neofetch/
