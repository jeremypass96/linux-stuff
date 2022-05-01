#!/bin/bash
# This shell script cleans up a Kubuntu install and removes unnecessary bloatware included with the operating system (if installed with the "Normal installation" option).

# Checking to see if we're running as root.
if [ $(id -u) -ne 0 ] ; then
echo "Please run this script as root! Thanks."
exit
fi

# Update repos.
apt update

# Add Nala repo and install nala, a nicer and better apt frontend.
echo "deb [arch=amd64] http://deb.volian.org/volian/ scar main" | tee /etc/apt/sources.list.d/volian-archive-scar-unstable.list
wget -qO - https://deb.volian.org/volian/scar.key | tee /etc/apt/trusted.gpg.d/volian-archive-scar-unstable.gpg > /dev/null
apt update ; apt install -y nala

# Install Papirus icons.
add-apt-repository -y ppa:papirus/papirus
nala update ; nala install -y papirus-icon-theme

# Remove bloatware. If you installed Kubuntu with the minimal install option, then you're all set!
nala purge -y libreoffice* elisa firefox ktorrent thunderbird konversation krdc kmahjongg ksudoku xserver-xorg-input-wacom kate plasma-discover
nala autopurge -y

# Install useful software.
nala install -y micro neofetch vlc fonts-roboto fonts-roboto-hinted

# Install the Brave browser.
nala install apt-transport-https curl
curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | tee /etc/apt/sources.list.d/brave-browser-release.list
nala update ; nala install -y brave-browser

# Configure micro.
mkdir /home/$USER/.config/micro
cp -v /home/$USER/linux-stuff/Dotfiles/config/micro/settings.json /home/$USER/.config/micro/settings.json
chown $USER:$USER /home/$USER/.config/micro
chown $USER:$USER /home/$USER/.config/micro/*
mkdir -p /etc/skel/.config/micro
cp -v /home/$USER/.config/micro/settings.json /etc/skel/.config/micro/

# Install and configure neofetch.
mkdir /home/$USER/.config/neofetch
dnf install -y neofetch
cp -v /home/$USER/linux-stuff/Dotfiles/config/neofetch/config.conf /home/$USER/.config/neofetch/config.conf
chown $USER:$USER /home/$USER/.config/neofetch
chown $USER:$USER /home/$USER/.config/neofetch/*
mkdir -p /etc/skel/.config/neofetch
cp -v /home/$USER/.config/neofetch/config.conf /etc/skel/.config/neofetch/

# Install and configure zsh.
nala install -y zsh
sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
cp -v /home/$USER/linux-stuff/Dotfiles/.zshrc /home/$USER/.zshrc
cp -v /home/$USER/.zshrc /etc/skel/.zshrc
git clone https://github.com/zsh-users/zsh-autosuggestions.git /home/$USER/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /home/$USER/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# Install KDE wallpapers.
nala install -y plasma-workspace-wallpapers
