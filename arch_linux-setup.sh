#!/bin/bash
# This script cleans up an Arch Linux KDE install installed with "archinstall." Run as a normal user.

# Audio buzz/hum fix.
sudo echo "options snd-hda-intel power_save=0 power_save_controller=N" >> /etc/modprobe.d/alsa-base.conf

# Tweak pacman for sane defaults.
sudo sed -i 's/#UseSyslog/UseSyslog'/g /etc/pacman.conf
sudo sed -i 's/#Color/Color'/g /etc/pacman.conf
sudo sed -i 's/"#ParallelDownloads = 5"/"ParallelDownloads = 20"'/g /etc/pacman.conf
sudo sed -i '39s/$/ILoveCandy'/g /etc/pacman.conf

# Setup "blackpac" script. Shell script utility that enables you to backlist packages.
# Download script.
cd ; wget http://downloads.sourceforge.net/project/ig-scripts/blackpac-1.0.1.sh
# Make script executable.
chmod +x blackpac-1.0.1.sh
# Install script.
sudo install blackpac-1.0.1.sh /usr/local/bin/
sudo mv /usr/local/bin/blackpac-1.0.1.sh /usr/local/bin/blackpac
# Blacklist and remvove packages.
sudo blackpac --blacklist qt5-tools v4l-utils kuserfeedback
sudo pacman -R qt5-tools v4l-utils kuserfeedback --noconfirm

# Remove unneeded packages.
sudo pacman -R nano vim --noconfirm

# Install some command-line utilities.
sudo pacman -S mandoc micro neofetch duf bat fd --noconfirm

# Install printing support.
sudo pacman -S cups hplip --noconfirm

# Install Papirus icon theme.
sudo pacman -S papirus-icon-theme --noconfirm

# Install yay AUR helper.
# Download and extract tarball.
cd && wget https://aur.archlinux.org/cgit/aur.git/snapshot/yay-bin.tar.gz
tar -xf yay-bin.tar.gz
# Install yay.
cd yay-bin
makepkg -sic --noconfirm
# Clean up.
cd ; rm -rf yay-bin ; rm -rf yay-bin.tar.gz
# Configure yay options.
yay --editor /usr/bin/micro --answerclean Y --nodiffmenu --noeditmenu --answerupgrade Y --removemake --cleanafter --devel --useask --combinedupgrade --batchinstall --save

# Install Brave web browser.
yay -S brave-bin --noconfirm

# Install fonts.
yay -S ttf-poppins ttf-sourcesanspro --noconfirm

# Install "lsd," a better replacement for ls.
yay -S lsd --noconfirm

# Remove unneeded dependencies.
yay -c --noconfirm