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
dnf remove -y libreoffice-* kaddressbook kmail kontact elisa-player kamoso kcolorchooser kgpg kmag kmouth qt5-qdbusviewer firefox dragon krdc krfb kolourpaint akregator im-chooser korganizer dnfdragora kmousetool mediawriter

# Update Fedora install.
dnf update -y

clear

# Add RPMFusion repositories.
dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

clear

# Install Papirus icons.
dnf copr enable -y dirkdavidis/papirus-icon-theme
dnf install -y papirus-icon-theme

clear

# Install XanMod Linux kernel.
dnf copr enable -y rmnscnce/kernel-xanmod
dnf install -y kernel-xanmod-tt

clear

# Install the Brave browser.
dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/
rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
dnf install -y brave-browser

clear

# Install the Atom text editor.
rpm --import https://packagecloud.io/AtomEditor/atom/gpgkey
sh -c 'echo -e "[Atom]\nname=Atom Editor\nbaseurl=https://packagecloud.io/AtomEditor/atom/el/7/\$basearch\nenabled=1\ngpgcheck=0\nrepo_gpgcheck=1\ngpgkey=https://packagecloud.io/AtomEditor/atom/gpgkey" > /etc/yum.repos.d/atom.repo'
dnf install -y atom

clear

# Install some useful software.
dnf install -y neofetch vlc pinta audacity-freeworld PackageKit-command-not-found

clear

# Install codecs.
dnf install -y gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel lame\* --exclude=lame-devel

clear

# Install the micro text editor and remove nano.
dnf install -y micro xclip && dnf remove -y nano

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
unzip Poppins.zip -d /usr/share/fonts/Poppins
rm -f /home/$USER/Poppins.zip

# Install the Source Sans Pro font.
curl https://fonts.google.com/download?family=Source%20Sans%20Pro -o /home/$USER/Source_Sans_Pro.zip
unzip Source_Sans_Pro.zip -d /usr/share/fonts/SourceSansPro
rm -f /home/$USER/Source_Sans_Pro.zip
