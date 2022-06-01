#!/bin/bash
# This shell script cleans up a Fedora KDE spin and removes unnecessary bloatware included with the operating system.

# Checking to see if we're running as root.
if [ $(id -u) -ne 0 ]; then
echo "Please run this script as root! Thanks."
exit
fi

# Update Fedora install.
dnf update -y

# Add RPMFusion repositories.
dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Install Papirus icons.
dnf copr enable dirkdavidis/papirus-icon-theme
dnf install -y papirus-icon-theme

# Remove bloatware.
dnf remove -y libreoffice-* kaddressbook kmail kontact elisa-player kamoso kcolorchooser kgpg kmag kmouth qt5-qdbusviewer firefox

# Install XanMod Linux kernel.
dnf copr enable rmnscnce/kernel-xanmod
dnf install -y kernel-xanmod-tt

# Install the Brave browser.
dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/
rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
dnf install -y brave-browser

# Install the Atom text editor.
rpm --import https://packagecloud.io/AtomEditor/atom/gpgkey
sh -c 'echo -e "[Atom]\nname=Atom Editor\nbaseurl=https://packagecloud.io/AtomEditor/atom/el/7/\$basearch\nenabled=1\ngpgcheck=0\nrepo_gpgcheck=1\ngpgkey=https://packagecloud.io/AtomEditor/atom/gpgkey" > /etc/yum.repos.d/atom.repo'
dnf install -y atom

# Install some useful software.
dnf install -y vlc kdenlive pinta audacity-freeworld PackageKit-command-not-found

# Install the micro text editor and remove nano.
dnf install -y micro xclip && dnf remove -y nano

# Configure micro.
mkdir /home/$USER/.config/micro
cp /home/$USER/linux-stuff/Dotfiles/config/micro/settings.json -o /home/$USER/.config/micro/settings.json
chown $USER:$USER /home/$USER/.config/micro
chown $USER:$USER /home/$USER/.config/micro/*
mkdir -p /etc/skel/.config/micro
cp -v /home/$USER/.config/micro/settings.json /etc/skel/.config/micro/

# Install and configure neofetch.
mkdir /home/$USER/.config/neofetch
dnf install -y neofetch
cp /home/$USER/linux-stuff/Dotfiles/config/neofetch/config.conf -o /home/$USER/.config/neofetch/config.conf
chown $USER:$USER /home/$USER/.config/neofetch
chown $USER:$USER /home/$USER/.config/neofetch/*
mkdir -p /etc/skel/.config/neofetch
cp -v /home/$USER/.config/neofetch/config.conf /etc/skel/.config/neofetch/

# Install KDE wallapers.
dnf install -y plasma-workspace-wallpapers

# Cleanup systemd boot.
./cleanup-systemd-boot.sh

# Install Zsh.
dnf install -y zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
