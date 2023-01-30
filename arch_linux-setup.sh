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
rm blackpac-1.0.1.sh
# Blacklist and remvove packages.
sudo blackpac --blacklist qt5-tools v4l-utils
sudo pacman -R qt5-tools v4l-utils --noconfirm

# Remove unneeded packages.
sudo pacman -R nano vim htop --noconfirm

# Install some command-line utilities.
sudo pacman -S mandoc micro duf bat fd lynis btop --noconfirm

# Install printing support.
sudo pacman -S cups hplip --noconfirm

# Install Papirus icon theme.
sudo pacman -S papirus-icon-theme --noconfirm

# Install yay AUR helper.
# Download and extract tarball.
cd ; wget https://aur.archlinux.org/cgit/aur.git/snapshot/yay-bin.tar.gz
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

# Install topgrade.
yay -S topgrade-bin --noconfirm

# Install pfetch.
yay -S pfetch-git --noconfirm

# Install grub theme.
yay -S grub-theme-stylish-color-1080p-git --noconfirm
sudo sed -i 's|#GRUB_THEME="/path/to/gfxtheme"|GRUB_THEME="/usr/share/grub/themes/stylish-color-1080p/theme.txt"|g' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Remove unneeded dependencies.
yay -c --noconfirm

# Update man pages.
sudo makewhatis

# Update environment variables.
# Configure pfetch.
sudo echo PF_INFO='"ascii os kernel uptime pkgs shell de memory"' >> /etc/environment
# Set BROWSER variable.
sudo echo BROWSER=/usr/bin/brave >> /etc/environment
# Set EDITOR variable.
sudo echo EDITOR=/usr/bin/micro >> /etc/environment
# Set MICRO_TRUECOLOR variable.
sudo echo MICRO_TRUECOLOR=1 >> /etc/environment
