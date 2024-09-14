#!/bin/bash
# This script cleans up and configures an Arch Linux KDE install that was installed with "archinstall." Run as a normal user!

# Audio buzz/hum fix.
sudo touch /etc/modprobe.d/alsa-base.conf && sudo chmod o+w /etc/modprobe.d/alsa-base.conf
echo "options snd-hda-intel power_save=0 power_save_controller=N" > /etc/modprobe.d/alsa-base.conf
sudo chmod o-w /etc/modprobe.d/alsa-base.conf

# Tweak pacman for sane defaults.
sudo sed -i 's/#UseSyslog/UseSyslog'/g /etc/pacman.conf
sudo sed -i 's/#Color/Color'/g /etc/pacman.conf
sudo sed -i 's/'"#ParallelDownloads = 5"'/'"ParallelDownloads = 20"''/g /etc/pacman.conf
sudo sed -i '/ParallelDownloads = 20/ a\ILoveCandy\' /etc/pacman.conf

# Rank mirrors.
sudo pacman -S reflector --noconfirm
sudo reflector --latest 150 --protocol https --sort rate --sort age --score 10 --save /etc/pacman.d/mirrorlist
# Congfigure reflector config file for systemd auto-update.
sudo chmod o+w /etc/xdg/reflector/reflector.conf
sudo sed -i 's/--latest 5/--latest 150'/g /etc/xdg/reflector/reflector.conf
echo "" >> /etc/xdg/reflector/reflector.conf
echo "# Sort the mirrors by highest score (--score)." >> /etc/xdg/reflector/reflector.conf
echo "--score 10" >> /etc/xdg/reflector/reflector.conf
echo "" >> /etc/xdg/reflector/reflector.conf
echo "# Sort the mirrors by highest rate (--sort)." >> /etc/xdg/reflector/reflector.conf
echo "--sort rate" >> /etc/xdg/reflector/reflector.conf
sudo chmod o-w /etc/xdg/reflector/reflector.conf
sudo systemctl enable reflector.service --now && sudo systemctl enable reflector.timer --now
sudo pacman -Syy

# Install and use a better NTP daemon, Chrony.
sudo pacman -S chrony --noconfirm
sudo sed -i 's/! server 0.arch.pool.ntp.org iburst/server 0.arch.pool.ntp.org iburst'/g /etc/chrony.conf
sudo sed -i 's/! server 1.arch.pool.ntp.org iburst/server 1.arch.pool.ntp.org iburst'/g /etc/chrony.conf
sudo sed -i 's/! server 3.arch.pool.ntp.org iburst/server 3.arch.pool.ntp.org iburst'/g /etc/chrony.conf
sudo systemctl disable systemd-timesyncd.service
sudo systemctl enable --now chronyd && sudo systemctl enable --now chrony-wait
sudo chronyc online

# Remove unneeded packages.
sudo pacman -Rns nano htop kate --noconfirm

# Install ffmpegthumbs, for video file thumbnail support in Dolphin.
sudo pacman -S ffmpegthumbs --noconfirm

# Install thumbnail support for PDF files.
sudo pacman -S kdegraphics-thumbnailers --noconfirm

# Install some KDE utilities.
sudo pacman -S kcalc kcharselect kfind kwalletmanager kdialog sweeper khelpcenter gwenview kaccounts-providers kio-gdrive kio-admin audiocd-kio ksystemlog kcron --noconfirm

# Install PackageKit so that Discover will work properly.
sudo pacman -S packagekit-qt6 --noconfirm

# Install some core utilities that didn't get installed, for some reason.
sudo pacman -S man-pages man-db logrotate cracklib usbutils hddtemp cronie --noconfirm

# Install some command-line utilities.
sudo pacman -S micro xclip vim duf bat fd lynis btop --noconfirm

# Install spell checking support.
sudo pacman -S aspell aspell-en --noconfirm

# Install and configure plocate.
sudo pacman -S plocate --noconfirm
sudo systemctl enable --now plocate-updatedb.timer

# Install paru AUR helper.
sudo pacman -S --needed base-devel && git clone https://aur.archlinux.org/paru-bin.git $HOME/paru-bin && cd paru-bin && makepkg -sic --noconfirm
cd .. && rm -rf paru-bin
# Configure paru options.
sudo sed -i 's/#BottomUp/BottomUp'/g /etc/paru.conf
sudo sed -i 's/#RemoveMake/RemoveMake'/g /etc/paru.conf
sudo sed -i 's/#SudoLoop/SudoLoop'/g /etc/paru.conf
sudo sed -i 's/#UseAsk/UseAsk'/g /etc/paru.conf
sudo sed -i 's/#CombinedUpgrade/CombinedUpgrade'/g /etc/paru.conf
sudo sed -i 's/#CleanAfter/CleanAfter'/g /etc/paru.conf
sudo sed -i 's/#NewsOnUpgrade/NewsOnUpgrade'/g /etc/paru.conf
sudo sed -i '/NewsOnUpgrade/ a\SkipReview\' /etc/paru.conf
sudo sed -i '/SkipReview/ a\BatchInstall\' /etc/paru.conf

# Install Konsole color scheme.
read -p "Which Konsole colorscheme do you want?
1. Catppuccin
2. OneHalf-Dark
-> " $resp
if [ "$resp" = 1 ]; then
	paru -S catppuccin-konsole-theme-git --noconfirm
fi
if [ "$resp" = 2 ]; then
	wget https://raw.githubusercontent.com/sonph/onehalf/master/konsole/onehalf-dark.colorscheme
	sudo mv onehalf-dark.colorscheme /usr/share/konsole
	sudo chmod 644 /usr/share/konsole/onehalf-dark.colorscheme
fi

# Install icon and KDE theme.
paru -S papirus-icon-theme papirus-folders vimix-gtk-themes kvantum kvantum-qt5 qt5ct --noconfirm

# Install KDE theme.
git clone https://github.com/vinceliuice/Vimix-kde.git $HOME/Vimix-kde
cd $HOME/Vimix-kde
sudo cp -rv aurorae/* /usr/share/aurorae/themes
sudo cp -rv color-schemes /usr/share
sudo cp -rv Kvantum /usr/share
sudo cp -rv plasma /usr/share
sudo cp -rv wallpaper/Vimix* /usr/share/plasma/wallpapers
cd sddm && sudo ./install.sh
# Fix Vimix SDDM folder permissions.
sudo chmod 755 /usr/share/sddm/themes/vimix
sudo chmod 755 /usr/share/sddm/themes/vimix/assets
sudo chmod 644 /usr/share/sddm/themes/vimix/assets/*
sudo chmod 755 /usr/share/sddm/themes/vimix/components
sudo chmod 644 /usr/share/sddm/themes/vimix/components/*
sudo chmod 755 /usr/share/sddm/themes/vimix/faces
sudo chmod 644 /usr/share/sddm/themes/vimix/faces/.face.icon
sudo chmod 644 /usr/share/sddm/themes/vimix/*.qml
sudo chmod 644 /usr/share/sddm/themes/vimix/*.desktop
sudo chmod 644 /usr/share/sddm/themes/vimix/*.png
sudo chmod 644 /usr/share/sddm/themes/vimix/*.conf
sudo chmod 644 /usr/share/sddm/themes/vimix/*.conf.user
sudo chmod 744 /usr/share/sddm/themes/vimix/background.jpg
# Fix Vimix Plasma theme folder permissions.
sudo chmod -R 644 /usr/share/plasma/desktoptheme/Vimix*
sudo chmod 755 /usr/share/plasma/desktoptheme/Vimix*
sudo chmod 755 /usr/share/plasma/desktoptheme/Vimix/dialogs
sudo chmod 755 /usr/share/plasma/desktoptheme/Vimix/icons
sudo chmod 755 /usr/share/plasma/desktoptheme/Vimix/solid
sudo chmod 755 /usr/share/plasma/desktoptheme/Vimix/translucent
sudo chmod 755 /usr/share/plasma/desktoptheme/Vimix/widgets
sudo chmod 755 /usr/share/plasma/desktoptheme/Vimix/solid/dialogs
sudo chmod 755 /usr/share/plasma/desktoptheme/Vimix/solid/widgets
sudo chmod 755 /usr/share/plasma/desktoptheme/Vimix/translucent/dialogs
sudo chmod 755 /usr/share/plasma/desktoptheme/Vimix/translucent/widgets
sudo chmod 755 /usr/share/plasma/look-and-feel/com.github.vinceliuice.Vimix*
sudo chmod 755 /usr/share/plasma/look-and-feel/com.github.vinceliuice.Vimix*/contents
sudo chmod 755 /usr/share/plasma/look-and-feel/com.github.vinceliuice.Vimix*/contents/previews
sudo chmod 755 /usr/share/plasma/look-and-feel/com.github.vinceliuice.Vimix*/contents/splash
sudo chmod 644 /usr/share/plasma/look-and-feel/com.github.vinceliuice.Vimix*/metadata.desktop
sudo chmod 644 /usr/share/plasma/look-and-feel/com.github.vinceliuice.Vimix*/contents/defaults
sudo chmod 644 /usr/share/plasma/look-and-feel/com.github.vinceliuice.Vimix*/contents/previews/*.jpg
sudo chmod 644 /usr/share/plasma/look-and-feel/com.github.vinceliuice.Vimix*/contents/previews/*.png
sudo chmod 755 /usr/share/plasma/look-and-feel/com.github.vinceliuice.Vimix*/contents/splash/images
sudo chmod 644 /usr/share/plasma/look-and-feel/com.github.vinceliuice.Vimix*/contents/splash/Splash.qml
sudo chmod 644 /usr/share/plasma/look-and-feel/com.github.vinceliuice.Vimix*/contents/splash/images/*.svg
sudo chmod 755 /usr/share/plasma/wallpapers/Vimix*
sudo chmod 755 /usr/share/plasma/wallpapers/Vimix*/contents
sudo chmod 755 /usr/share/plasma/wallpapers/Vimix*/contents/images
sudo chmod 644 /usr/share/plasma/wallpapers/Vimix*/contents/images/3840x3840.png
sudo chmod 644 /usr/share/plasma/wallpapers/Vimix*/metadata.desktop
sudo chmod 644 /usr/share/color-schemes/Vimix*.colors
sudo chmod 755 /usr/share/aurorae/themes/Vimix*
sudo chmod 644 /usr/share/aurorae/themes/Vimix*/*
sudo chmod 755 /usr/share/Kvantum/Vimix*
sudo chmod 644 /usr/share/Kvantum/Vimix*/*
# Cleanup
cd $HOME
rm -rf $HOME/Vimix-kde

# Install and configure printing support.
paru -S cups hplip-lite print-manager system-config-printer cups-pk-helper gutenprint foomatic-db-gutenprint-ppds tesseract-data-eng skanpage --noconfirm
sudo systemctl enable --now cups cups-browsed

# Install PolKit rules for desktop privileges. Enables automounting, suspend and hibernation, and CPU frequency settings.
paru -S desktop-privileges-nogroups --noconfirm

# Install hardware detection tool for mkinitcpio.
sudo pacman -S hwdetect --noconfirm

# Install power-profiles-daemon package. Makes power management profiles available to KDE.
sudo pacman -S power-profiles-daemon --noconfirm

# Install NTFS filesystem driver.
sudo pacman -S ntfs-3g --noconfirm

# Install Brave web browser.
paru -S brave-bin --noconfirm

# Install fonts.
paru -S ttf-poppins adobe-source-sans-fonts ttf-jetbrains-mono-nerd ttf-ms-fonts ttf-material-design-icons-desktop-git ttf-material-design-icons-git noto-fonts-emoji noto-fonts-lite ttf-nerd-fonts-symbols ttfautohint --noconfirm
sudo ln -s /usr/share/fontconfig/conf.avail/09-autohint-if-no-hinting.conf /etc/fonts/conf.d/

# Configure nerd fonts for "lsd".
sudo ln -s /usr/share/fontconfig/conf.avail/10-nerd-font-symbols.conf /etc/fonts/conf.d/

# Install "lsd," a better replacement for ls.
paru -S lsd --noconfirm

# Install topgrade.
paru -S topgrade-bin --noconfirm

# Install pfetch.
paru -S pfetch --noconfirm

# Install and configure VSCodium.
paru -S vscodium-bin vscodium-bin-marketplace --noconfirm
mkdir -p $HOME/.config/VSCodium/User && cp -v $HOME/linux-stuff/Dotfiles/config/VSCodium/User/settings.json $HOME/.config/VSCodium/User/settings.json
vscodium --install-extension zhuangtongfa.material-theme
vscodium --install-extension jeff-hykin.better-shellscript-syntax
vscodium --install-extension file-icons.file-icons
vscodium --install-extension miguelsolorio.fluent-icons

# Install grub theme.
paru -S grub-theme-stylish-color-1080p-git --noconfirm
sudo sed -i 's|#GRUB_THEME="/path/to/gfxtheme"|GRUB_THEME="/usr/share/grub/themes/stylish-color-1080p/theme.txt"|g' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Install Wine.
paru -S wine-installer wine-gecko wine-mono --noconfirm

# Install some useful software.
sudo pacman -S unrar vlc transmission-qt pinta audacity k3b okular spectacle p7zip clipgrab partitionmanager dolphin-plugins --noconfirm

# Install balenaEtcher to write OS images to USB flash drives.
paru -S etcher-bin --noconfirm

# Install VirtualBox.
sudo pacman -S virtualbox virtualbox-guest-iso --noconfirm
paru -S virtualbox-unattended-templates --noconfirm

# Install mp3tag.
paru -S mp3tag --noconfirm

# Install dependencies for k3b.
paru -S cdrtools dvd+rw-tools transcode sox normalize cdrdao --noconfirm

# Install some KDE games.
sudo pacman -S kapman kblocks kbounce kbreakout kmines knetwalk kpat kreversi --noconfirm

# Install Spotify.
paru -S spotify --noconfirm

# Install KDE Connect.
sudo pacman -S kdeconnect --noconfirm

# Install gufw firewall and enable the systemd service.
sudo pacman -S gufw --noconfirm
sudo systemctl enable --now ufw

# Install some useful pacman post-transaction hooks.
paru -S pacman-cleanup-hook grub-hook sync-pacman-hook-git remove-orphaned-kernels pacman-log-orphans-hook pamac-appstream-hook --noconfirm

# Setup config files and stuff.
cd linux-stuff/
./bat-setup.sh
./lsd-setup.sh
sudo ./cleanup-systemd-boot.sh

# Configure Zsh.
echo "Configuring Zsh..."
paru -S oh-my-zsh-git --noconfirm
cp -v /usr/share/oh-my-zsh/zshrc $HOME/.zshrc
sed -i s/ZSH_THEME='"robbyrussell"'/ZSH_THEME='"gentoo"'/g $HOME/.zshrc
sed -i 's/# HYPHEN_INSENSITIVE="true"/HYPHEN_INSENSITIVE="true"/g' $HOME/.zshrc
sed -i 's/'"# zstyle ':omz:update' mode disabled"'/'"zstyle ':omz:update' mode disabled"''/g $HOME/.zshrc
sed -i 's/# ENABLE_CORRECTION="true"/ENABLE_CORRECTION="true"/g' $HOME/.zshrc
sed -i 's/# COMPLETION_WAITING_DOTS="true"/COMPLETION_WAITING_DOTS="true"/g' $HOME/.zshrc
sed -i 's/# DISABLE_UNTRACKED_FILES_DIRTY="true"/DISABLE_UNTRACKED_FILES_DIRTY="true"/g' $HOME/.zshrc
sed -i 's|# HIST_STAMPS="mm/dd/yyyy"|HIST_STAMPS="mm/dd/yyyy"|g' $HOME/.zshrc
sed -i 's/'"plugins=(git)/plugins=(git colored-man-pages safe-paste sudo copypath zsh-autosuggestions zsh-syntax-highlighting)"'/g' $HOME/.zshrc
ZSH_CUSTOM=/usr/share/oh-my-zsh/custom
sudo git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting
sudo git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions
unset ZSH_CUSTOM
sudo chmod 755 /usr/share/oh-my-zsh/custom/plugins/zsh-autosuggestions
sudo chmod 755 /usr/share/oh-my-zsh/custom/plugins/zsh-autosuggestions/*.zsh
sudo chmod 755 /usr/share/oh-my-zsh/custom/plugins/zsh-syntax-highlighting
sudo chmod -R 755 /usr/share/oh-my-zsh/custom/plugins/zsh-syntax-highlighting/docs
sudo chmod -R 755 /usr/share/oh-my-zsh/custom/plugins/zsh-syntax-highlighting/highlighters
sudo chmod -R 755 /usr/share/oh-my-zsh/custom/plugins/zsh-syntax-highlighting/images
sudo chmod -R 755 /usr/share/oh-my-zsh/custom/plugins/zsh-syntax-highlighting/tests
sudo chmod 755 /usr/share/oh-my-zsh/custom/plugins/zsh-syntax-highlighting/*.zsh
sudo chmod 755 /usr/share/oh-my-zsh/custom/plugins/zsh-syntax-highlighting/.*
echo "" >> $HOME/.zshrc
echo "# Set the default umask." >> $HOME/.zshrc
echo "umask 077" >> $HOME/.zshrc
echo "" >> $HOME/.zshrc
echo "# Disable highlighting of pasted text." >> $HOME/.zshrc
echo "zle_highlight=('paste:none')" >> $HOME/.zshrc
echo "" >> $HOME/.zshrc
echo "# Apply sensible history settings." >> $HOME/.zshrc
echo "setopt HIST_EXPIRE_DUPS_FIRST" >> $HOME/.zshrc
echo "setopt HIST_FIND_NO_DUPS" >> $HOME/.zshrc
echo "setopt HIST_IGNORE_ALL_DUPS" >> $HOME/.zshrc
echo "setopt HIST_IGNORE_DUPS" >> $HOME/.zshrc
echo "setopt HIST_IGNORE_SPACE" >> $HOME/.zshrc
echo "setopt HIST_SAVE_NO_DUPS" >> $HOME/.zshrc
echo alias ls='"lsd"' >> $HOME/.zshrc
echo alias cat='"bat"' >> $HOME/.zshrc

# Copy over custom Oh My Zsh theme.
sudo cp -v jpassarelli.zsh-theme /usr/share/oh-my-zsh/custom/themes

# Setup Catppuccin colors.
cd $HOME && git clone https://github.com/catppuccin/zsh-syntax-highlighting.git
sudo cp -v zsh-syntax-highlighting/themes/*.zsh /etc/zsh
read -p "Which Catppuccin colors do you want for Zsh syntax highlighting?
1.) Latte
2.) Frappé
3.) Macchiato
4.) Mocha

0.) None.
-> " resp
if [ "$resp" = 1 ]; then
	echo "source /etc/zsh/catppuccin_latte-zsh-syntax-highlighting.zsh" >> $HOME/.zshrc
fi
if [ "$resp" = 2 ]; then
	echo "source /etc/zsh/catppuccin_frappe-zsh-syntax-highlighting.zsh" >> $HOME/.zshrc
fi
if [ "$resp" = 3 ]; then
	echo "source /etc/zsh/catppuccin_macchiato-zsh-syntax-highlighting.zsh" >> $HOME/.zshrc
fi
if [ "$resp" = 4 ]; then
	echo "source /etc/zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh" >> $HOME/.zshrc
if [ "$rest" = 0 ]; then
	sudo rm -rf /etc/zsh/*.zsh
	continue
fi
rm -rf zsh-syntax-highlighting
sudo cp -v $HOME/.zshrc /etc/skel/.zshrc
sudo cp -v /etc/skel/.zshrc /root/.zshrc
echo pfetch >> $HOME/.zshrc

# Change user's shell to zsh.
chsh -s /usr/bin/zsh $USER

# Update environment variables.
# Give temporary write access so we can apply the changes.
sudo chmod o+w /etc/environment
# Configure pfetch.
echo PF_INFO='"ascii os kernel uptime pkgs shell editor de"' >> /etc/environment
# Set BROWSER variable.
echo BROWSER=brave >> /etc/environment
# Set EDITOR variable.
echo EDITOR=vim >> /etc/environment
# Enable VSCodium to use QT file dialogs by default instead of GTK.
echo GTK_USE_PORTAL=1 >> /etc/environment
# Enable QT5 apps to use Kvantum theming engine.
echo QT_QPA_PLATFORMTHEME=qt5ct >> /etc/environment
# Remove permission for other users to write to this file.
sudo chmod o-w /etc/environment

# Install mkinitcpio firmware, gets rid of missing firmware messages.
paru -S mkinitcpio-firmware --noconfirm

# Stop mkinitcpio from generating a fallback kernel image.
echo "Stopping mkinitcpio from generating a fallback kernel image..."
if [ $(uname -r | grep arch | awk -F "-" '{print $(NF)}') ]; then
	sudo sed -i 's/'"PRESETS=('default' 'fallback')"'/'"PRESETS=('default')"''/g /etc/mkinitcpio.d/linux.preset
	sudo sed -i 's|fallback_image="/boot/initramfs-linux-fallback.img"|#fallback_image="/boot/initramfs-linux-fallback.img"|g' /etc/mkinitcpio.d/linux.preset
	sudo sed -i 's/fallback_options="-S autodetect"/#fallback_options="-S autodetect"'/g /etc/mkinitcpio.d/linux.preset
	sudo mkinitcpio -p linux
	sudo rm /boot/initramfs-linux-fallback.img
	sudo grub-mkconfig -o /boot/grub/grub.cfg
fi
if [ $(uname -r | grep hardened | awk -F "-" '{print $(NF)}') ]; then
	sudo sed -i 's/'"PRESETS=('default' 'fallback')"'/'"PRESETS=('default')"''/g /etc/mkinitcpio.d/linux-hardened.preset
	sudo sed -i 's|fallback_image="/boot/initramfs-linux-hardened-fallback.img"|#fallback_image="/boot/initramfs-linux-hardened-fallback.img"|g' /etc/mkinitcpio.d/linux-hardened.preset
	sudo sed -i 's/fallback_options="-S autodetect"/#fallback_options="-S autodetect"'/g /etc/mkinitcpio.d/linux-hardened.preset
	sudo mkinitcpio -p linux-hardened
	sudo rm /boot/initramfs-linux-hardened-fallback.img
	sudo grub-mkconfig -o /boot/grub/grub.cfg
fi
if [ $(uname -r | grep lts | awk -F "-" '{print $(NF)}') ]; then
	sudo sed -i 's/'"PRESETS=('default' 'fallback')"'/'"PRESETS=('default')"''/g /etc/mkinitcpio.d/linux-lts.preset
	sudo sed -i 's|fallback_image="/boot/initramfs-linux-lts-fallback.img"|#fallback_image="/boot/initramfs-linux-lts-fallback.img"|g' /etc/mkinitcpio.d/linux-lts.preset
	sudo sed -i 's/fallback_options="-S autodetect"/#fallback_options="-S autodetect"'/g /etc/mkinitcpio.d/linux-lts.preset
	sudo mkinitcpio -p linux-lts
	sudo rm /boot/initramfs-linux-lts-fallback.img
	sudo grub-mkconfig -o /boot/grub/grub.cfg
fi
if [ $(uname -r | grep zen | awk -F "-" '{print $(NF)}') ]; then
	sudo sed -i 's/'"PRESETS=('default' 'fallback')"'/'"PRESETS=('default')"''/g /etc/mkinitcpio.d/linux-zen.preset
	sudo sed -i 's|fallback_image="/boot/initramfs-linux-zen-fallback.img"|#fallback_image="/boot/initramfs-linux-zen-fallback.img"|g' /etc/mkinitcpio.d/linux-zen.preset
	sudo sed -i 's/fallback_options="-S autodetect"/#fallback_options="-S autodetect"'/g /etc/mkinitcpio.d/linux-zen.preset
	sudo mkinitcpio -p linux-zen
	sudo rm /boot/initramfs-linux-zen-fallback.img
	sudo grub-mkconfig -o /boot/grub/grub.cfg
fi
if [ $(uname -r | grep realtime | awk -F "-" '{print $(NF)}') ]; then
	sudo sed -i 's/'"PRESETS=('default' 'fallback')"'/'"PRESETS=('default')"''/g /etc/mkinitcpio.d/linux-rt.preset
	sudo sed -i 's|fallback_image="/boot/initramfs-linux-rt-fallback.img"|#fallback_image="/boot/initramfs-linux-rt-fallback.img"|g' /etc/mkinitcpio.d/linux-rt.preset
	sudo sed -i 's/fallback_options="-S autodetect"/#fallback_options="-S autodetect"'/g /etc/mkinitcpio.d/linux-rt.preset
	sudo mkinitcpio -p linux-rt
	sudo rm /boot/initramfs-linux-rt-fallback.img
	sudo grub-mkconfig -o /boot/grub/grub.cfg
fi
if [ $(uname -r | grep rt-lts | awk -F "-" '{print $(NF)}') ]; then
	sudo sed -i 's/'"PRESETS=('default' 'fallback')"'/'"PRESETS=('default')"''/g /etc/mkinitcpio.d/linux-rt-lts.preset
	sudo sed -i 's|fallback_image="/boot/initramfs-linux-rt-lts-fallback.img"|#fallback_image="/boot/initramfs-linux-rt-lts-fallback.img"|g' /etc/mkinitcpio.d/linux-rt-lts.preset
	sudo sed -i 's/fallback_options="-S autodetect"/#fallback_options="-S autodetect"'/g /etc/mkinitcpio.d/linux-rt-lts.preset
	sudo mkinitcpio -p linux-rt-lts
	sudo rm /boot/initramfs-linux-rt-lts-fallback.img
	sudo grub-mkconfig -o /boot/grub/grub.cfg
fi

# Configure lynis.
echo "Configuring lynis..."
sudo chmod o+w /etc/lynis/custom.prf
echo "machine-role=personal" > /etc/lynis/custom.prf
echo "test-scan-mode=normal" >> /etc/lynis/custom.prf
echo "" >> /etc/lynis/custom.prf
cat << EOF >> /etc/lynis/custom.prf
# Plugins to disable
disable-plugin=docker
disable-plugin=forensics
disable-plugin=intrusion-detection
disable-plugin=intrusion-prevention
disable-plugin=nginx
EOF
sudo chmod o-w /etc/lynis/custom.prf

# Secure the OS.
sudo pacman -S arch-audit apparmor sysstat puppet rkhunter libpwquality rng-tools --noconfirm
paru -S acct chkrootkit --noconfirm
sudo chmod 600 /boot/grub/grub.cfg
sudo chmod 600 /etc/ssh/sshd_config
sudo sed -i 's/umask 022/umask 077'/g /etc/login.defs
sudo sed -i 's/UMASK=0022/UMASK=0077'/g /etc/conf.d/sysstat
sudo chmod o+w /etc/profile
cat << EOF >> /etc/profile
# Set default umask.
umask 077
EOF
sudo chmod o-w /etc/profile
sudo touch /etc/sysctl.d/99-sysctl.conf
sudo chmod o+w /etc/sysctl.d/99-sysctl.conf
cat << EOF >> /etc/sysctl.d/99-sysctl.conf
sudo chmod o-w /etc/sysctl.d/99-sysctl.conf
dev.tty.ldisc_autoload = 0
fs.protected_fifos = 2
fs.protected_regular = 2
fs.suid_dumpable = 0
kernel.sysrq = 0
kernel.unprivileged_bpf_disabled = 1
kernel.kptr_restrict = 2
kernel.perf_event_paranoid = 3
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.log_martians = 1
net.core.bpf_jit_harden = 2
EOF
sudo chmod o-w /etc/sysctl.d/99-sysctl.conf
sudo touch /var/log/account/pacct
sudo accton on
sudo systemctl enable --now acct
sudo systemctl enable --now puppet
sudo systemctl enable --now auditd
sudo systemctl enable --now rngd
sudo chmod o+w /etc/conf.d/sysstat
echo "" >> /etc/conf.d/sysstat && echo 'ENABLED="true"' >> /etc/conf.d/sysstat
sudo chmod o-w /etc/conf.d/sysstat
sudo systemctl enable --now sysstat
sudo chmod o+w /etc/bash.bashrc
cat << EOF >> /etc/bash.bashrc
# Set default umask.
umask 077
EOF
sudo chmod o-w /etc/bash.bashrc
sudo chmod o+w /etc/hosts
cat << EOF >> /etc/hosts
127.0.0.1 localhost
::1 localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
127.0.1.1 `hostname`
EOF
sudo chmod o-w /etc/hosts
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no'/g /etc/ssh/sshd_config
sudo sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding no'/g /etc/ssh/sshd_config
sudo sed -i 's/#ClientAliveCountMax 3/ClientAliveCountMax 2'/g /etc/ssh/sshd_config
sudo sed -i 's/#Compression delayed/Compression no'/g /etc/ssh/sshd_config
sudo sed -i 's/#LogLevel INFO/LogLevel VERBOSE'/g /etc/ssh/sshd_config
sudo sed -i 's/#MaxAuthTries 6/MaxAuthTries 3'/g /etc/ssh/sshd_config
sudo sed -i 's/#MaxSessions 10/MaxSessions 2'/g /etc/ssh/sshd_config
sudo sed -i 's/#TCPKeepAlive yes/TCPKeepAlive no'/g /etc/ssh/sshd_config
sudo sed -i 's/#AllowAgentForwarding yes/AllowAgentForwarding no'/g /etc/ssh/sshd_config

# Increase password hashing rounds.
sudo sed -i 's/#SHA_CRYPT_MIN_ROUNDS 5000/SHA_CRYPT_MIN_ROUNDS 100000'/g /etc/login.defs
sudo sed -i 's/#SHA_CRYPT_MAX_ROUNDS 5000/SHA_CRYPT_MAX_ROUNDS 100000'g /etc/login.defs

# Change password encryption method from "YESCRYPT" to "SHA256."
sudo sed -i 's/ENCRYPT_METHOD YESCRYPT/ENCRYPT_METHOD SHA256'/g /etc/login.defs
sudo chmod o+w /etc/pam.d/passwd
cat << EOF >> /etc/pam.d/passwd
#
# These lines require the user to select a password with a minimum
# length of 8 and with at least 1 digit number, and 1 upper case
# letter.
#
password required pam_pwquality.so \
              dcredit=-1 ucredit=-1 lcredit=0 minlen=8
password required pam_unix.so use_authtok nullok sha256
EOF
sudo chmod o-w /etc/pam.d/passwd

# Setup AppArmor.
sudo sed -i 's/#write-cache/write-cache'/g /etc/apparmor/parser.conf
sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"/GRUB_CMDLINE_LINUX_DEFAULT="nowatchdog nmi_watchdog=0 loglevel=3 lsm=landlock,lockdown,yama,integrity,apparmor,bpf"/g' /etc/default/grub && sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo systemctl enable --now apparmor

# Prettify Arch logo.
sudo sed -i 's/LOGO=archlinux-logo/LOGO=distributor-logo-archlinux'/g /etc/os-release

# Hide menu entries and remove files.
####################
# Define the source directory
source_dir=/usr/share/applications/

# List of files to modify
files=(
  "bssh.desktop"
  "bvnc.desktop"
  "avahi-discover.desktop"
  "org.kde.kuserfeedback-console.desktop"
  "qv4l2.desktop"
  "qvidcap.desktop"
  "gcdmaster.desktop"
  "designer.desktop"
  "linguist.desktop"
  "assistant.desktop"
  "qdbusviewer.desktop"
  "codium-wayland.desktop"
  "vscodium-bin-wayland.desktop"
  "org.kde.krdp.desktop"
)

# Remove the files
for file in "${files[@]}"
do
  sudo rm -rf "$source_dir$file"
  echo "Removed $file..."
done

# Insert NoExtract directive with sed
for file in "${files[@]}"
do
  filename=$(basename "$file")
  sudo sed -i '/#NoExtract/a NoExtract = '"usr/share/applications/$filename" /etc/pacman.conf
done

# Delete the existing '#NoExtract' line
sudo sed -i '/^#NoExtract = $/d' /etc/pacman.conf

echo "All files removed and NoExtract directive updated."
####################

# Disable submenus in GRUB.
sudo sed -i 's/#GRUB_DISABLE_SUBMENU=y/GRUB_DISABLE_SUBMENU=y'/g /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Speed up systemd journal flush.
sudo sed -i 's/#Storage=auto/Storage=volatile'/g /etc/systemd/journald.conf
sudo sed -i 's/#SystemMaxFileSize=/SystemMaxFileSize=20MB'/g /etc/systemd/journald.conf

# Install pacman wrapper for easier command syntax (and set up).
paru -S pac-wrapper --noconfirm
sudo chmod o+w /etc/environment && echo PAC_PACMAN=paru >> /etc/environment && sudo chmod o-w /etc/environment
source /etc/environment

# Enable paccache SystemD timer (cleans up pacman package cache).
sudo systemctl enable --now paccache.timer

# Install autoupdate to automatically update the OS during boot.
paru -S autoupdate --noconfirm
sudo systemctl enable --now autoupdate.service

# Configure autoupdate.
sed -i 's/-Syuwq/-Syuq'/g /usr/lib/systemd/system/autoupdate.service

# Install and enable orphan-manager, a Systemd timer to automatically remove orphaned packages.
paru -S orphan-manager --noconfirm
sudo systemctl enable --now orphan-manager.timer

# Add scripts to system to automatically purge .pacnew and .pacsave files.
sudo ./purge_pacnew.sh
sudo ./purge_pacsave.sh

# Configure console text editor.
read -p "Which console text editor do you want?
1.) Micro
2.) Vim
3.) Vim with Catppuccino colorscheme.
-> " $resp
if [ "$resp" = 1 ]; then
	./micro-setup.sh
	sudo sed -i 's/vim/micro'/g /etc/environment
	sudo chmod o+w /etc/environment
	# Enables truecolor support.
	sudo echo MICRO_TRUECOLOR=1 >> /etc/environment
	sudo chmod o-w /etc/environment
	sudo pacman -Rns vim
fi
if [ "$resp" = 2 ]; then
	./vim_setup_archlinux.sh
	sudo pacman -Rns micro xclip --noconfirm
fi
if [ "$resp" = 3 ]; then
	./vim_setup_catppuccino_archlinux.sh
	sudo pacman -Rns micro xclip --noconfirm
fi
