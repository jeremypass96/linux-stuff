#!/bin/bash
# This script automates the installation of Gentoo Linux with a distribution binary kernel.

# Checking to see if we're running as root.
if [ $(id -u) -ne 0 ]; then
    echo "Please run this Gentoo installation script as root! Thanks."
    exit
fi

# Configure CPU flags.
emerge --ask --oneshot app-portage/cpuid2cpuflags
echo "*/* $(cpuid2cpuflags)" > /etc/portage/package.use/00cpu-flags

# Configure VIDEO_CARDS variable.
echo 'VIDEO_CARDS="amdgpu radeonsi"' >> /etc/portage/make.conf

# Configure ACCEPT_LICENSE variable.
cat << EOF >> /etc/portage/make.conf
# Overrides the profile's ACCEPT_LICENSE default value
ACCEPT_LICENSE="-* @BINARY-REDISTRIBUTABLE @EULA"
EOF

# Update the @world set
emerge --ask --verbose --update --deep --newuse @world
emerge --ask --depclean

# Configure system settings (e.g., timezone, locale)

# Set timezone
echo "America/Detroit" > /etc/timezone
emerge --config sys-libs/timezone-data

# Configure locale
cat << EOF >> /etc/locale.gen
en_US ISO-8859-1
en_US.UTF-8 UTF-8
EOF
locale-gen
eselect locale list
eselect locale set 3

# Apply environment changes
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"

# Install Linux firmware
emerge --ask sys-kernel/linux-firmware

# Add lines to package.use file
echo "sys-kernel/installkernel dracut uki" > /etc/portage/package.use/installkernel
echo "sys-kernel/installkernel grub" >> /etc/portage/package.use/installkernel
echo "sys-apps/systemd-utils boot kernel-install" > /etc/portage/package.use/systemd-utils
echo "*/* dist-kernel" > /etc/portage/package.use/module-rebuild

# Configure UKI.
cat << EOF >> /etc/dracut.conf
uefi="yes"
kernel_cmdline="nowatchdog nmi_watchdog=0 loglevel=3 lsm=landlock,lockdown,yama,integrity,apparmor,bpf udev.log_level=3"
EOF

# Install sys-apps/installkernel
emerge --ask sys-apps/installkernel

# Update environment variables
env-update

# Install Gentoo binary kernel
emerge --ask sys-kernel/gentoo-kernel-bin

cat << EOF >> /etc/fstab
/dev/sda1   /efi        vfat     umask=0077           0 2
/swapfile   none        swap     sw                   0 0
/dev/sda3   /           xfs      defaults,noatime     0 1

/dev/cdrom  /mnt/cdrom   auto    noauto,user          0 0
EOF

# Generate hostname
echo "GentooBox" > /etc/hostname

# Configure networking

# Install dhcpcd
emerge --ask net-misc/dhcpcd
rc-update add dhcpcd default
rc-service dhcpcd start

emerge --ask --noreplace net-misc/netifrc
echo config_eth0="dhcp" >> /etc/conf.d/net
cd /etc/init.d
ln -s net.lo net.eth0
rc-update add net.eth0 default

# Set clock configuration
sed -i 's/clock=UTC/clock=local/' /etc/conf.d/hwclock

# Install system logger
emerge --ask app-admin/sysklogd
rc-update add sysklogd default

# Install cron daemon
emerge --ask sys-process/dcron
crontab /etc/crontab

# Add file indexing
emerge --ask sys-apps/plocate

# Install Chrony
emerge --ask net-misc/chrony
rc-update add chronyd default

# Add IO Scheduler udev rules
emerge --ask sys-block/io-scheduler-udev-rules

# Install bootloader
emerge --ask --verbose sys-boot/grub
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# Ask the user if they are on a laptop and want to install wireless tools
read -p "Are you on a laptop and want to install wireless networking tools? (y/N): " install_wireless
if [[ ${install_wireless:-n} == "y" ]]; then
    emerge --ask net-wireless/iw net-wireless/wpa_supplicant
fi

# Set the root password
passwd

# Exit the chroot environment
exit

# Unmount partitions
umount -l /mnt/gentoo/dev{/shm,/pts,}
umount -R /mnt/gentoo

# Reboot the system
reboot