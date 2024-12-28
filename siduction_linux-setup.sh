#!/bin/sh
# This script will clean up and optimize a Siduction KDE (Debian-based rolling release distribution) installation.

# Define color codes
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting Siduction KDE optimization script...${NC}"

# Audio buzz/hum fix.
echo -e "${BLUE}Applying audio buzz/hum fix...${NC}"
echo "options snd-hda-intel power_save=0 power_save_controller=N" | sudo tee /etc/modprobe.d/alsa-base.conf > /dev/null
echo -e "${GREEN}Audio fix applied successfully.${NC}"

# Install Nala, a better apt front-end.
echo -e "${BLUE}Installing Nala...${NC}"
curl https://gitlab.com/volian/volian-archive/-/raw/main/install-nala.sh | bash
if [ $? -eq 0 ]; then
  echo -e "${GREEN}Nala installed successfully.${NC}"
else
  echo -e "${RED}Failed to install Nala.${NC}"
fi

# Update mirrors.
echo -e "${BLUE}Updating mirrors...${NC}"
sudo nala fetch
if [ $? -eq 0 ]; then
  echo -e "${GREEN}Mirrors updated successfully.${NC}"
else
  echo -e "${RED}Failed to update mirrors.${NC}"
fi

# Remove bloatware.
echo -e "${YELLOW}Removing bloatware...${NC}"
sudo nala purge xsane libreoffice-common firefox kmail kget konqueror konversation krdc krfb flameshot gimp imagemagick kcolorchooser kolourpaint kruler akregator kasts kdepim dragonplayer elisa mpv smplayer mc kate kleopatra krusader kteatime imagemagick* kaffeine ktorrent sshactivate kaddressbook korganizer zim whowatch yakuake byobu -y
sudo nala autoremove -y
if [ $? -eq 0 ]; then
  echo -e "${GREEN}Bloatware removed successfully.${NC}"
else
  echo -e "${RED}Failed to remove bloatware.${NC}"
fi

# Install and configure fonts.
echo -e "${BLUE}Installing and configuring fonts...${NC}"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/officialrajdeepsingh/nerd-fonts-installer/main/install.sh)"
sudo nala install fonts-adobe-sourcesans3 fonts-material-design-icons-iconfont fonts-materialdesignicons-webfont fonts-roboto-hinted fonts-ubuntu ttfautohint -y
sudo mkdir -p /usr/share/fonts/Poppins
sudo wget https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-*.ttf -P /usr/share/fonts/Poppins
ln -s /usr/share/fontconfig/conf.avail/09-autohint-if-no-hinting.conf /etc/fonts/conf.d/
ln -s /usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/
if [ $? -eq 0 ]; then
  echo -e "${GREEN}Fonts installed and configured successfully.${NC}"
else
  echo -e "${RED}Failed to install fonts.${NC}"
fi

# Update package list and upgrade Debian.
echo -e "${BLUE}Upgrading Debian packages...${NC}"
sudo nala upgrade
if [ $? -eq 0 ]; then
  echo -e "${GREEN}Packages upgraded successfully.${NC}"
else
  echo -e "${RED}Failed to upgrade packages.${NC}"
fi

# Install a few KDE games.
echo -e "${BLUE}Installing KDE games...${NC}"
sudo nala install kapman kblocks kbounce kbreakout kmines knetwalk kpat kreversi -y
if [ $? -eq 0 ]; then
  echo -e "${GREEN}KDE games installed successfully.${NC}"
else
  echo -e "${RED}Failed to install KDE games.${NC}"
fi

# Install some useful software.
echo -e "${BLUE}Installing useful software...${NC}"
sudo nala install audacity vlc fd-find bat lsd vim btop -y
if [ $? -eq 0 ]; then
  echo -e "${GREEN}Useful software installed successfully.${NC}"
else
  echo -e "${RED}Failed to install useful software.${NC}"
fi

# Install theme(s) for Konsole.
echo -e "${BLUE}Downloading and installing Konsole themes...${NC}"
dialog --title "Konsole Colorscheme" --menu "Which Konsole colorscheme do you want?" 12 40 12 \
1 "Catppuccin" \
2 "OneHalf-Dark" \
3 "Ayu Mirage" 2> /tmp/konsole_resp
konsole_resp=$(cat /tmp/konsole_resp)
if [ "$konsole_resp" = 1 ]; then
    curl --parallel https://raw.githubusercontent.com/catppuccin/konsole/refs/heads/main/themes/*.colorscheme -o "*.colorscheme"
    sudo mkdir -p /usr/share/konsole
    sudo chmod 755 /usr/share/konsole
    sudo mv *.colorscheme /usr/share/konsole
elif [ "$konsole_resp" = 2 ]; then
    curl https://raw.githubusercontent.com/sonph/onehalf/master/konsole/onehalf-dark.colorscheme -o onehalf-dark.colorscheme
    sudo mkdir -p /usr/share/konsole
    sudo chmod 755 /usr/share/konsole
    sudo mv onehalf-dark.colorscheme /usr/share/konsole
elif [ "$konsole_resp" = 3 ]; then
    curl https://raw.githubusercontent.com/mbadolato/iTerm2-Color-Schemes/refs/heads/master/konsole/Ayu%20Mirage.colorscheme -o AyuMirage.colorscheme
    sudo mkdir -p /usr/share/konsole
    sudo chmod 755 /usr/share/konsole
    sudo mv AyuMirage.colorscheme /usr/share/konsole
fi
if [ $? -eq 0 ]; then
  echo -e "${GREEN}Konsole theme(s) installed successfully.${NC}"
else
  echo -e "${RED}Failed to install Konsole theme(s).${NC}"
fi

# Install and setup Zsh.
echo -e "${BLUE}Installing and configuring Zsh...${NC}"
sudo nala install zsh -y && ./zsh-setup.sh
if [ $? -eq 0 ]; then
  echo -e "${GREEN}Zsh installed and configured successfully.${NC}"
else
  echo -e "${RED}Failed to install and configure Zsh.${NC}"
fi

# Install fastfetch.
echo -e "${BLUE}Installing fastfetch...${NC}"
sudo nala install fastfetch -y && ./fastfetch-setup.sh
if [ $? -eq 0 ]; then
  echo -e "${GREEN}Fastfetch installed successfully.${NC}"
else
  echo -e "${RED}Failed to install fastfetch.${NC}"
fi

# Cleanup systemd boot.
echo -e "${BLUE}Cleaning up systemd boot entries...${NC}"
sudo ./cleanup-systemd-boot.sh
if [ $? -eq 0 ]; then
  echo -e "${GREEN}Systemd boot entries cleaned up successfully.${NC}"
else
  echo -e "${RED}Failed to clean up systemd boot entries.${NC}"
fi

# Finalizing setup.
echo -e "${BLUE}Finalizing setup...${NC}"
sudo ln -s /usr/bin/batcat /usr/bin/bat && ./bat-setup.sh
sudo ./wallpapers.sh
./lsd-setup.sh
./vim_setup.sh
if [ $? -eq 0 ]; then
  echo -e "${GREEN}Final setup completed successfully.${NC}"
else
  echo -e "${RED}Failed to finalize setup.${NC}"
fi

# Install Brave web browser.
echo -e "${BLUE}Installing Brave web browser...${NC}"
sudo nala install curl && sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list > /dev/null
sudo nala update && sudo nala install brave-browser -y
if [ $? -eq 0 ]; then
  echo -e "${GREEN}Brave browser installed successfully.${NC}"
else
  echo -e "${RED}Failed to install Brave browser.${NC}"
fi

# Install grub theme.
echo -e "${BLUE}Installing GRUB theme...${NC}"
cd && git clone https://github.com/vinceliuice/grub2-themes.git
cd grub2-themes && sudo ./install.sh -t stylish
echo "GRUB_DISABLE_SUBMENU=y" | sudo tee -a /etc/default/grub > /dev/null
cd && rm -rf grub2-themes
if [ $? -eq 0 ]; then
  echo -e "${GREEN}GRUB theme installed successfully.${NC}"
else
  echo -e "${RED}Failed to install GRUB theme.${NC}"
fi

# Enable GRUB_DISABLE_RECOVERY in /etc/default/grub.
echo -e "${BLUE}Enabling GRUB recovery settings...${NC}"
sudo chmod o+w /etc/default/grub
sudo sed -i s/#GRUB_DISABLE_RECOVERY/GRUB_DISABLE_RECOVERY/g /etc/default/grub
sudo chmod o-w /etc/default/grub
if [ $? -eq 0 ]; then
  echo -e "${GREEN}GRUB recovery settings enabled successfully.${NC}"
else
  echo -e "${RED}Failed to enable GRUB recovery settings.${NC}"
fi

# Install icon theme.
echo -e "${BLUE}Installing Papirus icon theme...${NC}"
sudo nala install papirus-icon-theme -y
if [ $? -eq 0 ]; then
  echo -e "${GREEN}Papirus icon theme installed successfully.${NC}"
else
  echo -e "${RED}Failed to install Papirus icon theme.${NC}"
fi

# Update environment variables.
echo -e "${BLUE}Updating environment variables...${NC}"
sudo tee /etc/environment > /dev/null << EOF
BROWSER=brave
EDITOR=vim
EOF
if [ $? -eq 0 ]; then
  echo -e "${GREEN}Environment variables updated successfully.${NC}"
else
  echo -e "${RED}Failed to update environment variables.${NC}"
fi

# Install Liquorix kernel.
echo -e "${BLUE}Installing Liquorix kernel...${NC}"
curl -s 'https://liquorix.net/install-liquorix.sh' | sudo bash
if [ $? -eq 0 ]; then
  echo -e "${GREEN}Liquorix kernel installed successfully.${NC}"
else
  echo -e "${RED}Failed to install Liquorix kernel.${NC}"