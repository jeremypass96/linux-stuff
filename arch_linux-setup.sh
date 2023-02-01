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
sudo pacman -R nano vim htop kate htop --noconfirm

# Remove KDE Wayland session.
sudo pacman -R plasma-wayland-session --noconfirm

# Install some command-line utilities.
sudo pacman -S mandoc micro duf bat fd lynis btop --noconfirm

# Install Papirus icon theme.
sudo pacman -S papirus-icon-theme --noconfirm

# Install spell checking support.
sudo pacman -S aspell aspell-en --noconfirm

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
yay --editor /usr/bin/micro --answerclean A --nodiffmenu --noeditmenu --answerupgrade Y --removemake --cleanafter --devel --useask --combinedupgrade --batchinstall --save

# Install Konsole color scheme.
yay -S konsole-snazzy-git --noconfirm

# Install and configure printing support.
yay -S cups hplip-lite print-manager system-config-printer cups-pk-helper --noconfirm
sudo systemctl enable cups ; sudo systemctl start cups

# Install PolKit rules for desktop privileges. Enables automounting, suspend and hibernation, and CPU frequency settings.
yay -S desktop-privileges --noconfirm

# Install Brave web browser.
yay -S brave-bin --noconfirm

# Install fonts.
yay -S ttf-poppins ttf-sourcesanspro ttf-ibm-plex ttf-ms-fonts --noconfirm

# Install "lsd," a better replacement for ls.
yay -S lsd --noconfirm

# Install topgrade.
yay -S topgrade-bin --noconfirm

# Install pfetch.
yay -S pfetch-git --noconfirm

# Install Pamac, GUI frontend to install software.
yay -S pamac-aur pamac-tray-icon-plasma --noconfirm

# Install and configure VSCodium.
yay -S vscodium-bin vscodium-bin-marketplace --noconfirm
mkdir -p /home/$USER/.config/VSCodium/User ; cp /home/$USER/linux-stuff/Dotfiles/config/VSCodium/User/settings.json /home/$USER/.config/VSCodium/User/settings.json
vscodium --install-extension PKief.material-icon-theme BeardedBear.beardedtheme

# Install grub theme.
yay -S grub-theme-stylish-color-1080p-git --noconfirm
sudo sed -i 's|#GRUB_THEME="/path/to/gfxtheme"|GRUB_THEME="/usr/share/grub/themes/stylish-color-1080p/theme.txt"|g' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Install Wine.
yay -S wine-installer wine-gecko wine-mono --noconfirm

# Remove unneeded dependencies.
yay -c --noconfirm

# Install some useful software.
sudo pacman -S unrar vlc transmission-qt pinta audacity k3b juk okular --noconfirm
# Install dependencies for k3b.
sudo pacman -S cdrtools dvd+rw-tools cdrdao transcode --noconfirm

# Install some KDE games!
sudo pacman -S kapman kblocks kbounce --noconfirm

# Install Spotify.
yay -S spotify --noconfirm

# Update man pages.
sudo makewhatis

# Setup config files and stuff.
cd linux-stuff/
./bat-setup.sh
./lsd-setup.sh
./micro-setup.sh
sudo ./cleanup-systemd-boot.sh

# Configure Zsh.
yay -S oh-my-zsh-git oh-my-zsh-plugin-syntax-highlighting oh-my-zsh-plugin-autosuggestions --noconfirm
cp -v Dotfiles/.zshrc /home/$USER/.zshrc
sed -i 's/'"export ZSH="$HOME/.oh-my-zsh""'/'"export ZSH="/usr/share/oh-my-zsh""''/g /home/$USER/.zshrc
sed -i 's/'"# zstyle ':omz:update' mode disabled"'/'"zstyle ':omz:update' mode disabled"''/g /home/$USER/.zshrc
sed -i 's/'"zstyle ':omz:update' mode auto"'/'"# zstyle ':omz:update' mode auto"''/g /home/$USER/.zshrc
sed -i 's/'"zstyle ':omz:update' frequency 14"'/'"# zstyle ':omz:update' frequency 14"''/g /home/$USER/.zshrc
cd
sudo cp -v /home/$USER/.zshrc /etc/skel/.zshrc
sudo cp -v /etc/skel/.zshrc /root/.zshrc

# Install and configure find-the-command utility.
yay -S find-the-command --noconfirm
sudo pacman -S fzf pkgfile --noconfirm
echo "source /usr/share/doc/find-the-command/ftc.zsh quiet" >> /home/$USER/.zshrc
echo "source /usr/share/doc/find-the-command/ftc.zsh quiet" >> /etc/skel/.zshrc
echo "source /usr/share/doc/find-the-command/ftc.zsh quiet" >> /root/.zshrc
sudo systemctl enable pkgfile-update.timer
sudo systemctl start pkgfile-update.timer
sudo pkgfile --update

# Update environment variables.
# Give temporary write access so we can apply the changes.
sudo chown $USER:$USER /etc/environment
# Configure pfetch.
echo PF_INFO='"ascii os kernel uptime pkgs shell de memory"' >> /etc/environment
# Set BROWSER variable.
echo BROWSER=/usr/bin/brave >> /etc/environment
# Set EDITOR variable.
echo EDITOR=/usr/bin/micro >> /etc/environment
# Set MICRO_TRUECOLOR variable.
echo MICRO_TRUECOLOR=1 >> /etc/environment
# Change owner back to root.
sudo chown root:root /etc/environment

# Stop mkinitcpio from generating a fallback kernel image.
sudo sed -i 's/'"PRESETS=('default' 'fallback')"'/'"PRESETS=('default')"''/g /etc/mkinitcpio.d/linux.preset
sudo sed -i 's|fallback_image="/boot/initramfs-linux-fallback.img"|#fallback_image="/boot/initramfs-linux-fallback.img"|g' /etc/mkinitcpio.d/linux.preset
sudo sed -i 's/fallback_options="-S autodetect"/#fallback_options="-S autodetect"'/g /etc/mkinitcpio.d/linux.preset
sudo mkinitcpio -p linux
sudo rm /boot/initramfs-linux-fallback.img
sudo grub-mkconfig -o /boot/grub/grub.cfg
