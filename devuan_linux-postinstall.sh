#!/bin/bash
# This script will optimize a Devuan testing installation and install XLibre, SonicDE, and the Brave web browser.

# Disable suggested packages from apt.
cat <<EOF | sudo tee /etc/apt/apt.conf.d/99_noautosuggests >/dev/null
APT::Install-Suggests "false";
APT::AutoRemove::SuggestsImportant "false";
EOF
sudo apt update

# Install Nala, a better apt front-end.
sudo apt install -y nala

clear

# Update mirrors.
sudo nala fetch

clear

# Add Vendefoul Wolf repository.
echo "deb [trusted=yes] http://apt.fury.io/vendefoulwolf/ * *" | sudo tee /etc/apt/sources.list.d/fury.list >/dev/null
sudo chmod go+r /etc/apt/sources.list.d/fury.list

# Update package list and upgrade Devuan.
sudo sed -i s'/freia main/testing main'/g /etc/apt/sources.list
sudo sed -i s'/non-free-firmware/non-free-firmware non-free contrib'/g /etc/apt/sources.list
sudo nala full-upgrade

clear

# Install and configure PipeWire.
sudo nala install pipewire pipewire-pulse wireplumber -y
cat <<EOF >>~/.profile
if [ "$XDG_RUNTIME_DIR" = "/run/user/$(id -u)" ] ; then
        psess_pids=
        for p in pipewire wireplumber pipewire-pulse ; do
        command -v $p >/dev/null || continue
            pgrep --exact --uid $USER $p >/dev/null && continue
            $p &
            psess_pids="$! ${psess_pids}"
        done
        [ "$psess_pids" ] && trap "kill $psess_pids" EXIT
fi
EOF
cat <<EOF >>~/.xsessionrc
if [ -f ~/.profile ]; then
    . ~/.profile
fi
EOF

# Install necessary utility packages.
sudo nala install ca-certificates gpg curl dialog -y

clear

# Install XLibre.
sudo install -m 0755 -d /usr/share/keyrings
curl -fsSL https://mrchicken.nexussfan.cz/publickey.asc | gpg --dearmor | sudo tee /usr/share/keyrings/NexusSfan.pgp >/dev/null
sudo chmod a+r /usr/share/keyrings/NexusSfan.pgp
cat <<EOF | sudo tee /etc/apt/sources.list.d/xlibre-debian.sources
Types: deb
URIs: https://xlibre-debian.github.io/devuan/
Suites: main
Components: testing
Signed-By: /usr/share/keyrings/NexusSfan.pgp
EOF
sudo nala update
sudo nala install xlibre xlibre-archive-keyring -y

# Install SonicDE.
cat <<EOF | sudo tee /etc/apt/sources.list.d/sonicde-debian.sources >/dev/null
Types: deb
URIs: https://sonicde-debian.github.io/debian/
Suites: main
Components: testing
Signed-By: /usr/share/keyrings/NexusSfan.pgp
EOF
sudo nala update
sudo nala install sonicde sonic-archive-keyring

# Install some useful software.
sudo nala install audacity vlc fd-find bat lsd btop -y
clear

# Install and setup Zsh.
sudo nala install zsh -y && ./zsh-setup.sh

# Install fastfetch.
sudo nala install fastfetch -y && ./fastfetch-setup.sh

# Install Helix.
sudo nala install hx -y

clear

# Setup other stuff.
sudo ln -s /usr/bin/batcat /usr/bin/bat && sudo ./bat-setup.sh
sudo ./wallpapers.sh
./lsd-setup.sh

# Install Brave web browser.
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo nala update && sudo nala install brave-browser -y

# Install grub theme.
echo "Installing the GRUB theme..."
cd && git clone https://github.com/vinceliuice/grub2-themes.git
cd grub2-themes && sudo ./install.sh -t stylish
echo "GRUB_DISABLE_SUBMENU=y" | sudo tee -a /etc/default/grub
cd && rm -rf grub2-themes

# Enable GRUB_DISABLE_RECOVERY in /etc/default/grub.
sudo chmod o+w /etc/default/grub
sudo sed -i s/#GRUB_DISABLE_RECOVERY/GRUB_DISABLE_RECOVERY/g /etc/default/grub
sudo chmod o-w /etc/default/grub

# Update environment variables.
cat <<EOF | sudo tee /etc/environment
BROWSER=brave
EDITOR=hx
EOF

# Install Liquorix kernel.
curl -s 'https://liquorix.net/install-liquorix.sh' | sudo bash
