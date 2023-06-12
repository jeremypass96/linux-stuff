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
sudo sed -i 's/#NoExtract   =/NoExtract    = mirrorlist.pacnew'/g /etc/pacman.conf
sudo pacman -Syy

# Setup "blackpac" script. Shell script utility that enables you to backlist packages.
# Download script.
cd && wget http://downloads.sourceforge.net/project/ig-scripts/blackpac.sh
# Make script executable.
chmod +x blackpac.sh
# Install script.
sudo install blackpac.sh /usr/local/bin/
sudo mv /usr/local/bin/blackpac.sh /usr/local/bin/blackpac
rm blackpac.sh
# Blacklist and remvove packages.
sudo blackpac --blacklist qt5-tools
sudo pacman -R qt5-tools --noconfirm

# Install and use better NTP daemon.
sudo pacman -S chrony --noconfirm
sudo sed -i 's/! server 0.arch.pool.ntp.org iburst/server 0.arch.pool.ntp.org iburst'/g /etc/chrony.conf
sudo sed -i 's/! server 1.arch.pool.ntp.org iburst/server 1.arch.pool.ntp.org iburst'/g /etc/chrony.conf
sudo sed -i 's/! server 3.arch.pool.ntp.org iburst/server 3.arch.pool.ntp.org iburst'/g /etc/chrony.conf
sudo systemctl disable systemd-timesyncd.service
sudo systemctl enable --now chronyd && sudo systemctl enable --now chrony-wait
sudo chronyc online

# Remove unneeded packages.
sudo pacman -Rsu nano vim htop kate --noconfirm

# Install ffmpegthumbs, for video file thumbnail support in Dolphin.
sudo pacman -S ffmpegthumbs --noconfirm

# Install thumbnail support for PDF files.
sudo pacman -S kdegraphics-thumbnailers --noconfirm

# Install some KDE utilities.
sudo pacman -S kcalc kcharselect kfind kwalletmanager kdialog sweeper khelpcenter gwenview kaccounts-providers kio-gdrive --noconfirm

# Install some core utilities that didn't get installed, for some reason.
sudo pacman -S man-pages man-db logrotate cracklib usbutils hddtemp --noconfirm

# Install some command-line utilities.
sudo pacman -S micro xclip duf bat fd lynis btop --noconfirm

# Install spell checking support.
sudo pacman -S aspell aspell-en --noconfirm

# Install paru AUR helper.
sudo pacman -S --needed base-devel && git clone https://aur.archlinux.org/paru-bin.git && cd paru-bin && makepkg -sic --noconfirm
cd .. && rm -rf paru-bin
# Configure paru options.
sudo sed -i 's/#BottomUp/BottomUp'/g /etc/paru.conf
sudo sed -i 's/#RemoveMake/RemoveMake'/g /etc/paru.conf
sudo sed -i 's/#SudoLoop/SudoLoop'/g /etc/paru.conf
sudo sed -i 's/#UseAsk/UseAsk'/g /etc/paru.conf
sudo sed -i 's/#CombinedUpgrade/CombinedUpgrade'/g /etc/paru.conf
sudo sed -i 's/#CleanAfter/CleanAfter'/g /etc/paru.conf
sudo sed -i '/#NewsOnUpgrade/ a\SkipReview\' /etc/paru.conf
sudo sed -i '/SkipReview/ a\BatchInstall\' /etc/paru.conf

# Install Konsole color scheme.
paru -S catppuccin-konsole-theme-git --noconfirm

# Install icon, cursor, and KDE theme.
paru -S newaita-icons-git bibata-cursor-theme-bin vimix-theme-kde-git vimix-gtk-themes-git plasma-splash-arch-moe kvantum --noconfirm

# Install and configure printing support.
paru -S cups hplip-lite print-manager system-config-printer cups-pk-helper gutenprint foomatic-db-gutenprint-ppds tesseract-data-eng skanpage --noconfirm
sudo systemctl enable --now cups cups-browsed

# Install PolKit rules for desktop privileges. Enables automounting, suspend and hibernation, and CPU frequency settings.
paru -S desktop-privileges --noconfirm

# Install hardware dection tool for mkinitcpio.
sudo pacman -S hwdetect --noconfirm

# Install Brave web browser.
paru -S brave-bin --noconfirm

# Install fonts.
paru -S ttf-poppins adobe-source-sans-fonts ttf-jetbrains-mono-nerd ttf-ms-fonts ttf-material-design-icons-desktop-git ttf-material-design-icons ttf-material-design-icons-git noto-fonts-emoji ttf-nerd-fonts-symbols --noconfirm
sudo ln -s /usr/share/fontconfig/conf.avail/09-autohint-if-no-hinting.conf /etc/fonts/conf.d/

# Configure nerd fonts for "lsd".
sudo ln -s /usr/share/fontconfig/conf.avail/10-nerd-font-symbols.conf /etc/fonts/conf.d/

# Install "lsd," a better replacement for ls.
paru -S lsd --noconfirm

# Install topgrade.
paru -S topgrade-bin --noconfirm

# Install pfetch.
paru -S pfetch --noconfirm

# Install Pamac, GUI frontend to install software.
paru -S pamac-aur pamac-tray-icon-plasma --noconfirm

# Install and configure VSCodium.
paru -S vscodium-bin vscodium-bin-marketplace --noconfirm
mkdir -p /home/$USER/.config/VSCodium/User && cp -v /home/$USER/linux-stuff/Dotfiles/config/VSCodium/User/settings.json /home/$USER/.config/VSCodium/User/settings.json
vscodium --install-extension Catppuccin.catppuccin-vsc
vscodium --install-extension Catppuccin.catppuccin-vsc-icons
vscodium --install-extension jeff-hykin.better-shellscript-syntax

# Install grub theme.
paru -S grub-theme-stylish-color-1080p-git --noconfirm
sudo sed -i 's|#GRUB_THEME="/path/to/gfxtheme"|GRUB_THEME="/usr/share/grub/themes/stylish-color-1080p/theme.txt"|g' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Install Wine.
paru -S wine-installer wine-gecko wine-mono --noconfirm

# Install some useful software.
sudo pacman -S unrar vlc transmission-qt pinta audacity k3b okular spectacle p7zip clipgrab partitionmanager --noconfirm

# Install balenaEtcher to write OS images to USB flash drives.
paru -S balena-etcher --noconfirm

# Install mp3tag.
paru -S mp3tag --noconfirm

# Install dependencies for k3b.
paru -S cdrtools dvd+rw-tools transcode sox normalize --noconfirm

# Install some KDE games!
sudo pacman -S kapman kblocks kbounce kbreakout kmines knetwalk kpat kreversi --noconfirm

# Install Spotify.
paru -S spotify --noconfirm

# Install KDE Connect.
sudo pacman -S kdeconnect --noconfirm

# Install gufw firewall and enable the systemd service.
sudo pacman -S gufw --noconfirm
sudo systemctl enable --now ufw

# Install some useful pacman post-transaction hooks.
paru -S pacman-cleanup-hook grub-hook sync-pacman-hook-git remove-orphaned-kernels pacman-log-orphans-hook --noconfirm

# Setup config files and stuff.
cd linux-stuff/
./bat-setup.sh
./lsd-setup.sh
./micro-setup.sh
sudo ./cleanup-systemd-boot.sh

# Configure Zsh.
echo "Configuring Zsh..."
paru -S oh-my-zsh-git oh-my-zsh-plugin-syntax-highlighting oh-my-zsh-plugin-autosuggestions --noconfirm
cp -v /usr/share/oh-my-zsh/zshrc /home/$USER/.zshrc
sed -i s/ZSH_THEME='"robbyrussell"'/ZSH_THEME='"gentoo"'/g /home/$USER/.zshrc
sed -i 's/# HYPHEN_INSENSITIVE="true"/HYPHEN_INSENSITIVE="true"/g' /home/$USER/.zshrc
sed -i 's/'"# zstyle ':omz:update' mode disabled"'/'"zstyle ':omz:update' mode disabled"''/g /home/$USER/.zshrc
sed -i 's/# ENABLE_CORRECTION="true"/ENABLE_CORRECTION="true"/g' /home/$USER/.zshrc
sed -i 's/# COMPLETION_WAITING_DOTS="true"/COMPLETION_WAITING_DOTS="true"/g' /home/$USER/.zshrc
sed -i 's|# HIST_STAMPS="mm/dd/yyyy"|HIST_STAMPS="mm/dd/yyyy"|g' /home/$USER/.zshrc
sed -i 's/'"plugins=(git)/plugins=(git colored-man-pages safe-paste sudo copypath zsh-autosuggestions zsh-syntax-highlighting)"'/g' /home/$USER/.zshrc
echo alias ls='"lsd"' >> /home/$USER/.zshrc
echo alias cat='"bat"' >> /home/$USER/.zshrc
cd
# Setup Catppuccin colors.
git clone https://github.com/catppuccin/zsh-syntax-highlighting.git
cd zsh-syntax-highlighting/themes/
sudo cp -v *.zsh /etc/zsh
read -p "Which Catppuccin colors do you want for Zsh syntax highlighting?
1.) Latte
2.) Frappé
3.) Macchiato
4.) Mocha
-> " resp
if [ "$resp" = 1 ]; then
echo source /etc/zsh/catppuccin_latte-zsh-syntax-highlighting.zsh >> /home/$USER/.zshrc
fi
if [ "$resp" = 2 ]; then
echo source /etc/zsh/catppuccin_frappe-zsh-syntax-highlighting.zsh >> /home/$USER/.zshrc
fi
if [ "$resp" = 3 ]; then
echo source /etc/zsh/catppuccin_macchiato-zsh-syntax-highlighting.zsh >> /home/$USER/.zshrc
fi
if [ "$resp" = 4 ]; then
echo source /etc/zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh >> /home/$USER/.zshrc
fi
cd && rm -rf zsh-syntax-highlighting
sudo cp -v /home/$USER/.zshrc /etc/skel/.zshrc
sudo cp -v /etc/skel/.zshrc /root/.zshrc
echo pfetch >> /home/$USER/.zshrc

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
echo EDITOR=micro >> /etc/environment
# Set MICRO_TRUECOLOR variable.
echo MICRO_TRUECOLOR=1 >> /etc/environment
# Remove permission for other users to write to this file.
sudo chmod o-w /etc/environment

# Install mkinitcpio firmware, gets rid of missing firmware messages.
paru -S mkinitcpio-firmware --noconfirm

# Stop mkinitcpio from generating a fallback kernel image.
echo "Stopping mkinitcpio from generating a fallback kernel image..."
if [ $(uname -r | grep arch) ]; then
sudo sed -i 's/'"PRESETS=('default' 'fallback')"'/'"PRESETS=('default')"''/g /etc/mkinitcpio.d/linux.preset
sudo sed -i 's|fallback_image="/boot/initramfs-linux-fallback.img"|#fallback_image="/boot/initramfs-linux-fallback.img"|g' /etc/mkinitcpio.d/linux.preset
sudo sed -i 's/fallback_options="-S autodetect"/#fallback_options="-S autodetect"'/g /etc/mkinitcpio.d/linux.preset
sudo mkinitcpio -p linux
sudo rm /boot/initramfs-linux-fallback.img
sudo grub-mkconfig -o /boot/grub/grub.cfg
fi
if [ $(uname -r | grep hardened) ]; then
sudo sed -i 's/'"PRESETS=('default' 'fallback')"'/'"PRESETS=('default')"''/g /etc/mkinitcpio.d/linux-hardened.preset
sudo sed -i 's|fallback_image="/boot/initramfs-linux-hardened-fallback.img"|#fallback_image="/boot/initramfs-linux-hardened-fallback.img"|g' /etc/mkinitcpio.d/linux-hardened.preset
sudo sed -i 's/fallback_options="-S autodetect"/#fallback_options="-S autodetect"'/g /etc/mkinitcpio.d/linux-hardened.preset
sudo mkinitcpio -p linux-hardened
sudo rm /boot/initramfs-linux-hardened-fallback.img
sudo grub-mkconfig -o /boot/grub/grub.cfg
fi
if [ $(uname -r | grep lts) ]; then
sudo sed -i 's/'"PRESETS=('default' 'fallback')"'/'"PRESETS=('default')"''/g /etc/mkinitcpio.d/linux-lts.preset
sudo sed -i 's|fallback_image="/boot/initramfs-linux-lts-fallback.img"|#fallback_image="/boot/initramfs-linux-lts-fallback.img"|g' /etc/mkinitcpio.d/linux-lts.preset
sudo sed -i 's/fallback_options="-S autodetect"/#fallback_options="-S autodetect"'/g /etc/mkinitcpio.d/linux-lts.preset
sudo mkinitcpio -p linux-lts
sudo rm /boot/initramfs-linux-lts-fallback.img
sudo grub-mkconfig -o /boot/grub/grub.cfg
fi
if [ $(uname -r | grep zen) ]; then
sudo sed -i 's/'"PRESETS=('default' 'fallback')"'/'"PRESETS=('default')"''/g /etc/mkinitcpio.d/linux-zen.preset
sudo sed -i 's|fallback_image="/boot/initramfs-linux-zen-fallback.img"|#fallback_image="/boot/initramfs-linux-zen-fallback.img"|g' /etc/mkinitcpio.d/linux-zen.preset
sudo sed -i 's/fallback_options="-S autodetect"/#fallback_options="-S autodetect"'/g /etc/mkinitcpio.d/linux-zen.preset
sudo mkinitcpio -p linux-zen
sudo rm /boot/initramfs-linux-zen-fallback.img
sudo grub-mkconfig -o /boot/grub/grub.cfg
fi

# Secure the OS.
sudo pacman -S arch-audit apparmor sysstat puppet rkhunter --noconfirm
paru -S acct chkrootkit --noconfirm
sudo chmod og-rwx /boot/grub/grub.cfg
sudo chmod og-rwx /etc/ssh/sshd_config
sudo sed -i 's/umask 022/umask 077'/g /etc/profile
sudo sed -i 's/UMASK=0022/UMASK=0077'/g /etc/conf.d/sysstat
sudo touch /etc/sysctl.d/99-sysctl.conf
sudo chmod o+w /etc/sysctl.d/99-sysctl.conf
echo "dev.tty.ldisc_autoload = 0" >> /etc/sysctl.d/99-sysctl.conf
echo "fs.protected_fifos = 2" >> /etc/sysctl.d/99-sysctl.conf
echo "fs.protected_regular = 2" >> /etc/sysctl.d/99-sysctl.conf
echo "fs.suid_dumpable = 0" >> /etc/sysctl.d/99-sysctl.conf
echo "kernel.sysrq = 0" >> /etc/sysctl.d/99-sysctl.conf
echo "kernel.unprivileged_bpf_disabled = 1" >> /etc/sysctl.d/99-sysctl.conf
echo "net.ipv4.conf.all.log_martians = 1" >> /etc/sysctl.d/99-sysctl.conf
echo "net.ipv4.conf.all.send_redirects = 0" >> /etc/sysctl.d/99-sysctl.conf
echo "net.ipv4.conf.default.log_martians = 1" >> /etc/sysctl.d/99-sysctl.conf
sudo chmod o-w /etc/sysctl.d/99-sysctl.conf
sudo touch /var/log/account/pacct
sudo accton on
sudo systemctl enable --now acct
sudo systemctl enable --now puppet
sudo systemctl enable --now auditd
sudo systemctl enable --now sysstat
sudo chmod o+w /etc/conf.d/sysstat
echo "" >> /etc/conf.d/sysstat && echo 'ENABLED="true"' >> /etc/conf.d/sysstat
sudo chmod o-w /etc/conf.d/sysstat
sudo chmod o+w /etc/bash.bashrc
echo "# Set umask." >> /etc/bash.bashrc
echo "umask 077" >> /etc/bash.bashrc
sudo chmod o-w /etc/bash.bashrc
sudo chmod o+w /etc/hosts
echo 127.0.0.1 localhost >> /etc/hosts
echo ::1 localhost ip6-localhost ip6-loopback >> /etc/hosts
echo ff02::1 ip6-allnodes >> /etc/hosts
echo ff02::2 ip6-allrouters >> /etc/hosts
echo 127.0.1.1 `hostname` >> /etc/hosts
echo 127.0.0.1 localhost >> /etc/hosts
echo ::1 localhost ip6-localhost ip6-loopback >> /etc/hosts
echo ff02::1 ip6-allnodes >> /etc/hosts
echo ff02::2 ip6-allrouters >> /etc/hosts
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

# Setup AppArmor.
sudo sed -i 's/#write-cache/write-cache'/g /etc/apparmor/parser.conf
sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"/GRUB_CMDLINE_LINUX_DEFAULT="nowatchdog nmi_watchdog=0 loglevel=3 lsm=landlock,lockdown,yama,integrity,apparmor,bpf"/g' /etc/default/grub && sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo systemctl enable --now apparmor

# Prettify Arch logo.
sudo sed -i 's/LOGO=archlinux-logo/LOGO=distributor-logo-arch-linux'/g /etc/os-release

# Hide menu entries.
sudo chmod o+w /usr/share/applications/bssh.desktop
echo Hidden=true >> /usr/share/applications/bssh.desktop
sudo chmod o-w /usr/share/applications/bssh.desktop
sudo chmod o+w /usr/share/applications/bvnc.desktop
echo Hidden=true >> /usr/share/applications/bvnc.desktop
sudo chmod o-w /usr/share/applications/bvnc.desktop
sudo chmod o+w /usr/share/applications/avahi-discover.desktop
echo Hidden=true >> /usr/share/applications/avahi-discover.desktop
sudo chmod o-w /usr/share/applications/avahi-discover.desktop
sudo chmod o+w /usr/share/applications/electron19.desktop
echo Hidden=true >> /usr/share/applications/electron19.desktop
sudo chmod o-w /usr/share/applications/electron19.desktop
sudo chmod o+w /usr/share/applications/org.kde.kuserfeedback-console.desktop
echo Hidden=true >> /usr/share/applications/org.kde.kuserfeedback-console.desktop
sudo chmod o-w /usr/share/applications/org.kde.kuserfeedback-console.desktop
sudo chmod o+w /usr/share/applications/qv4l2.desktop
echo Hidden=true >> /usr/share/applications/qv4l2.desktop
sudo chmod o-w /usr/share/applications/qv4l2.desktop
sudo chmod o+w /usr/share/applications/qvidcap.desktop
echo Hidden=true >> /usr/share/applications/qvidcap.desktop
sudo chmod o-w /usr/share/applications/qvidcap.desktop

# Setup Catppuccin theme for btop.
mkdir -p /home/$USER/.config/btop/themes
git clone https://github.com/catppuccin/btop.git
cd btop/themes && cp -v *.theme /home/$USER/.config/btop/themes/
cd && rm -rf btop

# Disable submenus in GRUB.
sudo sed -i 's/#GRUB_DISABLE_SUBMENU=y/GRUB_DISABLE_SUBMENU=y'/g /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Speed up systemd journal flush.
sudo sed -i 's/#Storage=auto/Storage=volatile'/g /etc/systemd/journald.conf
sudo sed -i 's/#SystemMaxFileSize/SystemMaxFileSize=20MB'/g /etc/systemd/journald.conf