#!/bin/bash
# Void Linux post-install setup script. For use with a Void Linux base install.

# Checking to see if we're running as root.
if [ $(id -u) -ne 0 ]; then
echo "Please run this setup script as root via 'su'! Thanks."
exit
fi

# Change to US mirrors and sync repos.
echo "Changing to US mirrors and syncing repos..."
mkdir -p /etc/xbps.d
cp /usr/share/xbps.d/*-repository-*.conf /etc/xbps.d/
sed -i 's|https://repo-default.voidlinux.org|https://repo-us.voidlinux.org|g' /etc/xbps.d/*-repository-*.conf
xbps-install -S

# Install VPM (Void Package Management Utility), XBPS user-friendly front-end.
echo "Installing the Void Package Management utility..."
xbps-install -S vpm -y

# Add extra nonfree repo.
echo "Adding nonfree repo to system..."
vpm addrepo void-repo-nonfree

# Update OS.
echo "Updating OS packages..."
vpm upgrade -y

# Install Xorg server.
clear ; echo "Installing Xorg server..."
vpm install xorg-minimal xorg-input-drivers xorg-video-drivers xorg-fonts dbus-elogind dbus-elogind-x11 -y
ln -s /etc/sv/elogind /var/service/

# Install misc. utilities.
clear ; echo "Installing misc. utilities..."
vpm install wget curl zsh xdg-user-dirs xdg-user-dirs-gtk xdg-utils xdg-desktop-portal lsd topgrade octoxbps micro make autoconf automake pkg-config gcc lynis neofetch flac vlc duf btop gufw ffmpegthumbs ntfs-3g -y

# Install fonts.
clear ; echo "Installing fonts..."
vpm install nerd-fonts google-fonts-ttf -y

# Install the Poppins font.
curl https://fonts.google.com/download?family=Poppins -o /home/$USER/Poppins.zip
unzip /home/$USER/Poppins.zip -d /usr/share/fonts/Poppins
rm -f /home/$USER/Poppins.zip

# Install micro plugins.
micro -plugin install quoter wc

# Install KDE.
clear ; echo "Installing the KDE desktop..."
vpm install kde5 kde5-baseapps kaccounts-integration kaccounts-providers xdg-desktop-portal-kde k3b juk ark kdegraphics-thumbnailers -y

# Install Papirus icons.
clear ; echo "Installing the Papirus icon theme..."
vpm install papirus-icon-theme -y

# Setup flatpak.
clear ; echo "Installing and setting up flatpak..."
vpm install flatpak -y
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y runtime/org.gtk.Gtk3theme.Breeze/x86_64/3.22

# Install Pinta.
clear ; echo "Installing Pinta..."
flatpak install -y app/com.github.PintaProject.Pinta/x86_64/stable

# Install Brave browser.
clear ; echo "Installing the Brave browser..."
flatpak install -y flathub com.brave.Browser

# Install grub theme.
cd && git clone https://github.com/vinceliuice/grub2-themes.git
cd grub2-themes && ./install.sh -t stylish
echo "GRUB_DISABLE_SUBMENU=y" >> /etc/default/grub
update-grub

# Secure the OS.
sed -i 77s/'022'/'077'/g /etc/login.defs
sed -i 26s/'022'/'077'/g /etc/profile
vpm install rsyslog -y && ln -s /etc/sv/rsyslogd /var/service/
vpm install apparmor -y
vpm install sysstat puppet rkhunter chkrootkit -y && ln -s /etc/sv/puppet /var/service/
chmod og-rwx /boot/grub/grub.cfg
chmod og-rwx /etc/ssh/sshd_config
chmod og-rwx /etc/cron.daily
chmod og-rwx /etc/cron.hourly
echo "dev.tty.ldisc_autoload = 0" >> /etc/sysctl.conf
echo "fs.protected_fifos = 2" >> /etc/sysctl.conf
echo "fs.protected_regular = 2" >> /etc/sysctl.conf
echo "kernel.kptr_restrict = 2" >> /etc/sysctl.conf
echo "kernel.perf_event_paranoid = 3" >> /etc/sysctl.conf
echo "kernel.sysrq = 0" >> /etc/sysctl.conf
echo "net.core.bpf_jit_harden = 2" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.accept_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.log_martians = 1" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.rp_filter = 1" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.send_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.accept_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.accept_source_route = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.log_martians = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.all.accept_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.accept_redirects = 0" >> /etc/sysctl.conf
sed -i s/'#AllowTcpForwarding yes'/'AllowTcpForwarding no'/g /etc/ssh/sshd_config
sed -i s/'#ClientAliveCountMax 3'/'ClientAliveCountMax 2'/g /etc/ssh/sshd_config
sed -i s/'#Compression delayed'/'Compression no'/g /etc/ssh/sshd_config
sed -i s/'#LogLevel INFO'/'LogLevel VERBOSE'/g /etc/ssh/sshd_config
sed -i s/'#MaxAuthTries 6'/'MaxAuthTries 3'/g /etc/ssh/sshd_config
sed -i s/'#MaxSessions 10'/'MaxSessions 2'/g /etc/ssh/sshd_config
sed -i s/'#TCPKeepAlive yes'/'TCPKeepAlive no'/g /etc/ssh/sshd_config
sed -i s/'#AllowAgentForwarding yes'/'AllowAgentForwarding no'/g /etc/ssh/sshd_config
sed -i s/'#Port 22'/'#Port'/g /etc/ssh/sshd_config
ln -s /etc/sv/ufw /var/service

# Configure plymouth boot splash.
vpm install plymouth -y
plymouth-set-default-theme -R fade-in
