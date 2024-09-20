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

# Checking to see if we're running as root.
if [ $(id -u) -ne 0 ]; then
    echo -e "${RED}Please run this setup script as root via 'su'! Thanks.${NC}"
    exit
fi

# Audio buzz/hum fix.
echo -e "${YELLOW}Applying audio buzz/hum fix...${NC}"
echo "options snd-hda-intel power_save=0 power_save_controller=N" >> /etc/modprobe.d/alsa-base.conf

# Configure XBPS to use the latest package versions.
echo -e "${GREEN}Configuring XBPS to use the latest package versions from the Void repositories...${NC}"
sed -i 's/#bestmatching=true/bestmatching=true/g' /usr/share/xbps.d/xbps.conf

# Add extra nonfree repo.
echo -e "${GREEN}Adding nonfree repo to system...${NC}"
xbps-install -S void-repo-nonfree -y

# Update OS.
echo -e "${GREEN}Updating OS packages...${NC}"
xbps-install -Suvy

# Install VPM (Void Package Management utility), XBPS user-friendly front-end.
echo -e "${GREEN}Installing the Void Package Management utility...${NC}"
xbps-install -S vpm -y

# Install Xorg server.
echo -e "${GREEN}Installing Xorg server...${NC}"
vpm install xorg-minimal xorg-input-drivers xorg-video-drivers xorg-fonts dbus-elogind dbus-elogind-x11 -y

# Install misc. utilities.
echo -e "${GREEN}Installing misc. utilities...${NC}"
vpm install dialog bc wget curl zsh xdg-user-dirs xdg-user-dirs-gtk xdg-utils xdg-desktop-portal lsd bat fd pfetch topgrade octoxbps make autoconf automake pkg-config gcc lynis flac vlc duf btop gufw ffmpegthumbs ntfs-3g void-updates void-release-keys fortune-mod-void unzip wl-clipboard qt5ct kvantum NetworkManager -y

echo -e "${YELLOW}Creating swapfile...${NC}"
./create_swapfile_void.sh

clear

# Enable printer support.
read -p "Do you want to enable printer support? (Y/n) " resp
resp=${resp:-Y}

if [ "$resp" = Y ] || [ "$resp" = y ]; then
    echo -e "${BLUE}Enabling printer support...${NC}"
    echo -e "${GREEN}Installing CUPS...${NC}"
    vpm install cups cups-filters cups-pdf system-config-printer system-config-printer-udev -y
    declare -a services=("cupsd" "cups-browsed")
    for service in "${services[@]}"; do
        ln -s "/etc/sv/$service" "/var/service/"
done

read -p "Do you want to install HPLIP for HP printer support? (Y/n) " resp
resp=${resp:-Y}
if [ "$resp" = Y ] || [ "$resp" = y ]; then
    vpm install hplip -y
else
    echo -e "${CYAN}Skipping HPLIP installation.${NC}"
fi
else
    echo -e "${CYAN}Skipping printer support.${NC}"
fi

# Install and configure fonts.
echo -e "${GREEN}Installing fonts...${NC}"
vpm install nerd-fonts source-sans-pro font-manjari noto-fonts-ttf noto-fonts-emoji font-material-design-icons-ttf ttf-ubuntu-font-family fonts-roboto-ttf ttfautohint -y
# Enable auto-hinting.
ln -s /usr/share/fontconfig/conf.avail/09-autohint-if-no-hinting.conf /etc/fonts/conf.d/
# Enable RGB sub-pixel rendering.
ln -s /usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/
# Configure nerd fonts for "lsd".
ln -s /usr/share/fontconfig/conf.avail/10-nerd-font-symbols.conf /etc/fonts/conf.d/

# Install the Poppins font.
echo -e "${YELLOW}Installing the Poppins font...${NC}"
mkdir -p /usr/share/fonts/Poppins
wget https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Black.ttf -P /usr/share/fonts/Poppins
wget https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-BlackItalic.ttf -P /usr/share/fonts/Poppins
wget https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Bold.ttf -P /usr/share/fonts/Poppins
wget https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-BoldItalic.ttf -P /usr/share/fonts/Poppins
wget https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-ExtraBold.ttf -P /usr/share/fonts/Poppins
wget https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-ExtraBoldItalic.ttf -P /usr/share/fonts/Poppins
wget https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-ExtraLight.ttf -P /usr/share/fonts/Poppins
wget https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-ExtraLightItalic.ttf -P /usr/share/fonts/Poppins
wget https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Italic.ttf -P /usr/share/fonts/Poppins
wget https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Light.ttf -P /usr/share/fonts/Poppins
wget https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-LightItalic.ttf -P /usr/share/fonts/Poppins
wget https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Medium.ttf -P /usr/share/fonts/Poppins
wget https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-MediumItalic.ttf -P /usr/share/fonts/Poppins
wget https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Regular.ttf -P /usr/share/fonts/Poppins
wget https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-SemiBold.ttf -P /usr/share/fonts/Poppins
wget https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-SemiBoldItalic.ttf -P /usr/share/fonts/Poppins
wget https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Thin.ttf -P /usr/share/fonts/Poppins
wget https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-ThinItalic.ttf -P /usr/share/fonts/Poppins

# Install KDE.
echo -e "${GREEN}Installing the KDE desktop...${NC}"
vpm install kde5 kde5-baseapps kaccounts-integration kaccounts-providers xdg-desktop-portal-kde k3b juk ark kdegraphics-thumbnailers oxygen-sounds oxygen-icons5 oxygen-gtk+3 print-manager plasma-firewall plasma-disks breeze krunner sddm -y

# Enable desktop services.
echo -e "${BLUE}Enabling desktop services...${NC}"
ln -s /etc/sv/dbus /var/service/
ln -s /etc/sv/NetworkManager /var/service/
ln -s /etc/sv/elogind /var/service/

# Install and configure PipeWire.
echo -e "${GREEN}Installing and configuring PipeWire...${NC}"
vpm install pipewire alsa-pipewire -y
mkdir -p /etc/pipewire/pipewire.conf.d
ln -s /usr/share/examples/wireplumber/10-wireplumber.conf /etc/pipewire/pipewire.conf.d/
ln -s /usr/share/examples/pipewire/20-pipewire-pulse.conf /etc/pipewire/pipewire.conf.d/
mkdir -p /etc/alsa/conf.d
ln -s /usr/share/alsa/alsa.conf.d/50-pipewire.conf /etc/alsa/conf.d/
ln -s /usr/share/alsa/alsa.conf.d/99-pipewire-default.conf /etc/alsa/conf.d/
ln -s /usr/share/applications/pipewire.desktop /etc/xdg/autostart/

# Install Newaita icons.
echo -e "${YELLOW}Installing the Newaita icon theme...${NC}"
cd && git clone https://github.com/cbrnix/Newaita.git
cp -r Newaita/Newaita /usr/share/icons
cd && rm -rf Newaita

# Install grub theme.
echo -e "${YELLOW}Installing the GRUB theme...${NC}"
cd && git clone https://github.com/vinceliuice/grub2-themes.git
cd grub2-themes && ./install.sh -t stylish
echo "GRUB_DISABLE_SUBMENU=y" >> /etc/default/grub
cd && rm -rf grub2-themes

# Configure lynis.
echo -e "${YELLOW}Configuring lynis...${NC}"
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

# Secure the OS.
echo -e "${GREEN}Securing the OS...${NC}"
sed -i 's/UMASK=0022/UMASK=0077/g' /etc/default/sysstat
vpm install sysstat rkhunter chkrootkit apparmor rsyslog audit acct -y

# Enable services.
echo -e "${BLUE}Enabling system services..."
ln -s /etc/sv/rsyslogd /var/service/
ln -s /etc/sv/auditd /var/service/
ln -s /etc/sv/ufw /var/service/

# Disable and stop sshd. Not needed on a personal desktop PC/laptop.
echo -e "${YELLOW}Disabling and stopping sshd. Not needed on a personal desktop PC/laptop.${NC}"
sv down sshd
rm /var/service/sshd
touch /etc/sv/sshd/down

# Enable process accounting.
echo -e "${YELLOW}Enabling process accounting...${NC}"
mkdir -p /var/log/account
touch /var/log/account/pacct
accton on

# Set permissions for sensitive files.
echo -e "${BLUE}Setting permissions for sensitive files...${NC}"
chmod og-rwx /boot/grub/grub.cfg
chmod og-rwx /etc/ssh/sshd_config
chmod og-rwx /etc/cron.daily
chmod og-rwx /etc/cron.hourly

# Configure sysctl.conf
echo -e "${BLUE}Configuring sysctl.conf...${NC}"
cat << EOF >> /etc/sysctl.conf
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
sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding no/' /etc/ssh/sshd_config
sed -i 's/#ClientAliveCountMax 3/ClientAliveCountMax 2/' /etc/ssh/sshd_config
sed -i 's/#Compression delayed/Compression no/' /etc/ssh/sshd_config
sed -i 's/#LogLevel INFO/LogLevel VERBOSE/' /etc/ssh/sshd_config
sed -i 's/#MaxAuthTries 6/MaxAuthTries 3/' /etc/ssh/sshd_config
sed -i 's/#MaxSessions 10/MaxSessions 2/' /etc/ssh/sshd_config
sed -i 's/#TCPKeepAlive yes/TCPKeepAlive no/' /etc/ssh/sshd_config
sed -i 's/#AllowAgentForwarding yes/AllowAgentForwarding no/' /etc/ssh/sshd_config

# Configure plymouth boot splash.
echo -e "${GREEN}Installing and configuring Plymouth...${NC}"
vpm install plymouth -y
plymouth-set-default-theme -R solar

# Download Konsole colors.
echo -e "${YELLOW}Downloading Konsole colors...${NC}"
mkdir -p /home/$USER/.local/share/konsole/
mkdir -p /etc/skel/.local/share/konsole/
curl https://raw.githubusercontent.com/sonph/onehalf/master/konsole/onehalf-dark.colorscheme -o /home/$USER/onehalf-dark.colorscheme
cp -v /home/$USER/onehalf-dark.colorscheme /home/$USER/.local/share/konsole/
cp -v /home/$USER/onehalf-dark.colorscheme /etc/skel/.local/share/konsole/
chown -R $USER:$USER /home/$USER/.local
rm -r /home/$USER/onehalf-dark.colorscheme

# Ask the user if they want to enable Flatpak support.
read -p "Do you want to enable Flatpak support? (Y/n) " resp
resp=${flatpak_resp:-Y}

if [ "$resp" = Y ] || [ "$resp" = y ]; then
    echo -e "${GREEN}Enabling Flatpak support...${NC}"
    vpm install flatpak -y
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    flatpak install -y runtime/org.gtk.Gtk3theme.Breeze/x86_64/3.22

# Ask the user if they want to install the Brave web browser.
read -p "Do you want to install the Brave web browser? Flatpak support is required and *WILL* be installed if you answered no to enabling Flakpak support. (Y/n) " resp
resp=${resp:-Y}

if [ "$resp" = Y ] || [ "$resp" = y ]; then
    echo -e "${GREEN}Enabling Flatpak support...${NC}"
    vpm install flatpak -y
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    flatpak install -y runtime/org.gtk.Gtk3theme.Breeze/x86_64/3.22
    echo -e "${MAGENTA}Installing Brave...${NC}"
    flatpak install -y com.brave.Browser
else
    echo -e "${CYAN}Skipping Brave browser installation.${NC}"
fi

# Ask the user if they want to install Pinta.
read -p "Do you want to install the Pinta image editor? (Y/n) " resp
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

# Update environment variables.
# Configure pfetch.
echo "PF_INFO=\"ascii os kernel uptime pkgs shell editor de\"" >> /etc/environment
# Set BROWSER variable.
echo "BROWSER=brave" >> /etc/environment
# Set EDITOR variable.
echo "EDITOR=micro" >> /etc/environment
# Set MICRO_TRUECOLOR variable to 1 to enable truecolor support for the micro text editor.
echo "MICRO_TRUECOLOR=1" >> /etc/environment
# Enable QT5 apps to use Kvantum theming engine.
echo QT_QPA_PLATFORMTHEME=qt5ct >> /etc/environment

# Download wallpapers.
./wallpapers.sh

echo -e "${BLUE}Void Linux post-install setup complete. Don't forget to enable SDDM by changing back into this directory and typing: "./enable-sddm-void.sh" after you reboot.${NC}"
