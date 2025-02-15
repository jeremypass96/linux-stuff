#!/bin/bash
# This script cleans up and configures an Arch Linux KDE install that was installed with "archinstall." Run as a normal user!

# Define color codes
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}Welcome to the Arch Linux post-install script!${NC}"
sleep 10 ; clear

# Audio buzz/hum fix.
echo -e "${BLUE}Fixing audio buzz/him issue...${NC}"
echo "options snd-hda-intel power_save=0 power_save_controller=N" | sudo tee /etc/modprobe.d/alsa-base.conf > /dev/null
echo -e "${GREEN}Audio buzz/him issue fixed!${NC}"
sleep 10 ; clear

# Tweak pacman for sane defaults.
echo -e "${BLUE}Tweaking pacman for sane defaults...${NC}"
sudo sed -i 's/#UseSyslog/UseSyslog'/g /etc/pacman.conf
sudo sed -i 's/#Color/Color'/g /etc/pacman.conf
sudo sed -i 's/'"#ParallelDownloads = 5"'/'"ParallelDownloads = 20"''/g /etc/pacman.conf
sudo sed -i '/ParallelDownloads = 20/ a\ILoveCandy\' /etc/pacman.conf
sleep 10 ; clear

# Rank mirrors.
echo -e "${BLUE}Ranking Arch Linux mirrors...${NC}"
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
sleep 10 ; clear

# Install and use a better NTP daemon, Chrony.
echo -e "${BLUE}Installing and using a better NTP daemon, Chrony...${NC}"
sudo pacman -S chrony --noconfirm
sudo sed -i 's/! server 0.arch.pool.ntp.org iburst/server 0.arch.pool.ntp.org iburst'/g /etc/chrony.conf
sudo sed -i 's/! server 1.arch.pool.ntp.org iburst/server 1.arch.pool.ntp.org iburst'/g /etc/chrony.conf
sudo sed -i 's/! server 3.arch.pool.ntp.org iburst/server 3.arch.pool.ntp.org iburst'/g /etc/chrony.conf
sudo systemctl disable systemd-timesyncd.service
sudo systemctl enable --now chronyd && sudo systemctl enable --now chrony-wait
sudo chronyc online
sleep 10 ; clear

# Remove unneeded packages.
echo -e "${BLUE}Removing unneeded packages...${NC}"
sudo pacman -Rns nano htop kate --noconfirm
sleep 10 ; clear

# Install file thumbnail support.
echo -e "${BLUE}Installing file thumbnail support...${NC}"
sudo pacman -S kdegraphics-thumbnailers ffmpegthumbs --noconfirm
sleep 10 ; clear

# Install some KDE utilities.
echo -e "${BLUE}Installing some KDE utilities...${NC}"
sudo pacman -S kcalc kcharselect kfind kwalletmanager kdialog sweeper khelpcenter gwenview kaccounts-providers kio-gdrive kio-admin audiocd-kio ksystemlog kcron --noconfirm
sleep 10 ; clear

# Install some core utilities that didn't get installed, for some odd reason.
echo -e "${BLUE}Installing some core system utilities that forgot to be installed...${NC}"
sudo pacman -S man-pages man-db logrotate cracklib usbutils hddtemp cronie --noconfirm
sleep 10 ; clear

# Install a few command-line utilities.
echo -e "${BLUE}Installing a few command-line utilities...${NC}"
sudo pacman -S duf bat fd lynis btop wcurl --noconfirm
sleep 10 ; clear

# Install spell checking support.
echo -e "${BLUE}Installing spell checking support...${NC}"
sudo pacman -S aspell aspell-en --noconfirm
sleep 10 ; clear

# Install and configure plocate.
echo -e "${BLUE}Installing and configuring 'plocate'...${NC}"
sudo pacman -S plocate --noconfirm
sudo systemctl enable --now plocate-updatedb.timer
sleep 10 ; clear

# Install paru AUR helper.
echo -e "${BLUE}Installing the 'paru' AUR helper...${NC}"
sudo pacman -S --needed base-devel && git clone https://aur.archlinux.org/paru-bin.git "$HOME"/paru-bin && cd "$HOME"/paru-bin && makepkg -sic --noconfirm
cd .. && rm -rf paru-bin
# Configure paru options.
echo -e "${BLUE}Configuring paru options...${NC}"
sudo sed -i 's/#BottomUp/BottomUp'/g /etc/paru.conf
sudo sed -i 's/#RemoveMake/RemoveMake'/g /etc/paru.conf
sudo sed -i 's/#SudoLoop/SudoLoop'/g /etc/paru.conf
sudo sed -i 's/#UseAsk/UseAsk'/g /etc/paru.conf
sudo sed -i 's/#CombinedUpgrade/CombinedUpgrade'/g /etc/paru.conf
sudo sed -i 's/#CleanAfter/CleanAfter'/g /etc/paru.conf
sudo sed -i 's/#NewsOnUpgrade/NewsOnUpgrade'/g /etc/paru.conf
sudo sed -i '/NewsOnUpgrade/ a\SkipReview\' /etc/paru.conf
sudo sed -i '/SkipReview/ a\BatchInstall\' /etc/paru.conf
echo -e "${GREEN}Paru options configured.${NC}"
sleep 10 ; clear

# Change to wget from curl for http/https downloads with Paru.
echo -e "${BLUE}Changing download manager to wget from curl for Paru...${NC}"
sudo sed -i 's|http::/usr/bin/curl -qgb "" -fLC - --retry 3 --retry-delay 3 -o %o %u|http::/usr/bin/wget --no-cookies --tries=3 --waitretry=3 --continue -O %o %u|' /etc/makepkg.conf
sudo sed -i 's|https::/usr/bin/curl -qgb "" -fLC - --retry 3 --retry-delay 3 -o %o %u|https::/usr/bin/wget --no-cookies --tries=3 --waitretry=3 --continue -O %o %u|' /etc/makepkg.conf
sleep 10 ; clear

# Install Konsole color scheme.
dialog --title "Konsole Colorscheme" --menu "Which Konsole colorscheme do you want?" 10 42 10 \
1 "Catppuccin" \
2 "OneHalf-Dark" \
3 "Ayu Mirage" 2> /tmp/konsole_resp
konsole_resp=$(cat /tmp/konsole_resp)
if [ "$konsole_resp" = 1 ]; then
    paru -S catppuccin-konsole-theme-git --noconfirm
elif [ "$konsole_resp" = 2 ]; then
    wcurl --curl-options="--progress-bar" https://raw.githubusercontent.com/sonph/onehalf/master/konsole/onehalf-dark.colorscheme
	sudo mkdir -p /usr/share/konsole
	sudo chmod 755 /usr/share/konsole
	sudo mv onehalf-dark.colorscheme /usr/share/konsole
	sudo chmod 644 /usr/share/konsole/onehalf-dark.colorscheme
elif [ "$konsole_resp" = 3 ]; then
    wcurl --curl-options="--progress-bar" https://raw.githubusercontent.com/mbadolato/iTerm2-Color-Schemes/refs/heads/master/konsole/Ayu%20Mirage.colorscheme -o AyuMirage.colorscheme
	sudo mkdir -p /usr/share/konsole
	sudo chmod 755 /usr/share/konsole
	sudo mv AyuMirage.colorscheme /usr/share/konsole
	sudo chmod 644 /usr/share/konsole/AyuMirage.colorscheme
fi
sleep 10 ; clear

# Install icon and KDE theme.
echo -e "${BLUE}Installing Qogir icon theme and Vimix KDE/GTK/Kvantum theme...${NC}"
paru -S qogir-icon-theme-git vimix-gtk-themes kvantum kvantum-qt5 qt5ct --noconfirm
git clone https://github.com/vinceliuice/Vimix-kde.git "$HOME"/Vimix-kde
cd "$HOME"/Vimix-kde || exit
sudo cp -rv aurorae/* /usr/share/aurorae/themes
sudo cp -rv color-schemes /usr/share
sudo cp -rv Kvantum /usr/share
sudo cp -rv plasma /usr/share
sudo cp -rv wallpaper/Vimix* /usr/share/plasma/wallpapers
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
sudo chmod 755 /usr/share/aurorae
sudo chmod 755 /usr/share/aurorae/themes
sudo chmod 755 /usr/share/aurorae/themes/Vimix*
sudo chmod 644 /usr/share/aurorae/themes/Vimix*/*
sudo chmod 755 /usr/share/Kvantum/Vimix*
sudo chmod 644 /usr/share/Kvantum/Vimix*/*
# Cleanup
cd "$HOME" || exit
rm -rf "$HOME"/Vimix-kde
sleep 10 ; clear

# Install Octopi, a Qt-based pacman frontend with AUR support.
echo -e "${BLUE}Installing Octopi...${NC}"
paru -S octopi --noconfirm
sleep 10 ; clear

# Install and configure printing support.
echo -e "${BLUE}Installing and configuring printing support...${NC}"
paru -S cups hplip-lite print-manager system-config-printer cups-pk-helper gutenprint foomatic-db-gutenprint-ppds tesseract-data-eng skanpage --noconfirm
sudo systemctl enable --now cups cups-browsed
sleep 10 ; clear

# Install PolKit rules for desktop privileges. Enables automounting, suspend and hibernation, and CPU frequency settings.
paru -S desktop-privileges-nogroups --noconfirm
sleep 10 ; clear

# Install hardware detection tool for mkinitcpio.
echo -e "${BLUE}Installing hardware detection tool for mkinitcpio...${NC}"
sudo pacman -S hwdetect --noconfirm
sleep 10 ; clear

# Install power-profiles-daemon package. Makes power management profiles available to KDE.
echo -e "${BLUE}Installing power-profiles-daemon package. Makes power management profiles available to KDE...${NC}"
sudo pacman -S power-profiles-daemon --noconfirm
sleep 10 ; clear

# Install NTFS filesystem driver.
echo -e "${BLUE}Installing NTFS filesystem driver...${NC}"
sudo pacman -S ntfs-3g --noconfirm
sleep 10 ; clear

# Install Brave web browser.
echo -e "${BLUE}Installing the Brave web browser...${NC}"
paru -S brave-bin --noconfirm
sleep 10 ; clear

# Install fonts.
echo -e "${BLUE}Installing fonts...${NC}"
paru -S ttf-poppins adobe-source-sans-fonts ttf-jetbrains-mono-nerd ttf-ms-fonts ttf-material-design-icons-desktop-git ttf-material-design-icons-git noto-fonts-emoji noto-fonts-lite ttf-nerd-fonts-symbols ttfautohint --noconfirm
sudo ln -s /usr/share/fontconfig/conf.avail/09-autohint-if-no-hinting.conf /etc/fonts/conf.d/
sleep 10 ; clear

# Install "lsd," a better replacement for ls.
echo -e "${BLUE}Installing 'lsd,' a better replacement for ls...${NC}"
paru -S lsd --noconfirm
sleep 10 ; clear

# Configure nerd fonts for "lsd".
echo -e "${BLUE}Configuring nerd fonts for 'lsd'...${NC}"
sudo ln -s /usr/share/fontconfig/conf.avail/10-nerd-font-symbols.conf /etc/fonts/conf.d/
echo -e "${GREEN}Fonts configured.${NC}"
sleep 10 ; clear

# Install and configure fastfetch.
echo -e "${BLUE}Installing and configuring 'fastfetch'...${NC}"
sudo pacman -S fastfetch --noconfirm
mkdir "$HOME"/.config/fastfetch
sudo mkdir /etc/skel/.config/fastfetch
cp -v "$HOME"/linux-stuff/Dotfiles/config/fasfetch/config.jsonc "$HOME"/.config/fastfetch
sudo cp -v "$HOME"/linux-stuff/Dotfiles/config/fasfetch/config.jsonc /etc/skel/.config/fastfetch
# Fix directory permissions.
sudo chmod 755 /etc/skel/.config/fastfetch
# Fix config file permissions.
sudo chmod 644 /etc/skel/.config/fastfetch/config.jsonc
sleep 10 ; clear

# Install and configure VSCodium.
echo -e "${BLUE}Installing and configuring VSCodium...${NC}"
paru -S vscodium-bin vscodium-bin-marketplace --noconfirm
mkdir -p "$HOME"/.config/VSCodium/User && cp -v "$HOME"/linux-stuff/Dotfiles/config/VSCodium/User/settings.json "$HOME"/.config/VSCodium/User/settings.json
vscodium --install-extension qyurila.ayu-midas
vscodium --install-extension jeff-hykin.better-shellscript-syntax
vscodium --install-extension file-icons.file-icons
vscodium --install-extension miguelsolorio.fluent-icons
vscodium --install-extension streetsidesoftware.code-spell-checker
sleep 10 ; clear

# Install GRUB theme.
echo -e "${BLUE}Installing and configuring GRUB theme...${NC}"
paru -S grub-theme-stylish-color-1080p-git --noconfirm
sudo sed -i 's|#GRUB_THEME="/path/to/gfxtheme"|GRUB_THEME="/usr/share/grub/themes/stylish-color-1080p/theme.txt"|g' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
sleep 10 ; clear

# Install Wine.
echo -e "${BLUE}Installing Wine...${NC}"
paru -S wine-installer wine-gecko wine-mono --noconfirm
sleep 10 ; clear

# Install some useful software.
echo -e "${BLUE}Installing some useful software for daily tasks and multimedia needs...${NC}"
sudo pacman -S unrar vlc transmission-qt pinta audacity k3b okular spectacle p7zip clipgrab partitionmanager dolphin-plugins --noconfirm
sleep 10 ; clear

# Install balenaEtcher to write OS images to USB flash drives.
echo -e "${BLUE}Installing balenaEtcher...${NC}"
paru -S etcher-bin --noconfirm
sleep 10 ; clear

# Install VirtualBox.
echo -e "${BLUE}Installing VirtualBox...${NC}"
sudo pacman -S virtualbox virtualbox-guest-iso --noconfirm
sleep 10 ; clear

# Install mp3tag.
echo -e "${BLUE}Installing mp3tag...${NC}"
paru -S mp3tag --noconfirm
sleep 10 ; clear

# Install dependencies for k3b.
echo -e "${BLUE}Installing dependencies for k3b to ensure all features work correctly...${NC}"
paru -S cdrtools dvd+rw-tools transcode sox normalize cdrdao --noconfirm
sleep 10 ; clear

# Install some KDE games.
echo -e "${BLUE}Installing some KDE games...${NC}"
sudo pacman -S kapman kblocks kbounce kbreakout kmines knetwalk kpat kreversi --noconfirm
sleep 10 ; clear

# Install Spotify.
echo -e "${BLUE}Installing Spotify...${NC}"
paru -S spotify --noconfirm
sleep 10 ; clear

# Install KDE Connect.
echo -e "${BLUE}Installing KDE Connect...${NC}"
sudo pacman -S kdeconnect --noconfirm
sleep 10 ; clear

# Install gufw firewall and enable the systemd service.
echo -e "${BLUE}Installing and enabling the 'gufw' firewall...${NC}"
sudo pacman -S gufw --noconfirm
sudo systemctl enable --now ufw
sleep 10 ; clear

# Install some useful pacman post-transaction hooks.
echo -e "${BLUE}Installing useful Pacman post-transaction hooks to automate system maintenance tasks...${NC}"
paru -S paccache-hook grub-hook sync-pacman-hook-git remove-orphaned-kernels pacman-log-orphans-hook --noconfirm
echo -e "${BLUE}Configuring paccache-hook to keep 0 cached packages...${NC}"
sudo sed -i 's/installed_keep=2/installed_keep=0/g' /etc/paccache-hook.conf
if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}paccache-hook configuration updated successfully!${NC}"
else
    echo -e "${RED}Failed to update the paccache-hook configuration. Please check the configuration file manually.${NC}"
fi
sleep 10 ; clear

# Setup config files and stuff.
cd linux-stuff/ || exit
./bat-setup.sh
./lsd-setup.sh
sudo ./cleanup-systemd-boot.sh
sleep 10 ; clear

# Configure Zsh.
echo -e "${BLUE}Configuring Zsh...${NC}"
paru -S oh-my-zsh-git --noconfirm
cp -v /usr/share/oh-my-zsh/zshrc "$HOME"/.zshrc
sed -i s/ZSH_THEME='"robbyrussell"'/ZSH_THEME='"jpassarelli"'/g "$HOME"/.zshrc
sed -i 's/# HYPHEN_INSENSITIVE="true"/HYPHEN_INSENSITIVE="true"/g' "$HOME"/.zshrc
sed -i 's/'"# zstyle ':omz:update' mode disabled"'/'"zstyle ':omz:update' mode disabled"''/g "$HOME"/.zshrc
sed -i 's/# ENABLE_CORRECTION="true"/ENABLE_CORRECTION="true"/g' "$HOME"/.zshrc
sed -i 's/# COMPLETION_WAITING_DOTS="true"/COMPLETION_WAITING_DOTS="true"/g' "$HOME"/.zshrc
sed -i 's/# DISABLE_UNTRACKED_FILES_DIRTY="true"/DISABLE_UNTRACKED_FILES_DIRTY="true"/g' "$HOME"/.zshrc
sed -i 's|# HIST_STAMPS="mm/dd/yyyy"|HIST_STAMPS="mm/dd/yyyy"|g' "$HOME"/.zshrc
sed -i 's/'"plugins=(git)/plugins=(git colored-man-pages safe-paste sudo copypath zsh-autosuggestions zsh-syntax-highlighting)"'/g' "$HOME"/.zshrc
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
echo "" >> "$HOME"/.zshrc
echo "# Set the default umask." >> "$HOME"/.zshrc
echo "umask 077" >> "$HOME"/.zshrc
echo "" >> "$HOME"/.zshrc
echo "# Disable highlighting of pasted text." >> "$HOME"/.zshrc
echo "zle_highlight=('paste:none')" >> "$HOME"/.zshrc
echo "" >> "$HOME"/.zshrc
echo "# Apply sensible history settings." >> "$HOME"/.zshrc
echo "setopt HIST_EXPIRE_DUPS_FIRST" >> "$HOME"/.zshrc
echo "setopt HIST_FIND_NO_DUPS" >> "$HOME"/.zshrc
echo "setopt HIST_IGNORE_ALL_DUPS" >> "$HOME"/.zshrc
echo "setopt HIST_IGNORE_DUPS" >> "$HOME"/.zshrc
echo "setopt HIST_IGNORE_SPACE" >> "$HOME"/.zshrc
echo "setopt HIST_SAVE_NO_DUPS" >> "$HOME"/.zshrc
echo alias ls='"lsd"' >> "$HOME"/.zshrc
echo alias cat='"bat"' >> "$HOME"/.zshrc
sleep 10 ; clear

# Setup Catppuccin colors.
cd "$HOME" && git clone https://github.com/catppuccin/zsh-syntax-highlighting.git
sudo cp -v zsh-syntax-highlighting/themes/*.zsh /etc/zsh

read -rp "$(echo -e "${YELLOW}Which Catppuccin colors do you want for Zsh syntax highlighting?${NC}")
1.) Latte
2.) Frappé
3.) Macchiato
4.) Mocha

0.) None.
-> " resp
case "$resp" in
    1) echo "source /etc/zsh/catppuccin_latte-zsh-syntax-highlighting.zsh" >> "$HOME"/.zshrc ;;
    2) echo "source /etc/zsh/catppuccin_frappe-zsh-syntax-highlighting.zsh" >> "$HOME"/.zshrc ;;
    3) echo "source /etc/zsh/catppuccin_macchiato-zsh-syntax-highlighting.zsh" >> "$HOME"/.zshrc ;;
    4) echo "source /etc/zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh" >> "$HOME"/.zshrc ;;
    0) sudo rm -rf /etc/zsh/*.zsh ;;
    *) echo -e "${RED}Invalid option. Please choose a valid number.${NC}" ;;
esac
rm -rf zsh-syntax-highlighting

sudo cp -v "$HOME"/.zshrc /etc/skel/.zshrc
sudo cp -v /etc/skel/.zshrc /root/.zshrc
echo fastfetch >> "$HOME"/.zshrc
sleep 10 ; clear

# Copy over custom Oh My Zsh theme.
sudo cp -v "$HOME"/linux-stuff/jpassarelli.zsh-theme /usr/share/oh-my-zsh/custom/themes

# Change user's shell to zsh.
chsh -s /usr/bin/zsh "$USER"

# Update environment variables.
# Set BROWSER variable.
echo 'BROWSER=brave' | sudo tee -a /etc/environment > /dev/null
# Set EDITOR variable.
echo 'EDITOR=vim' | sudo tee -a /etc/environment > /dev/null
# Enable VSCodium to use QT file dialogs by default instead of GTK.
echo 'GTK_USE_PORTAL=1' | sudo tee -a /etc/environment > /dev/null
# Enable QT5 apps to use Kvantum theming engine.
echo 'QT_QPA_PLATFORMTHEME=qt5ct' | sudo tee -a /etc/environment > /dev/null

# Install mkinitcpio firmware, gets rid of missing firmware messages.
echo -e "${BLUE}Installing mkinitcpio firmware to get rid of missing firmware messages...${NC}"
paru -S mkinitcpio-firmware --noconfirm
sleep 10 ; clear

# Use xz compression when compressing the initramfs image.
sudo sed -i 's/#COMPRESSION="xz"/COMPRESSION="xz"/g' /etc/mkinitcpio.conf

# Stop mkinitcpio from generating a fallback kernel image.
echo -e "${BLUE}Stopping mkinitcpio from generating a fallback kernel image...${NC}"
if [ "$(uname -r | grep arch | awk -F "-" '{print $(NF)}')" ]; then
	sudo sed -i 's/'"PRESETS=('default' 'fallback')"'/'"PRESETS=('default')"''/g /etc/mkinitcpio.d/linux.preset
	sudo sed -i 's|fallback_image="/boot/initramfs-linux-fallback.img"|#fallback_image="/boot/initramfs-linux-fallback.img"|g' /etc/mkinitcpio.d/linux.preset
	sudo sed -i 's/fallback_options="-S autodetect"/#fallback_options="-S autodetect"'/g /etc/mkinitcpio.d/linux.preset
	sudo mkinitcpio -p linux
	sudo rm /boot/initramfs-linux-fallback.img
	sudo grub-mkconfig -o /boot/grub/grub.cfg
fi
if [ "$(uname -r | grep hardened | awk -F "-" '{print $(NF)}')" ]; then
	sudo sed -i 's/'"PRESETS=('default' 'fallback')"'/'"PRESETS=('default')"''/g /etc/mkinitcpio.d/linux-hardened.preset
	sudo sed -i 's|fallback_image="/boot/initramfs-linux-hardened-fallback.img"|#fallback_image="/boot/initramfs-linux-hardened-fallback.img"|g' /etc/mkinitcpio.d/linux-hardened.preset
	sudo sed -i 's/fallback_options="-S autodetect"/#fallback_options="-S autodetect"'/g /etc/mkinitcpio.d/linux-hardened.preset
	sudo mkinitcpio -p linux-hardened
	sudo rm /boot/initramfs-linux-hardened-fallback.img
	sudo grub-mkconfig -o /boot/grub/grub.cfg
fi
if [ "$(uname -r | grep lts | awk -F "-" '{print $(NF)}')" ]; then
	sudo sed -i 's/'"PRESETS=('default' 'fallback')"'/'"PRESETS=('default')"''/g /etc/mkinitcpio.d/linux-lts.preset
	sudo sed -i 's|fallback_image="/boot/initramfs-linux-lts-fallback.img"|#fallback_image="/boot/initramfs-linux-lts-fallback.img"|g' /etc/mkinitcpio.d/linux-lts.preset
	sudo sed -i 's/fallback_options="-S autodetect"/#fallback_options="-S autodetect"'/g /etc/mkinitcpio.d/linux-lts.preset
	sudo mkinitcpio -p linux-lts
	sudo rm /boot/initramfs-linux-lts-fallback.img
	sudo grub-mkconfig -o /boot/grub/grub.cfg
fi
if [ "$(uname -r | grep zen | awk -F "-" '{print $(NF)}')" ]; then
	sudo sed -i 's/'"PRESETS=('default' 'fallback')"'/'"PRESETS=('default')"''/g /etc/mkinitcpio.d/linux-zen.preset
	sudo sed -i 's|fallback_image="/boot/initramfs-linux-zen-fallback.img"|#fallback_image="/boot/initramfs-linux-zen-fallback.img"|g' /etc/mkinitcpio.d/linux-zen.preset
	sudo sed -i 's/fallback_options="-S autodetect"/#fallback_options="-S autodetect"'/g /etc/mkinitcpio.d/linux-zen.preset
	sudo mkinitcpio -p linux-zen
	sudo rm /boot/initramfs-linux-zen-fallback.img
	sudo grub-mkconfig -o /boot/grub/grub.cfg
fi
if [ "$(uname -r | grep realtime | awk -F "-" '{print $(NF)}')" ]; then
	sudo sed -i 's/'"PRESETS=('default' 'fallback')"'/'"PRESETS=('default')"''/g /etc/mkinitcpio.d/linux-rt.preset
	sudo sed -i 's|fallback_image="/boot/initramfs-linux-rt-fallback.img"|#fallback_image="/boot/initramfs-linux-rt-fallback.img"|g' /etc/mkinitcpio.d/linux-rt.preset
	sudo sed -i 's/fallback_options="-S autodetect"/#fallback_options="-S autodetect"'/g /etc/mkinitcpio.d/linux-rt.preset
	sudo mkinitcpio -p linux-rt
	sudo rm /boot/initramfs-linux-rt-fallback.img
	sudo grub-mkconfig -o /boot/grub/grub.cfg
fi
if [ "$(uname -r | grep rt-lts | awk -F "-" '{print $(NF)}')" ]; then
	sudo sed -i 's/'"PRESETS=('default' 'fallback')"'/'"PRESETS=('default')"''/g /etc/mkinitcpio.d/linux-rt-lts.preset
	sudo sed -i 's|fallback_image="/boot/initramfs-linux-rt-lts-fallback.img"|#fallback_image="/boot/initramfs-linux-rt-lts-fallback.img"|g' /etc/mkinitcpio.d/linux-rt-lts.preset
	sudo sed -i 's/fallback_options="-S autodetect"/#fallback_options="-S autodetect"'/g /etc/mkinitcpio.d/linux-rt-lts.preset
	sudo mkinitcpio -p linux-rt-lts
	sudo rm /boot/initramfs-linux-rt-lts-fallback.img
	sudo grub-mkconfig -o /boot/grub/grub.cfg
fi

# Configure lynis.
echo -e "${BLUE}Configuring lynis...${NC}"
sudo tee /etc/lynis/custom.prf > /dev/null << EOF
machine-role=personal
test-scan-mode=normal

# Plugins to disable
disable-plugin=docker
disable-plugin=forensics
disable-plugin=intrusion-detection
disable-plugin=intrusion-prevention
disable-plugin=nginx
EOF

# Secure the OS.
echo -e "${BLUE}Hardening the OS...${NC}"
sudo pacman -S arch-audit apparmor sysstat puppet rkhunter libpwquality rng-tools --noconfirm
paru -S acct chkrootkit --noconfirm
sudo chmod 600 /boot/grub/grub.cfg
sudo chmod 600 /etc/ssh/sshd_config
sudo sed -i 's/umask 022/umask 077'/g /etc/login.defs
sudo sed -i 's/UMASK=0022/UMASK=0077'/g /etc/conf.d/sysstat

sudo tee -a /etc/profile > /dev/null << EOF
# Set default umask.
umask 077
EOF

sudo tee -a /etc/sysctl.d/99-sysctl.conf > /dev/null << EOF
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

# Enable accounting.
sudo touch /var/log/account/pacct
sudo accton on
sudo systemctl enable --now acct
sudo systemctl enable --now puppet
sudo systemctl enable --now auditd
sudo systemctl enable --now rngd
sudo tee -a /etc/conf.d/sysstat > /dev/null << EOF
#####
echo 'ENABLED="true"'
EOF
sudo systemctl enable --now sysstat

sudo tee -a /etc/bash.bashrc > /dev/null << EOF
# Set default umask.
umask 077
EOF

sudo tee -a /etc/hosts > /dev/null << EOF
127.0.0.1 localhost
::1 localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
127.0.1.1 $(hostname)
EOF

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
sudo sed -i 's/#SHA_CRYPT_MAX_ROUNDS 5000/SHA_CRYPT_MAX_ROUNDS 100000'/g /etc/login.defs

# Change password encryption method from "YESCRYPT" to "SHA256."
sudo sed -i 's/ENCRYPT_METHOD YESCRYPT/ENCRYPT_METHOD SHA256'/g /etc/login.defs
sudo tee -a /etc/pam.d/passwd > /dev/null << EOF
#
# These lines require the user to select a password with a minimum
# length of 8 and with at least 1 digit number, and 1 upper case
# letter.
#
password required pam_pwquality.so \
              dcredit=-1 ucredit=-1 lcredit=0 minlen=8
password required pam_unix.so use_authtok nullok sha256
EOF

# Setup AppArmor.
echo -e "${BLUE}Setting up AppArmor...${NC}"
sudo sed -i 's/#write-cache/write-cache'/g /etc/apparmor/parser.conf
sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"/GRUB_CMDLINE_LINUX_DEFAULT="nowatchdog nmi_watchdog=0 loglevel=3 lsm=landlock,lockdown,yama,integrity,apparmor,bpf"/g' /etc/default/grub && sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo systemctl enable --now apparmor
sleep 10 ; clear

# Prettify Arch logo.
sudo sed -i 's/LOGO=archlinux-logo/LOGO=distributor-logo-archlinux'/g /etc/os-release

# Hide menu entries and remove files.
echo -e "${BLUE}Cleaning up KDE menu entries...${NC}"
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
  "org.kde.kcolorchooser.desktop"
)

# Remove the files
for file in "${files[@]}"
do
  sudo rm -rf "$source_dir$file"
  echo -e "${BLUE}Removed $file...${NC}"
done

# Insert NoExtract directive with sed
for file in "${files[@]}"
do
  filename=$(basename "$file")
  sudo sed -i '/#NoExtract/a NoExtract = '"usr/share/applications/$filename" /etc/pacman.conf
done

# Delete the existing '#NoExtract' line
sudo sed -i '/^#NoExtract = $/d' /etc/pacman.conf

echo -e "${GREEN}All files removed and NoExtract directive updated.${NC}"
####################
sleep 10 ; clear

# Disable submenus in GRUB.
echo -e "${BLUE}Disabling submenus in GRUB...${NC}"
sudo sed -i 's/#GRUB_DISABLE_SUBMENU=y/GRUB_DISABLE_SUBMENU=y'/g /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Speed up systemd journal flush.
echo -e "${BLUE}Speeding up systemd journal flush...${NC}"
sudo sed -i 's/#Storage=auto/Storage=volatile'/g /etc/systemd/journald.conf
sudo sed -i 's/#SystemMaxFileSize=/SystemMaxFileSize=20MB'/g /etc/systemd/journald.conf

# Install pacman wrapper for easier command syntax (and set up).
echo -e "${BLUE}Installing pacman wrapper for easier command syntax...${NC}"
paru -S pac-wrapper --noconfirm
sudo tee -a /etc/environment > /dev/null << EOF
PAC_PACMAN=paru
EOF
source /etc/environment
sleep 10 ; clear

# Install and enable orphan-manager, a systemd timer to automatically remove orphaned packages.
echo -e "${BLUE}Installing and enabling 'orphan-manager,' a systemd timer to automatically remove orphaned packages...${NC}"
paru -S orphan-manager --noconfirm
sudo systemctl enable --now orphan-manager.timer
sleep 10 ; clear

# Add scripts to automatically purge .pacnew and .pacsave files.
echo -e "${BLUE}Adding scripts to the system to automatically purge .pacnew and .pacsave files...${NC}"
sudo ./purge_pacnew.sh
sudo ./restore_pacsave.sh

# Configure console text editor.
echo -e "${YELLOW}Which console text editor do you want?${NC}"
echo "1.) Micro"
echo "2.) Vim"
echo "3.) Vim with Catppuccino colorscheme"
read -rp "-> " resp

case "$resp" in
    1)
        sudo pacman -S micro xclip --noconfirm
        "$HOME"/./linux-stuff/micro-setup.sh
        sudo sed -i 's/vim/micro/g' /etc/environment
        echo MICRO_TRUECOLOR=1 | sudo tee -a /etc/environment > /dev/null
        sudo pacman -Rns vim
        ;;
    2)
        "$HOME"/./linux-stuff/vim_setup_archlinux.sh
        ;;
    3)
        "$HOME"/./linux-stuff/vim_setup_catppuccino_archlinux.sh
        ;;
esac
sleep 10 ; clear

# Install and fix Plymouth and apply theme!
sudo pacman -S plymouth --noconfirm
sudo sed -i '/^HOOKS=/s/\(.*\)\(microcode\)/\1plymouth \2/' /etc/mkinitcpio.conf
sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="nowatchdog nmi_watchdog=0 loglevel=3 lsm=landlock,lockdown,yama,integrity,apparmor,bpf"/GRUB_CMDLINE_LINUX_DEFAULT="nowatchdog nmi_watchdog=0 quiet loglevel=3 udev.log-priority=3 lsm=landlock,lockdown,yama,integrity,apparmor,bpf udev.log_level=3 splash net.ifnames=0"/g' /etc/default/grub
echo ShowDelay=0 | sudo tee -a /etc/plymouth/plymouthd.conf > /dev/null
paru -S plymouth-theme-arch-charge-big --noconfirm
sudo plymouth-set-default-theme -R arch-charge-big
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Check if we're running on VMware.
if dmesg | grep -iq 'VMware\|Virtual Machine'; then
    # Install open-vm-tools.
    echo -e "${GREEN}Running on VMware, installing open-vm-tools and the Xorg mouse driver...${NC}"
    sudo pacman -S open-vm-tools xf86-input-vmmouse --noconfirm
    sudo systemctl enable --now vmtoolsd
    sudo systemctl enable --now vmware-vmblock-fuse
else
    echo -e "${RED}Not running on VMware.${NC} ${GREEN}Skipping open-vm-tools installation.${NC}"
fi
