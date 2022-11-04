#!/bin/bash
# Void Linux post-install setup script. For use with a Void Linux base install.

# Checking to see if we're running as root.
if [ $(id -u) -ne 0 ]; then
echo "Please run this setup script as root via 'su'! Thanks."
exit
fi

# Sync repos.
clear ; echo "Syncing repos..."
xbps-install -S

# Install VPM (Void Package Management Utility), XBPS user-friendly front-end.
clear ; echo "Installing the Void Package Management utility..."
xbps-install -S vpm -y

# Add extra nonfree repo.
clear ; echo "Adding nonfree repo to system..."
vpm addrepo void-repo-nonfree -y

# Update OS.
clear ; echo "Upgrading OS packages..."
vpm update -y && sudo vpm upgrade -y

# Install Xorg server.
clear ; echo "Installing Xorg server..."
vpm install xorg-minimal xorg-input-drivers xorg-video-drivers xorg-fonts dbus-elogind dbus-elogind-x11 -y
ln -s /etc/sv/elogind /var/service/

# Install misc. utilities.
clear ; echo "Installing misc. utilities..."
vpm install wget curl zsh xdg-user-dirs xdg-user-dirs-gtk xdg-utils xdg-desktop-portal lsd topgrade octoxbps micro make autoconf automake pkg-config gcc lynis neofetch flac vlc duf btop ffmpegthumbs -y

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
vpm install kde5 kde5-baseapps kaccounts-integration kaccounts-providers xdg-desktop-portal-kde k3b juk kdegraphics-thumbnailers -y

# Download Konsole colors.
curl https://raw.githubusercontent.com/mbadolato/iTerm2-Color-Schemes/master/konsole/Andromeda.colorscheme -o /home/$USER/.local/share/konsole/Andromeda.colorscheme

# Install Papirus icons.
clear ; echo "Installing the Papirus icon theme..."
vpm install papirus-icon-theme -y

# Setup flatpak.
clear ; echo "Installing and setting up flatpak..."
vpm install flatpak -y
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install Pinta.
clear ; echo "Installing Pinta..."
flatpak install -y app/com.github.PintaProject.Pinta/x86_64/stable runtime/org.gtk.Gtk3theme.Breeze/x86_64/3.22

# Install grub theme.
cd && git clone https://github.com/vinceliuice/grub2-themes.git
cd grub2-themes && ./install.sh -t stylish

# Install Brave browser.
clear ; echo "Installing the Brave browser..."
flatpak install -y flathub com.brave.Browser
