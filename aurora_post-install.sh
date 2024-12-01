#!/bin/bash
# This script will install the Vimix KDE theme and Papirus icons and install the Brave web browser, VSCodium, and the Pinta image editor on Aurora, and some more useful software.

# Install the Papirus icon theme.
wget -qO- https://git.io/papirus-icon-theme-install | env DESTDIR="$HOME/.icons" sh

# Install the Vimix KDE theme.
rpm-ostree install kvantum
git clone https://github.com/vinceliuice/Vimix-kde.git $HOME/Vimix-kde
cd $HOME/Vimix-kde
./install.sh -t doder
# Cleanup
cd $HOME
rm -rf Vimix-kde

# Remove Firefox and Kate text editor.
flatpak uninstall -y org.mozilla.firefox
rpm-ostree uninstall kate

# Install the Brave web browser and VSCodium.
flatpak install -y com.brave.Browser com.vscodium.codium

# Configure VSCodium.
mkdir -p $HOME/.config/VSCodium/User && cp -v $HOME/linux-stuff/Dotfiles/config/VSCodium/User/settings.json $HOME/.config/VSCodium/User/settings.json
vscodium --install-extension qyurila.ayu-midas
vscodium --install-extension jeff-hykin.better-shellscript-syntax
vscodium --install-extension file-icons.file-icons
vscodium --install-extension miguelsolorio.fluent-icons

# Install the Pinta image editor.
flatpak install -y com.github.PintaProject.Pinta

# Install Audacity.
flatpak install -y org.audacityteam.Audacity

# Install VLC.
flatpak install -y org.videolan.VLC

# Install qBittorrent.
flatpak install -y org.qbittorrent.qBittorrent

# Install Spotify.
flatpak install -y com.spotify.Client