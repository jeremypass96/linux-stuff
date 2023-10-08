#!/bin/bash
# This script sets up btop with Catppuccin color scheme and custom config file. Run as a normal user!

# Setup Catppuccin theme for btop.
themes_dir="/etc/btop/themes"
config_dir="$HOME/.config/btop"
btop_config="$HOME/linux-stuff/Dotfiles/config/btop/btop.conf"

sudo mkdir -p "$themes_dir"
cd && git clone https://github.com/catppuccin/btop.git
cd btop/themes && sudo cp -v *.theme "$themes_dir"/
cd && rm -rf btop

# Copy over custom btop config file.
mkdir -p "$config_dir" && cp -v "$btop_config" "$config_dir"/btop.conf

# Copy the edited config file to other locations.

sudo mkdir -p /etc/skel/.config/btop
sudo cp -v "$btop_config" /etc/skel/.config/btop/btop.conf
sudo mkdir -p /root/.config/btop
sudo cp -v "$btop_config" /root/.config/btop/btop.conf

echo "btop has been configured with Catppuccin theme and custom config."
