#!/bin/bash
# This shell script sets up an Apline Linux install with a minimal KDE install.

# Checking to see if we're running as root.
if [ $(id -u) -ne 0 ]; then
echo "Please run this script as root via 'su' or 'sudo'! Thanks."
exit
fi

# Setup APK cache.
setup-apkcache /var/cache/apk

# Update repos to "latest-stable" and upgrade the Alpine package manager.
setup-apkrepos
apk update
apk add --upgrade apk-tools

# Install base packages.
apk add linux-edge util-linux pciutils usbutils coreutils binutils findutils mandoc man-pages mandoc-apropos zsh zsh-vcs udisks2 bash bash-completion neofetch btop micro alsa-utils alsa-lib alsaconf alsa-ucm-conf doas-sudo-shim ntfs-3g ntfs-3g-progs

# Install fonts.
apk add terminus-font ttf-inconsolata ttf-dejavu font-bitstream-100dpi font-bitstream-75dpi font-bitstream-type1 font-noto ttf-font-awesome font-noto-extra font-croscore font-adobe-source-code-pro font-ibm-plex-mono-nerd ttf-opensans ttf-linux-libertine ttf-liberation ttf-droid font-cursor-misc font-ibm-type1
fc-cache -f

# Install Xorg.
setup-xorg-base

# Add users to audio group.
addgroup $USER audio
addgroup root audio

clear

read -p "What video card do you have installed on your computer?
1.) AMD GPU
2.) ATI Radeon
3.) NVIDIA
4.) Intel
5.) VirtualBox
6.) VMware
7.) S3 Savage
8.) ATI Rage128
9.) 3Dfx
10.) S3 ViRGE
11.) Intel i740
12.) Chips and Technologies
13.) SiS
14.) VIA/S3G

0.) Not listed!
–> " resp
if [ "$resp" = 1 ]; then
apk add xf86-video-amdgpu linux-firmware-amdgpu
fi
if [ "$resp" = 2 ]; then
apk add xf86-video-ati linux-firmware-radeon
fi
if [ "$resp" = 3 ]; then
apk add xf86-video-nv linux-firmware-nvidia
fi
if [ "$resp" = 4 ]; then
apk add xf86-video-intel linux-firmware-i915
fi
if [ "$resp" = 5 ]; then
apk add xf86-video-vmware virtualbox-guest-additions virtualbox-guest-additions-x11
rc-update add virtualbox-guest-additions
rc-service virtualbox-guest-additions start
fi
if [ "$resp" = 6 ]; then
apk add xf86-video-vmware xf86-input-vmmouse open-vm-tools open-vm-tools-openrc
rc-update add open-vm-tools
rc-service open-vm-tools start
fi
if [ "$resp" = 7 ]; then
apk add xf86-video-savage
fi
if [ "$resp" = 8 ]; then
apk add xf86-video-r128 linux-firmware-r128
fi
if [ "$resp" = 9 ]; then
apk add xf86-video-tdfx
fi
if [ "$resp" = 10 ]; then
apk add xf86-video-s3virge
fi
if [ "$resp" = 11 ]; then
apk add xf86-video-i740
fi
if [ "$resp" = 12 ]; then
apk add xf86-video-chips
fi
if [ "$resp" = 13 ]; then
apk add xf86-video-sis
fi
if [ "$resp" = 14 ]; then
apk add xf86-video-openchrome
fi
if [ "$resp" = 0 ]; then
continue
fi

read -p "Do you have an AMD CPU installed? (y/n) " resp
if [ "$resp" = y ]; then
apk add linux-firmware-amd linux-firmware-amd-ucode
fi
if [ "$resp" = n ]; then
continue
fi

# Install KDE.
apk add plasma kde-applications-base kcalc kcharselect kdf kwalletmanager juk print-manager sweeper papirus-icon-theme elogind polkit-elogind polkit-openrc dbus

# Clean package cache.
apk cache clean

# Remove Linux LTS kernel.
apk del linux-lts

# Enable services.
rc-update add dbus
rc-update add elogind
rc-update add polkit
rc-update add udev
rc-update add networkmanager
rc-update add sddm
rc-service alsa start
rc-update add alsa

# Add users to groups.
addgroup $USER audio
addgroup root audio
addgroup $USER plugdev
addgroup $USER cdrom

# Upgrade everything else.
apk upgrade --available
sync

# Install other software.
apk add vlc-qt transmission pinta inkscape chromium k3b

# Prettify /etc/os-release (add logo line)
echo "LOGO=distributor-logo-alpine" >> /etc/os-release

echo "If everything was sucessfull, go ahead and reboot!"
