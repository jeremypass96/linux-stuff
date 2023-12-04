#!/bin/bash

CONFIG_DIR="$HOME/.config/lsd"

# Create directory structure
mkdir -p "$CONFIG_DIR"
sudo mkdir -p /etc/skel/.config/lsd
sudo mkdir -p /root/.config/lsd

# Copy config file
cp -v "$HOME/linux-stuff/Dotfiles/config/lsd/config.yaml" "$CONFIG_DIR"
sudo cp -v "$CONFIG_DIR/config.yaml" /etc/skel/.config/lsd/
sudo cp -v "$CONFIG_DIR/config.yaml" /root/.config/lsd/

# Set correct ownership
chown -R "$USER:$USER" "$CONFIG_DIR"

echo "lsd configuration has been set up."
