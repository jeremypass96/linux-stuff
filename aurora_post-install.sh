#!/bin/bash
# This script will install the Vimix KDE theme and Papirus icons and install the Brave web browser, VSCodium, and the Pinta image editor on Aurora, and some more useful software.

# Install the Qogir icon theme.
cd "$HOME" || exit
git clone https://github.com/vinceliuice/Qogir-icon-theme.git
cd "$HOME"/Qogir-icon-theme || exit
./install.sh -t default

# Install the Arc KDE theme.
rpm-ostree install kvantum arc-kde

# Remove Firefox and other junk.
flatpak uninstall -y org.mozilla.firefox org.fedoraproject.MediaWriter org.kde.haruna org.kde.kontact org.gnome.World.PikaBackup org.gnome.DejaDup

# Install the Brave web browser and VSCodium.
flatpak install -y com.brave.Browser com.vscodium.codium

# Configure VSCodium.
mkdir -p "$HOME"/.var/app/com.vscodium.codium/config/VSCodium/User && cp -v "$HOME"/linux-stuff/Dotfiles/config/VSCodium/User/settings.json "$HOME"/.var/app/com.vscodium.codium/config/VSCodium/User/settings.json
flatpak run com.vscodium.codium --install-extension qyurila.ayu-midas
flatpak run com.vscodium.codium --install-extension jeff-hykin.better-shellscript-syntax
flatpak run com.vscodium.codium --install-extension file-icons.file-icons
flatpak run com.vscodium.codium --install-extension miguelsolorio.fluent-icons

# Install the Pinta image editor, Audacity, VLC, QBittorrent, and Spotify.
flatpak install -y com.github.PintaProject.Pinta org.audacityteam.Audacity org.videolan.VLC org.qbittorrent.qBittorrent com.spotify.Client