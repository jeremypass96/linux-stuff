#!/bin/bash
# This script sets up btop with Catppuccin color scheme and custom config file. Run as a normal user!

# Setup Catppuccin theme for btop.
mkdir -p /home/$USER/.config/btop/themes
cd && git clone https://github.com/catppuccin/btop.git
cd btop/themes && cp -v *.theme /home/$USER/.config/btop/themes/
cd && rm -rf btop

# Copy over custom btop config file.
mkdir -p /home/$USER/.config/btop && cp -v /home/$USER/linux-stuff/Dotfiles/config/btop/btop.conf /home/$USER/.config/btop/btop.conf
mkdir -p /etc/skel/.config/btop
cp -v /home/$USER/linux-stuff/Dotfiles/config/btop/btop.conf /etc/skel/.config/btop/btop.conf
mkdir -p /root/.config/btop
cp -v /home/$USER/linux-stuff/Dotfiles/config/btop/btop.conf /root/.config/btop/btop.conf