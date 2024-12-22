#!/bin/bash

# Create directory if it doesn't exist
mkdir -p $HOME/.config/fastfetch

# Copy config file to user's config directory
cp -v $HOME/linux-stuff/Dotfiles/config/fastfetch/config.jsonc $HOME/.config/fastfetch/config.jsonc

# Set ownership for the user
chown -R $USER:$USER $HOME/.config/fastfetch

# Copy config file to system-wide skel directory
sudo mkdir -p /etc/skel/.config/fastfetch
sudo cp -v $HOME/.config/fastfetch/config.jsonc /etc/skel/.config/fastfetch/

# Copy config file to root's config directory
sudo mkdir -p /root/.config/fastfetch
sudo cp -v /etc/skel/.config/fastfetch/config.jsonc /root/.config/fastfetch/
