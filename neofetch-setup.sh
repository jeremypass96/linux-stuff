#!/bin/bash

# Create directory if it doesn't exist
mkdir -p $HOME/.config/neofetch

# Copy config file to user's config directory
cp -v $HOME/linux-stuff/Dotfiles/config/neofetch/config.conf $HOME/.config/neofetch/config.conf

# Set ownership for the user
chown -R $USER:$USER $HOME/.config/neofetch

# Copy config file to system-wide skel directory
sudo mkdir -p /etc/skel/.config/neofetch
sudo cp -v $HOME/.config/neofetch/config.conf /etc/skel/.config/neofetch/

# Copy config file to root's config directory
sudo mkdir -p /root/.config/neofetch
sudo cp -v /etc/skel/.config/neofetch/config.conf /root/.config/neofetch/
