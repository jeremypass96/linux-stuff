#!/bin/bash
# This script cleans up and configures an Artix Linux KDE install with OpenRC. Run as a normal user!

# Audio buzz/hum fix.
sudo touch /etc/modprobe.d/alsa-base.conf && sudo chmod o+w /etc/modprobe.d/alsa-base.conf
echo "options snd-hda-intel power_save=0 power_save_controller=N" > /etc/modprobe.d/alsa-base.conf
sudo chmod o-w /etc/modprobe.d/alsa-base.conf

# Tweak pacman for sane defaults.
sudo sed -i 's/#UseSyslog/UseSyslog'/g /etc/pacman.conf
sudo sed -i 's/#Color/Color'/g /etc/pacman.conf
sudo sed -i 's/'"#ParallelDownloads = 5"'/'"ParallelDownloads = 15"''/g /etc/pacman.conf
sudo sed -i '/ParallelDownloads = 15/ a\ILoveCandy\' /etc/pacman.conf

# Install wget to fetch "blackpac" script.
sudo pacman -S wget --noconfirm

# Setup "blackpac" script. Shell script utility that enables you to backlist packages.
# Download script.
cd && wget http://downloads.sourceforge.net/project/ig-scripts/blackpac-1.0.1.sh
# Make script executable.
chmod +x blackpac-1.0.1.sh
# Install script.
sudo install blackpac-1.0.1.sh /usr/local/bin/
sudo mv /usr/local/bin/blackpac-1.0.1.sh /usr/local/bin/blackpac
rm blackpac-1.0.1.sh
# Blacklist and remvove packages.
sudo blackpac --blacklist qt5-tools
sudo pacman -R qt5-tools --noconfirm

# Install and use better NTP daemon.
sudo pacman -Rsu ntp-openrc && sudo pacman -S chrony chrony-openrc --noconfirm
sudo sed -i 's/! server 0.arch.pool.ntp.org iburst/server 0.arch.pool.ntp.org iburst'/g /etc/chrony.conf
sudo sed -i 's/! server 1.arch.pool.ntp.org iburst/server 1.arch.pool.ntp.org iburst'/g /etc/chrony.conf
sudo sed -i 's/! server 3.arch.pool.ntp.org iburst/server 3.arch.pool.ntp.org iburst'/g /etc/chrony.conf
sudo rc-update add chrony && sudo rc-service chrony start
sudo chronyc online

# Remove unneeded packages.
sudo pacman -Rsu nano kate falkon konqueror mpv kgpg ktimer plasma-sdk --noconfirm

# Install ffmpegthumbs, for video file thumbnail support in Dolphin.
sudo pacman -S ffmpegthumbs --noconfirm

# Install thumbnail support for PDF files.
sudo pacman -S kdegraphics-thumbnailers --noconfirm

# Install some KDE utilities.
sudo pacman -S kcharselect kaccounts-providers kio-gdrive --noconfirm

# Install some core utilities that didn't get installed, for some reason.
sudo pacman -S cracklib hddtemp --noconfirm

# Install the micro text editor.
sudo pacman -S micro xclip --noconfirm

# Install spell checking support.
sudo pacman -S aspell aspell-en --noconfirm

# Install yay AUR helper.
# Download and extract tarball.
cd && curl https://aur.archlinux.org/cgit/aur.git/snapshot/yay-bin.tar.gz -o yay-bin.tar.gz
tar -xvf yay-bin.tar.gz
# Install yay.
cd yay-bin
makepkg -sic --noconfirm
# Clean up.
cd && rm -rf yay-bin && rm -rf yay-bin.tar.gz
# Configure yay options.
yay --editor /usr/bin/micro --answerclean A --answerupgrade Y --nodiffmenu --noeditmenu --removemake --cleanafter --devel --useask --combinedupgrade --batchinstall --sudoloop --save

# Install some command-line utilities not in the main repo.
yay -S duf-git bat-cat-git fd-git lynis-git btop-git --noconfirm

# Install Konsole color scheme.
yay -S catppuccin-konsole-theme-git --noconfirm

# Install icon, cursor, and KDE theme.
sudo yay -S newaita-icons-git bibata-cursor-theme-bin vimix-theme-kde-git kvantum --noconfirm

# Install and configure printing support.
yay -S hplip-lite system-config-printer cups-pk-helper gutenprint foomatic-db-gutenprint-ppds tesseract-data-eng skanpage --noconfirm
sudo rc-service cupsd restart

# Install PolKit rules for desktop privileges. Enables automounting, suspend and hibernation, and CPU frequency settings.
yay -S desktop-privileges --noconfirm

# Install Brave web browser.
yay -S brave-bin --noconfirm

# Install fonts.
yay -S ttf-poppins adobe-source-sans-fonts ttf-ibm-plex ttf-ms-fonts ttf-material-design-icons-desktop-git ttf-material-design-icons ttf-material-design-icons-git noto-fonts-emoji ttf-nerd-fonts-symbols-2048-em --noconfirm
sudo ln -s /usr/share/fontconfig/conf.avail/09-autohint-if-no-hinting.conf /etc/fonts/conf.d

# Configure nerd fonts for "lsd".
sudo ln -s /usr/share/fontconfig/conf.avail/10-nerd-font-symbols.conf /etc/fonts/conf.d/

# Install "lsd," a better replacement for ls.
yay -S lsd --noconfirm

# Install topgrade.
yay -S topgrade-bin --noconfirm

# Install pfetch.
yay -S pfetch --noconfirm

# Install Pamac, GUI frontend to install software.
yay -S pamac-aur pamac-tray-icon-plasma --noconfirm

# Install and configure VSCodium.
yay -S vscodium-bin vscodium-bin-marketplace --noconfirm
mkdir -p /home/$USER/.config/VSCodium/User && cp -v /home/$USER/linux-stuff/Dotfiles/config/VSCodium/User/settings.json /home/$USER/.config/VSCodium/User/settings.json
vscodium --install-extension PKief.material-icon-theme
vscodium --install-extension BeardedBear.beardedtheme
vscodium --install-extension jeff-hykin.better-shellscript-syntax

# Install grub theme and disable OS prober.
yay -S grub-theme-stylish-color-1080p-git --noconfirm
sudo sed -i 's|GRUB_THEME="/usr/share/grub/themes/artix/theme.txt"|GRUB_THEME="/usr/share/grub/themes/stylish-color-1080p/theme.txt"|g' /etc/default/grub
sudo sed -i 's/GRUB_DISABLE_OS_PROBER="false"/GRUB_DISABLE_OS_PROBER="true"/g' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Install Wine.
yay -S wine-installer wine-gecko wine-mono --noconfirm

# Install some useful software.
yay -S unrar vlc transmission-qt pinta-gtk3-git audacity k3b p7zip clipgrab partitionmanager --noconfirm

# Install balenaEtcher to write OS images to USB flash drives.
yay -S balena-etcher --noconfirm

# Install mp3tag.
yay -S mp3tag --noconfirm

# Install dependencies for k3b.
yay -S cdrtools dvd+rw-tools transcode cdrdao sox normalize --noconfirm

# Install some KDE games!
sudo pacman -S kapman kblocks kbounce kbreakout kmines knetwalk kpat kreversi --noconfirm

# Install Spotify.
yay -S spotify --noconfirm

# Install KDE Connect.
sudo pacman -S kdeconnect --noconfirm

# Install gufw firewall and enable the OpenRC service.
sudo pacman -S gufw ufw-openrc --noconfirm
sudo rc-update add ufw && sudo ufw enable && sudo rc-service ufw start

# Install some useful pacman post-transaction hooks.
yay -S pacman-cleanup-hook grub-hook sync-pacman-hook-git remove-orphaned-kernels pacman-log-orphans-hook --noconfirm

# Setup config files and stuff.
cd linux-stuff/
./bat-setup.sh
./lsd-setup.sh
./micro-setup.sh

# Configure Zsh.
yay -S oh-my-zsh-git oh-my-zsh-plugin-syntax-highlighting oh-my-zsh-plugin-autosuggestions --noconfirm
cp /usr/share/oh-my-zsh/zshrc /home/$USER/.zshrc
sed -i s/ZSH_THEME='"robbyrussell"'/ZSH_THEME='"gentoo"'/g /home/$USER/.zshrc
sed -i 's/# HYPHEN_INSENSITIVE="true"/HYPHEN_INSENSITIVE="true"/g' /home/$USER/.zshrc
sed -i 's/'"# zstyle ':omz:update' mode disabled"'/'"zstyle ':omz:update' mode disabled"''/g /home/$USER/.zshrc
sed -i 's/# ENABLE_CORRECTION="true"/ENABLE_CORRECTION="true"/g' /home/$USER/.zshrc
sed -i 's/# COMPLETION_WAITING_DOTS="true"/COMPLETION_WAITING_DOTS="true"/g' /home/$USER/.zshrc
sed -i 's|# HIST_STAMPS="mm/dd/yyyy"|HIST_STAMPS="mm/dd/yyyy"|g' /home/$USER/.zshrc
sed -i 's/'"plugins=(git)/plugins=(git colored-man-pages safe-paste sudo copypath zsh-autosuggestions zsh-syntax-highlighting)"'/g' /home/$USER/.zshrc
echo alias ls='"lsd"' >> /home/$USER/.zshrc
echo alias cat='"bat"' >> /home/$USER/.zshrc
echo pfetch >> /home/$USER/.zshrc
cd
sudo cp -v /home/$USER/.zshrc /etc/skel/.zshrc
sudo cp -v /etc/skel/.zshrc /root/.zshrc

# Remove unneeded dependencies.
yay -c --noconfirm

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
yay -S mkinitcpio-firmware --noconfirm

# Stop mkinitcpio from generating a fallback kernel image.
echo "Stopping mkinitcpio from generating a fallback kernel image..."
if [ $(uname -r | grep artix) ]; then
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

# Secure the OS.
sudo pacman -S audit-openrc apparmor apparmor-openrc puppet --noconfirm
sudo rc-update add auditd && sudo rc-service auditd start
yay -S acct chkrootkit aide --noconfirm
sudo chmod og-rwx /boot/grub/grub.cfg
sudo chmod og-rwx /etc/ssh/sshd_config
sudo sed -i 's/umask 022/umask 077'/g /etc/profile
sudo touch /etc/sysctl.d/90-sysctl.conf
sudo chmod o+w /etc/sysctl.d/90-sysctl.conf
echo "dev.tty.ldisc_autoload = 0" >> /etc/sysctl.d/90-sysctl.conf
echo "fs.protected_fifos = 2" >> /etc/sysctl.d/90-sysctl.conf
echo "fs.protected_regular = 2" >> /etc/sysctl.d/90-sysctl.conf
echo "fs.suid_dumpable = 0" >> /etc/sysctl.d/90-sysctl.conf
echo "kernel.sysrq = 0" >> /etc/sysctl.d/90-sysctl.conf
echo "kernel.unprivileged_bpf_disabled = 1" >> /etc/sysctl.d/90-sysctl.conf
echo "net.ipv4.conf.all.log_martians = 1" >> /etc/sysctl.d/90-sysctl.conf
echo "net.ipv4.conf.all.send_redirects = 0" >> /etc/sysctl.d/90-sysctl.conf
echo "net.ipv4.conf.default.log_martians = 1" >> /etc/sysctl.d/90-sysctl.conf
sudo chmod o-w /etc/sysctl.d/90-sysctl.conf
sudo touch /var/log/account/pacct
sudo accton on
sudo sed -i 's/#write-cache/write-cache'/g /etc/apparmor/parser.conf
sudo rc-update add auditd && sudo rc-service auditd start
sudo chmod o+w /etc/bash.bashrc
echo "# Set umask." >> /etc/bash.bashrc
echo "umask 077" >> /etc/bash.bashrc
sudo chmod o-w /etc/bash.bashrc
sudo chmod o+w /etc/hosts
echo 127.0.0.1 localhost >> /etc/hosts
echo "::1 localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters" >> /etc/hosts
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
sudo rc-update add apparmor
sudo sed -i 's/#write-cache/write-cache'/g /etc/apparmor/parser.conf
sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/GRUB_CMDLINE_LINUX_DEFAULT="quiet lsm=landlock,lockdown,yama,integrity,apparmor,bpf"/g' /etc/default/grub && sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo rc-service apparmor start

#### Update AIDE database.
sudo sed -i 's|database_out=file:@@{DBDIR}/aide.db.new.gz|database_out=file:@@{DBDIR}/aide.db.gz|g' /etc/aide.conf && sudo aide -i
sudo sed -i 's|database_out=file:@@{DBDIR}/aide.db.gz|database_out=file:@@{DBDIR}/aide.db.new.gz|g' /etc/aide.conf && sudo aide -u
####

# Prettify Arch logo.
sudo sed -i 's/LOGO=archlinux-logo/LOGO=distributor-logo-arch-linux'/g /etc/os-release