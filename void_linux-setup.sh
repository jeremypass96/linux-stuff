#!/bin/bash
# Void Linux post-install setup script. For use with a Void Linux base install.

# Define color codes
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m' # No color

# Audio buzz/hum fix.
echo -e "${YELLOW}Applying audio buzz/hum fix...${NC}"
echo "options snd-hda-intel power_save=0 power_save_controller=N" | sudo tee -a /etc/modprobe.d/alsa-base.conf > /dev/null

# Configure XBPS to use the latest package versions.
echo -e "${GREEN}Configuring XBPS to use the latest package versions from the Void repositories...${NC}"
sudo sed -i 's/#bestmatching=true/bestmatching=true/g' /usr/share/xbps.d/xbps.conf

# Add extra nonfree repo.
echo -e "${GREEN}Adding nonfree repo to system...${NC}"
sudo xbps-install -S void-repo-nonfree -y

# Update OS.
echo -e "${GREEN}Updating OS packages...${NC}"
sudo xbps-install -Suvy

# Install VPM (Void Package Management utility), XBPS user-friendly front-end.
echo -e "${GREEN}Installing the Void Package Management utility...${NC}"
sudo xbps-install -S vpm -y

# Install Xorg server.
echo -e "${GREEN}Installing Xorg server...${NC}"
sudo vpm install xorg-minimal xorg-input-drivers xorg-video-drivers xorg-fonts dbus-elogind dbus-elogind-x11 -y

# Install misc. utilities.
echo -e "${GREEN}Installing misc. utilities...${NC}"
sudo vpm install dialog bc wget curl zsh xdg-user-dirs xdg-user-dirs-gtk xdg-utils xdg-desktop-portal lsd bat fd fastfetch topgrade octoxbps make autoconf automake pkg-config gcc lynis flac vlc duf btop gufw ffmpegthumbs ntfs-3g void-updates void-release-keys fortune-mod-void unzip wl-clipboard qt5ct kvantum NetworkManager -y
echo -e "${YELLOW}Creating swapfile...${NC}"
sudo ./create_swapfile_void.sh

clear

# Enable printer support.
read -rp "Do you want to enable printer support? (Y/n) " printer_resp
printer_resp=${printer_resp:-Y}

if [[ "$printer_resp" =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}Enabling printer support...${NC}"
    echo -e "${GREEN}Installing CUPS...${NC}"
    sudo vpm install cups cups-filters cups-pdf system-config-printer system-config-printer-udev -y

    # Enable CUPS services
    services=("cupsd" "cups-browsed")
    for service in "${services[@]}"; do
        sudo ln -s "/etc/sv/$service" "/var/service/"
    done

    read -rp "Do you want to install HPLIP for HP printer support? (Y/n) " hplip_resp
    hplip_resp=${hplip_resp:-Y}
    if [[ "$hplip_resp" =~ ^[Yy]$ ]]; then
        sudo vpm install hplip -y
    else
        echo -e "${CYAN}Skipping HPLIP installation.${NC}"
    fi
else
    echo -e "${CYAN}Skipping printer support.${NC}"
fi

# Install and configure fonts.
echo -e "${GREEN}Installing fonts...${NC}"
sudo vpm install nerd-fonts source-sans-pro font-manjari noto-fonts-ttf noto-fonts-emoji font-material-design-icons-ttf ttf-ubuntu-font-family fonts-roboto-ttf ttfautohint -y
# Enable auto-hinting.
sudo ln -s /usr/share/fontconfig/conf.avail/09-autohint-if-no-hinting.conf /etc/fonts/conf.d/
# Enable RGB sub-pixel rendering.
sudo ln -s /usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/
# Configure nerd fonts for "lsd".
sudo ln -s /usr/share/fontconfig/conf.avail/10-nerd-font-symbols.conf /etc/fonts/conf.d/

# Install the Poppins font.
echo -e "${YELLOW}Installing the Poppins font...${NC}"
mkdir -p /usr/share/fonts/Poppins
sudo wget https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Black.ttf -P /usr/share/fonts/Poppins
sudo wget https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-BlackItalic.ttf -P /usr/share/fonts/Poppins
sudo wget https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Bold.ttf -P /usr/share/fonts/Poppins
sudo wget https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-BoldItalic.ttf -P /usr/share/fonts/Poppins
sudo wget https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-ExtraBold.ttf -P /usr/share/fonts/Poppins
sudo wget https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-ExtraBoldItalic.ttf -P /usr/share/fonts/Poppins
sudo wget https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-ExtraLight.ttf -P /usr/share/fonts/Poppins
sudo wget https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-ExtraLightItalic.ttf -P /usr/share/fonts/Poppins
sudo wget https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Italic.ttf -P /usr/share/fonts/Poppins
sudo wget https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Light.ttf -P /usr/share/fonts/Poppins
sudo wget https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-LightItalic.ttf -P /usr/share/fonts/Poppins
sudo wget https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Medium.ttf -P /usr/share/fonts/Poppins
sudo wget https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-MediumItalic.ttf -P /usr/share/fonts/Poppins
sudo wget https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Regular.ttf -P /usr/share/fonts/Poppins
sudo wget https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-SemiBold.ttf -P /usr/share/fonts/Poppins
sudo wget https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-SemiBoldItalic.ttf -P /usr/share/fonts/Poppins
sudo wget https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Thin.ttf -P /usr/share/fonts/Poppins
sudo wget https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-ThinItalic.ttf -P /usr/share/fonts/Poppins

# Install KDE.
echo -e "${GREEN}Installing the KDE desktop...${NC}"
sudo vpm install kde5 kde5-baseapps kaccounts-integration kaccounts-providers xdg-desktop-portal-kde k3b juk ark kdegraphics-thumbnailers oxygen-sounds oxygen-icons5 oxygen-gtk+3 print-manager plasma-firewall plasma-disks breeze krunner sddm -y

# Enable desktop services.
echo -e "${BLUE}Enabling desktop services...${NC}"
sudo ln -s /etc/sv/dbus /var/service/
sudo ln -s /etc/sv/NetworkManager /var/service/
sudo ln -s /etc/sv/elogind /var/service/

# Install and configure PipeWire.
echo -e "${GREEN}Installing and configuring PipeWire...${NC}"
sudo vpm install pipewire alsa-pipewire -y
mkdir -p /etc/pipewire/pipewire.conf.d
sudo ln -s /usr/share/examples/wireplumber/10-wireplumber.conf /etc/pipewire/pipewire.conf.d/
sudo ln -s /usr/share/examples/pipewire/20-pipewire-pulse.conf /etc/pipewire/pipewire.conf.d/
mkdir -p /etc/alsa/conf.d
sudo ln -s /usr/share/alsa/alsa.conf.d/50-pipewire.conf /etc/alsa/conf.d/
sudo ln -s /usr/share/alsa/alsa.conf.d/99-pipewire-default.conf /etc/alsa/conf.d/
sudo ln -s /usr/share/applications/pipewire.desktop /etc/xdg/autostart/

# Install Papirus icons.
echo -e "${YELLOW}Installing the Papirus icon theme...${NC}"
sudo sudo vpm install papirus-icon-theme -y

# Install grub theme.
echo -e "${YELLOW}Installing the GRUB theme...${NC}"
cd && git clone https://github.com/vinceliuice/grub2-themes.git
cd grub2-themes && sudo ./install.sh -t stylish
echo "GRUB_DISABLE_SUBMENU=y" | sudo tee -a /etc/default/grub > /dev/null
cd && rm -rf grub2-themes

# Configure lynis.
echo -e "${YELLOW}Configuring lynis...${NC}"
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
echo -e "${GREEN}Securing the OS...${NC}"
sudo sed -i 's/UMASK=0022/UMASK=0077/g' /etc/default/sysstat
sudo vpm install sysstat rkhunter chkrootkit apparmor rsyslog audit acct -y

# Enable services.
echo -e "${BLUE}Enabling system services..."
sudo sudo ln -s /etc/sv/rsyslogd /var/service/
sudo sudo ln -s /etc/sv/auditd /var/service/
sudo sudo ln -s /etc/sv/ufw /var/service/

# Disable and stop sshd. Not needed on a personal desktop PC/laptop.
echo -e "${YELLOW}Disabling and stopping sshd. Not needed on a personal desktop PC/laptop.${NC}"
sudo sv down sshd
sudo rm /var/service/sshd
sudo touch /etc/sv/sshd/down

# Enable process accounting.
echo -e "${YELLOW}Enabling process accounting...${NC}"
sudo mkdir -p /var/log/account
sudo touch /var/log/account/pacct
accton on

# Set permissions for sensitive files.
echo -e "${BLUE}Setting permissions for sensitive files...${NC}"
sudo chmod og-rwx /boot/grub/grub.cfg
sudo chmod og-rwx /etc/ssh/sshd_config
sudo chmod og-rwx /etc/cron.daily
sudo chmod og-rwx /etc/cron.hourly

# Configure sysctl.conf
echo -e "${BLUE}Configuring sysctl.conf...${NC}"
sudo tee -a /etc/sysctl.conf > /dev/null << EOF
dev.tty.ldisc_autoload = 0
fs.protected_fifos = 2
fs.protected_regular = 2
kernel.kptr_restrict = 2
kernel.perf_event_paranoid = 3
kernel.sysrq = 0
net.core.bpf_jit_harden = 2
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.default.log_martians = 1
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
EOF

# Configure sshd_config
echo -e "${BLUE}Configuring sshd_config...${NC}"
sudo sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding no/' /etc/ssh/sshd_config
sudo sed -i 's/#ClientAliveCountMax 3/ClientAliveCountMax 2/' /etc/ssh/sshd_config
sudo sed -i 's/#Compression delayed/Compression no/' /etc/ssh/sshd_config
sudo sed -i 's/#LogLevel INFO/LogLevel VERBOSE/' /etc/ssh/sshd_config
sudo sed -i 's/#MaxAuthTries 6/MaxAuthTries 3/' /etc/ssh/sshd_config
sudo sed -i 's/#MaxSessions 10/MaxSessions 2/' /etc/ssh/sshd_config
sudo sed -i 's/#TCPKeepAlive yes/TCPKeepAlive no/' /etc/ssh/sshd_config
sudo sed -i 's/#AllowAgentForwarding yes/AllowAgentForwarding no/' /etc/ssh/sshd_config

# Configure plymouth boot splash.
echo -e "${GREEN}Installing and configuring Plymouth...${NC}"
sudo sudo vpm install plymouth -y
plymouth-set-default-theme -R solar

# Download Konsole colors.
echo -e "${YELLOW}Downloading Konsole colors...${NC}"
dialog --title "Konsole Colorscheme" --menu "Which Konsole colorscheme do you want?" 12 40 12 \
1 "Catppuccin" \
2 "OneHalf-Dark" \
3 "Ayu Mirage" 2> /tmp/konsole_resp
konsole_resp=$(cat /tmp/konsole_resp)
if [ "$konsole_resp" = 1 ]; then
    curl --parallel https://raw.githubusercontent.com/catppuccin/konsole/refs/heads/main/themes/catppuccin-frappe.colorscheme -o catppuccin-frappe.colorscheme https://raw.githubusercontent.com/catppuccin/konsole/refs/heads/main/themes/catppuccin-latte.colorscheme -o catppuccin-latte.colorscheme https://raw.githubusercontent.com/catppuccin/konsole/refs/heads/main/themes/catppuccin-macchiato.colorscheme -o catppuccin-macchiato.colorscheme https://raw.githubusercontent.com/catppuccin/konsole/refs/heads/main/themes/catppuccin-mocha.colorscheme -o catppuccin-mocha.colorscheme
	sudo mkdir -p /usr/share/konsole
 	sudo chmod 755 /usr/share/konsole
	sudo mv *.colorscheme /usr/share/konsole
 	sudo chmod 644 /usr/share/konsole/*.colorscheme
elif [ "$konsole_resp" = 2 ]; then
    curl https://raw.githubusercontent.com/sonph/onehalf/master/konsole/onehalf-dark.colorscheme -o onehalf-dark.colorscheme
	sudo mkdir -p /usr/share/konsole
 	sudo chmod 755 /usr/share/konsole
	sudo mv onehalf-dark.colorscheme /usr/share/konsole
 	sudo chmod 644 /usr/share/konsole/onehalf-dark.colorscheme
elif [ "$konsole_resp" = 3 ]; then
    curl https://raw.githubusercontent.com/mbadolato/iTerm2-Color-Schemes/refs/heads/master/konsole/Ayu%20Mirage.colorscheme -o AyuMirage.colorscheme
	sudo mkdir -p /usr/share/konsole
 	sudo chmod 755 /usr/share/konsole
	sudo mv AyuMirage.colorscheme /usr/share/konsole
 	sudo chmod 644 /usr/share/konsole/AyuMirage.colorscheme
fi

# Ask the user if they want to enable Flatpak support.
read -rp "Do you want to enable Flatpak support? (Y/n) " resp
resp=${resp:-Y}

if [ "$resp" = Y ] || [ "$resp" = y ]; then
    echo -e "${GREEN}Enabling Flatpak support...${NC}"
    sudo vpm install flatpak -y
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    flatpak install -y runtime/org.gtk.Gtk3theme.Breeze/x86_64/3.22

# Ask the user if they want to install the Brave web browser.
read -rp "Do you want to install the Brave web browser? Flatpak support is required and *WILL* be installed if you answered no to enabling Flakpak support. (Y/n) " resp
resp=${resp:-Y}

if [ "$resp" = Y ] || [ "$resp" = y ]; then
    echo -e "${GREEN}Enabling Flatpak support...${NC}"
    sudo vpm install flatpak -y
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    flatpak install -y runtime/org.gtk.Gtk3theme.Breeze/x86_64/3.22
    echo -e "${MAGENTA}Installing Brave...${NC}"
    flatpak install -y com.brave.Browser
else
    echo -e "${CYAN}Skipping Brave browser installation.${NC}"
fi

# Ask the user if they want to install Pinta.
read -rp "Do you want to install the Pinta image editor? (Y/n) " resp
resp=${resp:-Y}

if [ "$resp" = Y ] || [ "$resp" = y ]; then
    echo -e "${MAGENTA}Installing Pinta image editor...${NC}"
    flatpak install -y app/com.github.PintaProject.Pinta/x86_64/stable
else
    echo -e "${CYAN}Skipping Pinta installation.${NC}"
fi
else
    echo "${CYAN}Skipping Flatpak setup.${NC}"
fi

# Ask the user if they want to install VSCodium.
read -rp "Do you want to install VSCodium? (Y/n) " resp
resp=${resp:-Y}

if [ "$resp" = Y ] || [ "$resp" = y ]; then
    echo -e "${MAGENTA}Installing VSCodium...${NC}"
    flatpak install -y com.vscodium.codium
    mkdir -p "$HOME"/.var/app/com.vscodium.codium/config/VSCodium/User && cp -v "$HOME"/linux-stuff/Dotfiles/config/VSCodium/User/settings.json "$HOME"/.var/app/com.vscodium.codium/config/VSCodium/User/settings.json
    flatpak run com.vscodium.codium --install-extension qyurila.ayu-midas
    flatpak run com.vscodium.codium --install-extension jeff-hykin.better-shellscript-syntax
    flatpak run com.vscodium.codium --install-extension file-icons.file-icons
    flatpak run com.vscodium.codium --install-extension miguelsolorio.fluent-icons
else
    echo -e "${CYAN}Skipping VSCodium installation.${NC}"
fi

# Ask the user if they want to install Audacity.
read -rp "Do you want to install Audacity? (Y/n) " resp
resp=${resp:-Y}

if [ "$resp" = Y ] || [ "$resp" = y ]; then
    echo -e "${MAGENTA}Installing Audacity...${NC}"
    flatpak install -y org.audacityteam.Audacity
else
    echo -e "${CYAN}Skipping Audacity installation.${NC}"
fi

# Ask the user if they want to install Spotify.
read -rp "Do you want to install Spotify? (Y/n) " resp
resp=${resp:-Y}

if [ "$resp" = Y ] || [ "$resp" = y ]; then
    echo -e "${MAGENTA}Installing Spotify...${NC}"
    flatpak install -y com.spotify.Client
else
    echo -e "${CYAN}Skipping Spotify installation.${NC}"
fi

# Update environment variables.
# Set BROWSER variable.
echo 'BROWSER=brave' | sudo tee -a /etc/environment > /dev/null
# Set EDITOR variable.
echo 'EDITOR=vim' | sudo tee -a /etc/environment > /dev/null
# Enable VSCodium to use QT file dialogs by default instead of GTK.
echo 'GTK_USE_PORTAL=1' | sudo tee -a /etc/environment > /dev/null
# Enable QT5 apps to use Kvantum theming engine.
echo 'QT_QPA_PLATFORMTHEME=qt5ct' | sudo tee -a /etc/environment > /dev/null

# Download wallpapers.
"$HOME"/./linux-stuff/wallpapers.sh

# Run various setup scripts.
"$HOME"/./linux-stuff/zsh-setup.sh
"$HOME"/./linux-stuff/bat-setup.sh
"$HOME"/./linux-stuff/fastfetch-setup.sh
"$HOME"/./linux-stuff/vim_setup.sh
"$HOME"/./linux-stuff/lsd-setup.sh

echo -e "${BLUE}Void Linux post-install setup complete. Don't forget to enable SDDM by changing back into this directory and typing: "./enable-sddm-void.sh" after you reboot.${NC}"