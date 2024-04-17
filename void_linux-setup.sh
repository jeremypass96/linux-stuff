#!/bin/bash
# Void Linux post-install setup script. For use with a Void Linux base install.

# Checking to see if we're running as root.
if [ $(id -u) -ne 0 ]; then
    echo "Please run this setup script as root via 'su'! Thanks."
    exit
fi

# Audio buzz/hum fix.
echo "options snd-hda-intel power_save=0 power_save_controller=N" >> /etc/modprobe.d/alsa-base.conf

# Configure XBPS to use the latest package versions.
sed -i 's/#bestmatching=true/bestmatching=true/g' /usr/share/xbps.d/xbps.conf

# Add extra nonfree repo.
echo "Adding nonfree repo to system..."
xbps-install -S void-repo-nonfree -y

# Update OS.
echo "Updating OS packages..."
xbps-install -Suvy

# Install VPM (Void Package Management utility), XBPS user-friendly front-end.
echo "Installing the Void Package Management utility..."
xbps-install -S vpm -y

# Install Xorg server.
echo "Installing Xorg server..."
vpm install xorg-minimal xorg-input-drivers xorg-video-drivers xorg-fonts dbus-elogind dbus-elogind-x11 -y

# Install misc. utilities.
echo "Installing misc. utilities..."
vpm install wget curl zsh xdg-user-dirs xdg-user-dirs-gtk xdg-utils xdg-desktop-portal lsd bat fd pfetch topgrade octoxbps micro make autoconf automake pkg-config gcc lynis neofetch flac vlc duf btop gufw ffmpegthumbs ntfs-3g void-updates void-release-keys fortune-mod-void unzip wl-clipboard qt5ct kvantum -y

clear

# Enable printer support.
read -p "Do you want to enable printer support? (Y/n) " resp
resp=${resp:-Y}

if [ "$resp" = Y ] || [ "$resp" = y ]; then
    echo "Enabling printer support..."
    echo "Installing CUPS..."
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
    echo "Skipping HPLIP installation."
fi
else
    echo "Skipping printer support."
fi

# Install and configure fonts.
echo "Installing fonts..."
vpm install nerd-fonts font-util source-sans-pro font-manjari noto-fonts-ttf noto-fonts-emoji font-material-design-icons-ttf ttf-ubuntu-font-family fonts-roboto-ttf ttfautohint -y
# Enable auto-hinting.
ln -s /usr/share/fontconfig/conf.avail/09-autohint-if-no-hinting.conf /etc/fonts/conf.d/
# Enable RGB sub-pixel rendering.
ln -s /usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/
# Configure nerd fonts for "lsd".
ln -s /usr/share/fontconfig/conf.avail/10-nerd-font-symbols.conf /etc/fonts/conf.d/

# Install the Poppins font.
echo "Installing the Poppins font..."
curl https://fonts.google.com/download?family=Poppins -o /home/$USER/Poppins.zip
unzip /home/$USER/Poppins.zip -x OFL.txt -d /usr/share/fonts/Poppins
rm -f /home/$USER/Poppins.zip

# Install KDE.
echo "Installing the KDE desktop..."
vpm install kde5 kde5-baseapps kaccounts-integration kaccounts-providers xdg-desktop-portal-kde k3b juk ark kdegraphics-thumbnailers -y

# Enable desktop services.
declare -a services=("dbus" "NetworkManager" "elogind")
for service in "${services[@]}"; do
    ln -s "/etc/sv/$service" "/var/service/"
done

# Install and configure PipeWire.
vpm install pipewire alsa-pipewire -y
mkdir -p /etc/pipewire/pipewire.conf.d
ln -s /usr/share/examples/wireplumber/10-wireplumber.conf /etc/pipewire/pipewire.conf.d/
ln -s /usr/share/examples/pipewire/20-pipewire-pulse.conf /etc/pipewire/pipewire.conf.d/
mkdir -p /etc/alsa/conf.d
ln -s /usr/share/alsa/alsa.conf.d/50-pipewire.conf /etc/alsa/conf.d/
ln -s /usr/share/alsa/alsa.conf.d/99-pipewire-default.conf /etc/alsa/conf.d/
ln -s /usr/share/applications/pipewire.desktop /etc/xdg/autostart/

# Install Newaita icons.
echo "Installing the Newaita icon theme..."
cd && git clone https://github.com/cbrnix/Newaita.git
cp -r Newaita/Newaita /usr/share/icons
cd && rm -rf Newaita

# Install grub theme.
echo "Installing the GRUB theme..."
cd && git clone https://github.com/vinceliuice/grub2-themes.git
cd grub2-themes && ./install.sh -t stylish
echo "GRUB_DISABLE_SUBMENU=y" >> /etc/default/grub
cd && rm -rf grub2-themes

# Configure lynis.
echo "Configuring lynis..."
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
echo "Securing the OS..."
sed -i 's/UMASK=0022/UMASK=0077/g' /etc/default/sysstat
vpm install sysstat rkhunter chkrootkit apparmor rsyslog audit acct -y

# Enable services.
declare -a services=("rsyslogd" "auditd" "ufw")
for service in "${services[@]}"; do
    ln -s "/etc/sv/$service" "/var/service/"
done

# Disable and stop sshd. Not needed on a personal desktop PC/laptop.
sv down sshd
rm /var/service/sshd
touch /etc/sv/sshd/down

# Enable process accounting.
echo "Enabling process accounting..."
mkdir -p /var/log/account
touch /var/log/account/pacct
accton on

# Set permissions for sensitive files.
echo "Setting permissions for sensitive files..."
chmod og-rwx /boot/grub/grub.cfg
chmod og-rwx /etc/ssh/sshd_config
chmod og-rwx /etc/cron.daily
chmod og-rwx /etc/cron.hourly

# Configure sysctl.conf
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
sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding no/' /etc/ssh/sshd_config
sed -i 's/#ClientAliveCountMax 3/ClientAliveCountMax 2/' /etc/ssh/sshd_config
sed -i 's/#Compression delayed/Compression no/' /etc/ssh/sshd_config
sed -i 's/#LogLevel INFO/LogLevel VERBOSE/' /etc/ssh/sshd_config
sed -i 's/#MaxAuthTries 6/MaxAuthTries 3/' /etc/ssh/sshd_config
sed -i 's/#MaxSessions 10/MaxSessions 2/' /etc/ssh/sshd_config
sed -i 's/#TCPKeepAlive yes/TCPKeepAlive no/' /etc/ssh/sshd_config
sed -i 's/#AllowAgentForwarding yes/AllowAgentForwarding no/' /etc/ssh/sshd_config

# Configure plymouth boot splash.
vpm install plymouth -y
plymouth-set-default-theme -R solar

# Download Konsole colors.
echo "Downloading Konsole colors..."
mkdir -p /home/$USER/.local/share/konsole/
cd && curl https://raw.githubusercontent.com/sonph/onehalf/master/konsole/onehalf-dark.colorscheme -o onehalf-dark.colorscheme
cp -v onehalf-dark.colorscheme /home/$USER/.local/share/konsole/
chown -R $USER:$USER /home/$USER/.local

# Ask the user if they want to enable Flatpak support.
read -p "Do you want to enable Flatpak support? (Y/n) " resp
resp=${flatpak_resp:-Y}

if [ "$resp" = Y ] || [ "$resp" = y ]; then
    echo "Enabling Flatpak support..."
    vpm install flatpak -y
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    flatpak install -y runtime/org.gtk.Gtk3theme.Breeze/x86_64/3.22

# Ask the user if they want to install the Brave web browser.
read -p "Do you want to install the Brave web browser? Flatpak support is required and *WILL* be installed if you answered no to enabling Flakpak support. (Y/n) " resp
resp=${resp:-Y}

if [ "$resp" = Y ] || [ "$resp" = y ]; then
    echo "Enabling Flatpak support..."
    vpm install flatpak -y
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    flatpak install -y runtime/org.gtk.Gtk3theme.Breeze/x86_64/3.22
    echo "Installing Brave..."
    flatpak install -y com.brave.Browser
else
    echo "Skipping Brave browser installation."
fi

# Ask the user if they want to install Pinta.
read -p "Do you want to install the Pinta image editor? (Y/n) " resp
resp=${resp:-Y}

if [ "$resp" = Y ] || [ "$resp" = y ]; then
    echo "Installing Pinta image editor..."
    flatpak install -y app/com.github.PintaProject.Pinta/x86_64/stable
else
    echo "Skipping Pinta installation."
fi
else
    echo "Skipping Flatpak setup."
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

echo "Void Linux post-install setup complete. Don't forget to enable SDDM by changing back into this directory and typing: "./enable-sddm-void.sh" after you reboot."
