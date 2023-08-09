#!/bin/bash
# This shell script cleans up a Fedora KDE spin and removes unnecessary bloatware included with the operating system.

# Checking to see if we're running as root.
if [ $(id -u) -ne 0 ]; then
    echo "Please run this script as root! Thanks."
    exit
fi

clear

# Audio buzz/hum fix.
echo "options snd-hda-intel power_save=0 power_save_controller=N" >> /etc/modprobe.d/alsa-base.conf

# Configure DNF for speed and sanity.
echo -e "fastestmirror=True\nmax_parallel_downloads=20\ndefaultyes=True\ninstall_weak_deps=False" >> /etc/dnf/dnf.conf

# Remove bloatware and install some KDE games.
dnf remove -y libreoffice-* kaddressbook kmail kontact elisa-player kamoso kgpg kmag kmouth kmahjongg qt5-qdbusviewer firefox dragon krdc krfb kolourpaint akregator im-chooser korganizer dnfdragora kmousetool mediawriter
dnf install -y kapman kbrickbuster kblocks kbounce knetwalk

# Install KDE Plasma browser integration.
dnf install -y plasma-browser-integration

# Update Fedora install.
dnf update -y

clear

# Add RPMFusion repositories.
dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

clear

# Install Newaita icons.
echo "Installing the Newaita icon theme..."
cd && git clone https://github.com/cbrnix/Newaita.git
cp -r Newaita/Newaita-dark /usr/share/icons
rm -rf Newaita

clear

# Install the Brave browser.
dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/
rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
dnf install -y brave-browser

clear

# Install some useful software.
dnf install -y neofetch vlc audacity-freeworld flac PackageKit-command-not-found duf btop lsd HandBrake-gui ffmpegthumbs juk

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
dnf install -y micro xclip && dnf remove -y nano

clear

# Install the JetBrain Mono fonts.
dnf install -y jetbrains-mono-fonts

clear

# Install KDE wallpapers.
dnf install -y plasma-workspace-wallpapers

clear

# Cleanup systemd boot.
./cleanup-systemd-boot.sh

clear

# Install Zsh.
dnf install -y zsh

clear

# Download Konsole colors.
cd && git clone https://github.com/catppuccin/konsole.git
mkdir -p /home/$USER/.local/share/konsole/
cp -v konsole/*.colorscheme /home/$USER/.local/share/konsole/
chown -R $USER:$USER /home/$USER/.local/share/konsole/
rm -rf konsole

clear

# Install the Poppins font.
curl https://fonts.google.com/download?family=Poppins -o /home/$USER/Poppins.zip
unzip /home/$USER/Poppins.zip -x OFL.txt -d /usr/share/fonts/Poppins
rm -f /home/$USER/Poppins.zip

# Install the Source Sans 3 font.
curl https://fonts.google.com/download\?family\=Source+Sans+3 -o /home/$USER/Source_Sans_3.zip
unzip /home/$USER/Source_Sans_3.zip -x README.txt OFL.txt SourceSans3-VariableFont_wght.ttf SourceSans3-Italic-VariableFont_wght.ttf -d /usr/share/fonts/SourceSansPro
rm -f /home/$USER/Source_Sans_3.zip

clear

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

clear

# Secure the OS.
declare -a files_to_secure=("/etc/login.defs" "/etc/init.d/functions" "/etc/bashrc" "/etc/csh.cshrc")
for file in "${files_to_secure[@]}"; do
    sed -i 's/umask 022/umask 077/' "$file"
done

echo "umask 077" >> /etc/profile

# Update /etc/login.defs to change umask
sed -i '117s/022/077/g' /etc/login.defs

chmod og-rwx /etc/at.deny
chmod og-rwx /etc/cron.*
chmod og-rwx /etc/crontab
chmod og-rwx /etc/cron.deny

updatedb
dnf install -y sysstat puppet rkhunter chkrootkit ghc-cprng-aes

# Set sysctl parameters for security
echo -e "dev.tty.ldisc_autoload = 0\n\
fs.protected_fifos = 2\n\
fs.protected_regular = 2\n\
fs.suid_dumpable = 0\n\
kernel.dmesg_restrict = 1\n\
kernel.kptr_restrict = 2\n\
kernel.perf_event_paranoid = 3\n\
kernel.sysrq = 0\n\
kernel.unprivileged_bpf_disabled = 1\n\
kernel.yama.ptrace_scope = 1\n\
net.core.bpf_jit_harden = 2\n\
net.ipv4.conf.all.log_martians = 1\n\
net.ipv4.conf.all.rp_filter = 1\n\
net.ipv4.conf.default.log_martians = 1" >> /etc/sysctl.d/90-override.conf

clear

# Install packages to auto-update the OS.
dnf install -y dnf-automatic fedora-upgrade
systemctl enable --now dnf-system-upgrade

clear

# Install and run topgrade.
topgrade_latest_version=$(curl -s https://api.github.com/repos/topgrade-rs/topgrade/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
topgrade_url="https://github.com/topgrade-rs/topgrade/releases/download/${topgrade_latest_version}/topgrade-${topgrade_latest_version}-x86_64-unknown-linux-gnu.tar.gz"
topgrade_temp_dir="$(mktemp -d)"

wget "$topgrade_url" -P "$topgrade_temp_dir"
tar -xf "${topgrade_temp_dir}/topgrade-${topgrade_latest_version}-x86_64-unknown-linux-gnu.tar.gz" -C "$topgrade_temp_dir"
install "${topgrade_temp_dir}/topgrade" /usr/local/bin/
rm -rf "$topgrade_temp_dir"

topgrade

clear

# Install grub theme.
git clone https://github.com/vinceliuice/grub2-themes.git "$HOME/grub2-themes"
"$HOME/grub2-themes/install.sh" -t stylish
rm -rf "$HOME/grub2-themes"

clear

# Speed up systemd journal flush.
sed -i 's/#Storage=auto/Storage=volatile/' /etc/systemd/journald.conf
sed -i 's/#SystemMaxFileSize=/SystemMaxFileSize=20MB/' /etc/systemd/journald.conf

echo "Cleanup and optimization complete."
