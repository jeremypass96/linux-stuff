#!/bin/bash
# This shell script sets up an Apline Linux install with a minimal KDE install.

# Checking to see if we're running as root.
if [ $(id -u) -ne 0 ]; then
echo "Please run this script as root via 'su' or 'sudo'! Thanks."
exit
fi

# Audio buzz/hum fix.
echo "options snd-hda-intel power_save=0 power_save_controller=N" >> /etc/modprobe.d/alsa-base.conf

# Setup APK cache.
setup-apkcache /var/cache/apk

# Install base packages.
apk add linux-edge util-linux pciutils usbutils coreutils binutils findutils mandoc man-pages mandoc-apropos zsh zsh-vcs udisks2 bash bash-completion neofetch btop micro alsa-utils alsa-lib alsaconf alsa-ucm-conf doas-sudo-shim ntfs-3g ntfs-3g-progs lsd fd fd-zsh-completion bat bat-zsh-completion

# Install fonts.
apk add terminus-font ttf-inconsolata ttf-dejavu font-bitstream-100dpi font-bitstream-75dpi font-bitstream-type1 font-noto ttf-font-awesome font-noto-extra font-croscore font-adobe-source-code-pro font-ibm-plex-mono-nerd ttf-opensans ttf-linux-libertine ttf-liberation ttf-droid font-cursor-misc font-ibm-type1 nerd-fonts
fc-cache -f

# Install Xorg.
setup-xorg-base

clear

read -p "What video card do you have installed on your computer?
1.) AMD GPU
2.) ATI Radeon
3.) NVIDIA
4.) Intel
5.) VirtualBox
6.) VMware
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
rc-update add virtualbox-guest-additions && rc-service virtualbox-guest-additions start
fi
if [ "$resp" = 6 ]; then
apk add xf86-video-vmware xf86-input-vmmouse open-vm-tools open-vm-tools-openrc
rc-update add open-vm-tools && rc-service open-vm-tools start
fi

read -p "Do you have an AMD CPU installed? (y/n) " resp
if [ "$resp" = y ]; then
apk add linux-firmware-amd linux-firmware-amd-ucode
fi
if [ "$resp" = n ]; then
continue
fi

# Install KDE.
apk add plasma kde-applications-base oxygen-sounds kcalc kcharselect kdf kwalletmanager kdeconnect juk print-manager sweeper papirus-icon-theme elogind polkit-elogind polkit-openrc

# Clean package cache.
apk cache clean

# Remove Linux LTS kernel.
apk del linux-lts

# Enable services.
rc-update add dbus && rc-service dbus start
rc-update add elogind && rc-service elogind start
rc-update add polkit && rc-service polkit start
rc-update add udev && rc-service udev start
rc-update add networkmanager && rc-service networkmanager start
rc-update add sddm
rc-update add alsa && rc-service alsa start

# Add users to groups.
addgroup $USER audio
addgroup root audio
addgroup $USER plugdev
addgroup $USER cdrom

# Install other software.
apk add vlc-qt transmission pinta inkscape chromium k3b

# Prettify /etc/os-release (add logo line)
echo "LOGO=distributor-logo-alpine" >> /etc/os-release

# Update repos to "latest-stable" and upgrade the Alpine package manager.
setup-apkrepos -f
sed -i 's|https://dl-cdn.alpinelinux.org/alpine/v*.*/main|https://dl-cdn.alpinelinux.org/alpine/latest-stable/main|g' /etc/apk/repositories
sed -i 's|#https://dl-cdn.alpinelinux.org/alpine/v*.*/community|https://dl-cdn.alpinelinux.org/alpine/latest-stable/community|g' /etc/apk/repositories
sed -i 's|https://*.*.*/alpine/v*.*/main|https://dl-cdn.alpinelinux.org/alpine/latest-stable/main|g' /etc/apk/repositories
sed -i 's|#https://*.*.*/alpine/v*.*/community|https://dl-cdn.alpinelinux.org/alpine/latest-stable/community|g' /etc/apk/repositories
apk update
apk add --upgrade apk-tools

# Upgrade everything else.
apk upgrade --available
sync

echo "If everything was successful, go ahead and reboot!"
