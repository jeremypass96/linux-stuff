#!/bin/bash
# Void Linux post-install setup script. For use with a Void Linux base install.

# Checking to see if we're running as root.
if [ $(id -u) -ne 0 ]; then
echo "Please run this setup script as root via 'su'! Thanks."
exit
fi

# Audio buzz/hum fix.
echo "options snd-hda-intel power_save=0 power_save_controller=N" >> /etc/modprobe.d/alsa-base.conf

# Change to US mirrors and sync repos.
echo "Changing to US mirrors and syncing repos..."
mkdir -p /etc/xbps.d
cp /usr/share/xbps.d/*-repository-*.conf /etc/xbps.d/
sed -i 's|https://repo-default.voidlinux.org|https://repo-us.voidlinux.org|g' /etc/xbps.d/*-repository-*.conf
xbps-install -S

# Configure XBPS to use the latest package versions.
sed -i s/'#bestmatching=true'/'bestmatching=true'/g /usr/share/xbps.d/xbps.conf

# Add extra nonfree repo.
echo "Adding nonfree repo to system..."
xbps-install -S void-repo-nonfree -y

# Add multilib repos.
echo "Adding multilib repos to system..."
xbps-install -S void-repo-multilib void-repo-multilib-nonfree -y

# Update OS.
echo "Updating OS packages..."
xbps-install -Suvy

# Install VPM (Void Package Management utility), XBPS user-friendly front-end.
echo "Installing the Void Package Management utility..."
xbps-install -S vpm -y

# Install Xorg server.
clear ; echo "Installing Xorg server..."
vpm install xorg-minimal xorg-input-drivers xorg-video-drivers xorg-fonts dbus-elogind dbus-elogind-x11 -y
ln -s /etc/sv/elogind /var/service/

# Install misc. utilities.
clear ; echo "Installing misc. utilities..."
vpm install wget curl zsh xdg-user-dirs xdg-user-dirs-gtk xdg-utils xdg-desktop-portal lsd bat fd topgrade octoxbps micro make autoconf automake pkg-config gcc lynis neofetch flac vlc duf btop gufw ffmpegthumbs ntfs-3g vsv void-updates void-release-keys fortune-mod-void -y

# Enable printing support.
vpm install cups hplip -y
vsv enable cupsd
vsv enable cups-browsed
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

# Install grub theme.
cd && git clone https://github.com/vinceliuice/grub2-themes.git
cd grub2-themes && ./install.sh -t stylish
echo "GRUB_DISABLE_SUBMENU=y" >> /etc/default/grub
update-grub

# Configure lynis.
echo "machine-role=personal" > /etc/lynis/custom.prf

# Secure the OS.
sed -i 77s/'022'/'077'/g /etc/login.defs
sed -i 26s/'022'/'077'/g /etc/profile
sed -i s/'UMASK=0022'/'UMASK=0077'/g /etc/default/sysstat
vpm install sysstat puppet rkhunter chkrootkit apparmor rsyslog audit acct -y
vsv enable puppet ; vsv enable rsyslogd ; vsv enable auditd ; vsv enable ufw ; vsv disable sshd
mkdir /var/log/account; touch /var/log/account/pacct ; accton on
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

# Configure plymouth boot splash.
vpm install plymouth -y
plymouth-set-default-theme -R solar