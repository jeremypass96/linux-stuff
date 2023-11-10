#!/bin/sh
# This script will clean up and optimize a Debian Xfce (rolling - Sid) installtion.

# Audio buzz/hum fix.
sudo touch /etc/modprobe.d/alsa-base.conf && sudo chmod o+w /etc/modprobe.d/alsa-base.conf
echo "options snd-hda-intel power_save=0 power_save_controller=N" > /etc/modprobe.d/alsa-base.conf
sudo chmod o-w /etc/modprobe.d/alsa-base.conf

clear

# Install Nala, a better apt front-end.
echo "deb [arch=amd64,arm64,armhf] http://deb.volian.org/volian/ scar main" | sudo tee /etc/apt/sources.list.d/volian-archive-scar-unstable.list
wget -qO - https://deb.volian.org/volian/scar.key | sudo tee /etc/apt/trusted.gpg.d/volian-archive-scar-unstable.gpg > /dev/null
sudo apt update && sudo apt install nala

clear

# Update mirrors.
sudo nala fetch

clear

# Remove bloatware.
sudo nala purge xterm xsane exfalso quodlibet libreoffice-common firefox-esr -y

clear

# Install a few GNOME games.
sudo nala install aisleriot four-in-a-row gnome-mines gnome-nibbles swell-foop quadrapassel -y

# Update package list and upgrade Debian.
sudo nala upgrade

clear

# Install some useful software.
sudo nala install audacity vlc git fd-find bat lsd micro btop -y

clear

# Install Catppuccin themes for Xfce terminal.
cd && git clone https://github.com/catppuccin/xfce4-terminal.git
mkdir -pv $HOME/.local/share/xfce4/terminal/colorschemes
cp -v xfce4-terminal/src/*.theme $HOME/.local/share/xfce4/terminal/colorschemes
rm -rf xfce4-terminal

clear

# Install and setup Zsh.
nala install zsh -y && ./zsh-setup.sh

clear

# Cleanup systemd boot.
sudo ./cleanup-systemd-boot.sh

# Setup other stuff.
sudo ln -s /usr/bin/batcat /usr/bin/bat && ./bat-setup.sh
./btop-setup.sh
./lsd-setup.sh
./micro-setup.sh

# Install Brave web browser.
sudo nala install curl && sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo nala update && sudo nala install brave-browser -y
