#!/bin/bash
# This shell script cleans up a Fedora KDE spin and removes unnecessary bloatware included with the operating system.

# Checking to see if we're running as root.
if [ $(id -u) -ne 0 ] ; then
echo "Please run this script as root! Thanks."
exit
fi

# Update Fedora install.
dnf update -y

# Add RPMFusion repositories.
dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Remove bloatware.
dnf remove -y libreoffice-* kaddressbook kmail kontact elisa-player kamoso kcolorchooser kgpg kmag kmouth qt5-qdbusviewer

# Install XanMod Linux kernel.
dnf copr enable rmnscnce/kernel-xanmod
dnf install -y kernel-xanmod-tt

# Install some useful software.
dnf install -y vlc kdenlive pinta audacity-freeworld command-not-found

# Install the micro text editor and remove nano.
dnf install -y micro xclip && dnf remove -y nano

# Configure micro.
mkdir /home/$USER/.config/micro
curl https://raw.githubusercontent.com/jeremypass96/freebsd-setup-scripts/main/Dotfiles/config/micro/settings.json -o /home/$USER/.config/micro/settings.json
chown $USER /home/$USER/.config/micro/*
mkdir -p /etc/skel/.config/micro
cp -v /home/$USER/.config/micro/settings.json /etc/skel/.config/micro/

# Install and configure neofetch.
mkdir /home/$USER/.config/neofetch
dnf install -y neofetch
curl https://raw.githubusercontent.com/jeremypass96/freebsd-setup-scripts/main/Dotfiles/config/neofetch/config.conf -o /home/$USER/.config/neofetch/config.conf
chown $USER /home/$USER/.config/neofetch/*
mkdir -p /etc/skel/.config/neofetch
cp -v /home/$USER/.config/neofetch/config.conf /etc/skel/.config/neofetch/

# Install and configure zsh.
dnf install -y zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
curl https://raw.githubusercontent.com/jeremypass96/linux-stuff/main/Dotfiles/.zshrc -o /home/$USER/.zshrc
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

# Install KDE wallapers.
dnf install -y plasma-workspace-wallpapers
