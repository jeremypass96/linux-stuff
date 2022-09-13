#!/bin/bash
# This shell script cleans up a Fedora KDE spin and removes unnecessary bloatware included with the operating system.

# Checking to see if we're running as root.
if [ $(id -u) -ne 0 ]; then
echo "Please run this script as root! Thanks."
exit
fi

clear

# Make DNF faster.
echo "fastestmirror=True" >> /etc/dnf/dnf.conf
echo "deltarpm=True" >> /etc/dnf/dnf.conf
echo "max_parallel_downloads=20" >> /etc/dnf/dnf.conf

# Remove bloatware.
dnf remove -y libreoffice-* kaddressbook kmail kontact elisa-player kamoso kgpg kmag kmouth qt5-qdbusviewer firefox dragon krdc krfb kolourpaint akregator im-chooser korganizer dnfdragora kmousetool mediawriter
dnf install -y plasma-browser-integration

# Update Fedora install.
dnf update -y

clear

# Add RPMFusion repositories.
dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

clear

# Install Papirus icons.
wget -qO- https://git.io/papirus-icon-theme-install | sh

clear

# Install the Brave browser.
dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/
rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
dnf install -y brave-browser

clear

# Install some useful software.
dnf install -y neofetch vlc audacity-freeworld flac PackageKit-command-not-found duf btop HandBrake-gui ffmpegthumbs

clear

# Install Pinta.
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y app/com.github.PintaProject.Pinta/x86_64/stable runtime/org.gtk.Gtk3theme.Breeze/x86_64/3.22

# Install codecs.
dnf install -y gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel lame\* --exclude=lame-devel

# Install K3b.
dnf install -y k3b cdrskin sox

clear

# Install the micro text editor and remove nano.
dnf install -y micro xclip ; dnf remove -y nano

clear

# Install the IBM Plex Mono fonts.
dnf install -y ibm-plex-mono-fonts

clear

# Install KDE wallapers.
dnf install -y plasma-workspace-wallpapers

clear

# Cleanup systemd boot.
./cleanup-systemd-boot.sh

clear

# Install Zsh.
dnf install -y zsh

clear

# Download Konsole colors.
curl https://raw.githubusercontent.com/mbadolato/iTerm2-Color-Schemes/master/konsole/Andromeda.colorscheme -o /home/$USER/.local/share/konsole/Andromeda.colorscheme

clear

# Install the Poppins font.
curl https://fonts.google.com/download?family=Poppins -o /home/$USER/Poppins.zip
unzip /home/$USER/Poppins.zip -d /usr/share/fonts/Poppins
rm -f /home/$USER/Poppins.zip

# Install the Source Sans Pro font.
curl https://fonts.google.com/download?family=Source%20Sans%20Pro -o /home/$USER/Source_Sans_Pro.zip
unzip /home/$USER/Source_Sans_Pro.zip -d /usr/share/fonts/SourceSansPro
rm -f /home/$USER/Source_Sans_Pro.zip

# Install lynis.
cat >> /etc/yum.repos.d/cisofy-lynis.repo << EOF
[lynis]
name=CISOfy Software - Lynis package
baseurl=https://packages.cisofy.com/community/lynis/rpm/
enabled=1
gpgkey=https://packages.cisofy.com/keys/cisofy-software-rpms-public.key
gpgcheck=1
priority=2
EOF
dnf install -y lynis

# Secure the OS.
sed -i 117s/'022'/'077'/g /etc/login.defs
sed -i s/'umask 022'/'umask 077'/g /etc/init.d/functions
sed -i s/'umask 022'/'umask 077'/g /etc/bashrc
sed -i s/'umask 022'/'umask 077'/g /etc/csh.cshrc
echo "umask 077" >> /etc/profile
updatedb
dnf install -y sysstat puppet rkhunter chkrootkit ghc-cprng-aes
echo "dev.tty.ldisc_autoload = 0" >> /etc/sysctl.d/90-override.conf
echo "fs.protected_fifos = 2" >> /etc/sysctl.d/90-override.conf
echo "fs.protected_regular = 2" >> /etc/sysctl.d/90-override.conf
echo "fs.suid_dumpable = 0" >> /etc/sysctl.d/90-override.conf
echo "kernel.dmesg_restrict = 1" >> /etc/sysctl.d/90-override.conf
echo "kernel.kptr_restrict = 2" >> /etc/sysctl.d/90-override.conf
echo "kernel.perf_event_paranoid = 3" >> /etc/sysctl.d/90-override.conf
echo "kernel.sysrq = 0" >> /etc/sysctl.d/90-override.conf
echo "kernel.unprivileged_bpf_disabled = 1" >> /etc/sysctl.d/90-override.conf
echo "kernel.yama.ptrace_scope = 1" >> /etc/sysctl.d/90-override.conf
echo "net.core.bpf_jit_harden = 2" >> /etc/sysctl.d/90-override.conf
echo "net.ipv4.conf.all.log_martians = 1" >> /etc/sysctl.d/90-override.conf
echo "net.ipv4.conf.all.rp_filter = 1" >> /etc/sysctl.d/90-override.conf
echo "net.ipv4.conf.default.log_martians = 1" >> /etc/sysctl.d/90-override.conf
chmod og-rwx /etc/at.deny
chmod og-rwx /etc/cron.*
chmod og-rwx /etc/crontab
chmod og-rwx /etc/cron.d
chmod og-rwx /etc/cron.deny

# Install packages to auto-update the OS.
dnf install -y dnf-automatic fedora-upgrade
systemctl enable dnf-system-upgrade
systemctl start dnf-system-upgrade

# Install and run topgrade.
curl https://github.com/r-darwish/topgrade/releases/download/v9.0.1/topgrade-v9.0.1-x86_64-unknown-linux-gnu.tar.gz -o topgrade-v9.0.1-x86_64-unknown-linux-gnu.tar.gz
tar -x topgrade-v9.0.1-x86_64-unknown-linux-gnu.tar.gz
install topgrade /usr/local/bin/
topgrade

# Install grub theme.
cd && git clone https://github.com/vinceliuice/grub2-themes.git
cd grub2-themes && ./install.sh -t stylish
