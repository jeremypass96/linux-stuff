#!/bin/sh
# This script will clean up and optimize a Debian Xfce (rolling - Sid) installation.

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

# Update package list and upgrade Debian.
sudo nala upgrade

clear

# Install a few GNOME games.
sudo nala install aisleriot four-in-a-row gnome-mines gnome-nibbles swell-foop quadrapassel -y
clear

# Install some useful software.
sudo nala install audacity vlc fd-find bat lsd vim btop -y
clear

# Install OneHalf-Dark theme for Xfce terminal.
sudo mkdir -p /etc/skel/.local/share/xfce4/terminal/colorschemes
cd $HOME && curl https://raw.githubusercontent.com/sonph/onehalf/master/xfce4-terminal/OneHalfDark.theme -o OneHalfDark.theme
mkdir -p $HOME/.local/share/xfce4/terminal/colorschemes
cp -v OneHalfDark.theme /etc/skel/.local/share/xfce4/terminal/colorschemes
cp -v OneHalfDark.theme $HOME/.local/share/xfce4/terminal/colorschemes

clear

# Install and setup Zsh.
nala install zsh -y && ./zsh-setup.sh

# Install fastfetch.
sudo nala install fastfetch -y

clear

# Cleanup systemd boot.
sudo ./cleanup-systemd-boot.sh

# Setup other stuff.
sudo ln -s /usr/bin/batcat /usr/bin/bat && ./bat-setup.sh
sudo ./wallpapers.sh
./lsd-setup.sh
./bat-setup.sh
./zsh-setup.sh
./fastfetch-setup.sh
./vim_setup.sh

# Install Brave web browser.
sudo nala install curl && sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo nala update && sudo nala install brave-browser -y

# Install grub theme.
echo "Installing the GRUB theme..."
cd && git clone https://github.com/vinceliuice/grub2-themes.git
cd grub2-themes && sudo ./install.sh -t stylish
sudo tee -a /etc/default/grub > /dev/null << EOF
GRUB_DISABLE_SUBMENU=y
EOF
cd && rm -rf grub2-themes

# Enable GRUB_DISABLE_RECOVERY in /etc/default/grub.
sudo chmod o+w /etc/default/grub
sudo sed -i s/#GRUB_DISABLE_RECOVERY/GRUB_DISABLE_RECOVERY/g /etc/default/grub
sudo chmod o-w /etc/default/grub

# Update environment variables.
sudo tee -a /etc/environment > /dev/null << EOF
BROWSER=brave
EDITOR=vim
EOF

# Install Liquorix kernel.
curl -s 'https://liquorix.net/install-liquorix.sh' | sudo bash