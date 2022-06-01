#!/bin/bash
# This shell script cleans up a Kubuntu install and removes unnecessary bloatware included with the operating system (if installed with the "Normal installation" option).

# Checking to see if we're running as root.
if [ $(id -u) -ne 0 ]; then
echo "Please run this script as root via 'su' or 'sudo'! Thanks."
exit
fi

# Add Nala repo and install nala, a nicer and better apt frontend.
echo "deb [arch=amd64] http://deb.volian.org/volian/ scar main" | tee /etc/apt/sources.list.d/volian-archive-scar-unstable.list
wget -qO - https://deb.volian.org/volian/scar.key | tee /etc/apt/trusted.gpg.d/volian-archive-scar-unstable.gpg > /dev/null
apt update; apt install -y nala

# Install Papirus icons.
add-apt-repository -y ppa:papirus/papirus
nala update; nala install -y papirus-icon-theme

# Remove bloatware. If you installed Kubuntu with the minimal install option, then you're all set!
nala purge -y libreoffice* elisa ktorrent thunderbird konversation krdc kmahjongg ksudoku xserver-xorg-input-wacom kate plasma-discover imagemagick-6.q16
nala autopurge -y
snap remove --purge firefox

# Install useful software.
nala install -y micro fonts-roboto fonts-roboto-hinted

# Install the Brave browser.
nala install -y apt-transport-https curl
curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | tee /etc/apt/sources.list.d/brave-browser-release.list
nala update; nala install -y brave-browser

# Install the Atom text editor.
wget -qO - https://packagecloud.io/AtomEditor/atom/gpgkey | apt-key add -
sh -c 'echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" > /etc/apt/sources.list.d/atom.list'
nala update
nala install -y atom

# Install KDE wallpapers.
nala install -y plasma-workspace-wallpapers

# Cleanup systemd boot.
./cleanup-systemd-boot.sh

# Install Zsh.
nala install -y zsh
