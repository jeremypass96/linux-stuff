#!/bin/bash
# This script sets up btop with Catppuccin color scheme and custom config file.

# Checking to see if we're running as root.
if [ $(id -u) -ne 0 ]; then
	echo "Please run this setup script as root via 'su'! Thanks."
    exit
fi

# Setup Catppuccin theme for btop.
themes_dir="/etc/btop/themes"
config_dir="$HOME/.config/btop"
btop_config="$HOME/linux-stuff/Dotfiles/config/btop/btop.conf"

mkdir -p "$themes_dir"
cd $HOME && git clone https://github.com/catppuccin/btop.git
cp -v $HOME/btop/themes/*.theme "$themes_dir"/
rm -rf btop

# Copy over custom btop config file.
mkdir -p "$config_dir" && cp -v "$btop_config" "$config_dir"/btop.conf

# Set correct user ownership permissions.
chown -R $USER:$USER "$config_dir"

# Copy the edited config file to other locations.
mkdir -p /etc/skel/.config/btop
cp -v "$btop_config" /etc/skel/.config/btop/btop.conf
mkdir -p /root/.config/btop
cp -v "$btop_config" /root/.config/btop/btop.conf

echo "btop has been configured with Catppuccin theme and custom config."
