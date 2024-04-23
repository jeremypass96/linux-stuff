#!/bin/bash
# This script automates the installation of Gentoo Linux with a distribution binary kernel.

# Checking to see if we're running as root.
if [ $(id -u) -ne 0 ]; then
    echo "Please run this Gentoo installation script as root! Thanks."
    exit
fi

# Test if we have a network connection using Google's public IP address.
ping -c 4 8.8.8.8

# Test HTTPS access and DNS resolution.
curl --location gentoo.org --output /dev/null

# Set variables for customization
EFI_PARTITION="/dev/sda1"
ROOT_PARTITION="/dev/sda2"
HOSTNAME="GentooBox"

# Update the system clock
chronyd -q

# Partition the disk
parted -s select /dev/sda
parted -s mklabel gpt
parted -s "$EFI_PARTITION" mkpart primary fat32 1MiB 1GiB
parted -s "$ROOT_PARTITION" mkpart primary xfs 1MiB 100%
parted -s set "$ROOT_PARTITION" root on

# Format the partitions
mkfs.vfat -F 32 "$EFI_PARTITION"
mkfs.xfs "$ROOT_PARTITION"

# Make swap file and activate it.
dd if=/dev/zero of=/swapfile bs=1MB count=8192
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

# Mount the root partition
mkdir --parents /mnt/gentoo/efi
mount "$ROOT_PARTITION" /mnt/gentoo

# Enter the /mnt/gentoo directory
cd /mnt/gentoo

# Download and extract the Gentoo stage3 tarball
wget https://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64-desktop-openrc/stage3-amd64-desktop-openrc-20240421T170413Z.tar.xz
wget https://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64-desktop-openrc/stage3-amd64-desktop-openrc-20240421T170413Z.tar.xz.CONTENTS.gz
wget https://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64-desktop-openrc/stage3-amd64-desktop-openrc-20240421T170413Z.tar.xz.DIGESTS
wget https://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64-desktop-openrc/stage3-amd64-desktop-openrc-20240421T170413Z.tar.xz.sha256
wget https://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64-desktop-openrc/stage3-amd64-desktop-openrc-20240421T170413Z.tar.xz.asc
sha256sum --check stage3-amd64-desktop-openrc-20240421T170413Z.tar.xz.sha256
gpg --import /usr/share/openpgp-keys/gentoo-release.asc
gpg --verify stage3-amd64-desktop-openrc-20240421T170413Z.tar.xz.asc
gpg --verify stage3-amd64-desktop-openrc-20240421T170413Z.tar.xz.DIGESTS
gpg --verify stage3-amd64-desktop-openrc-20240421T170413Z.tar.xz.sha256
tar xpvf stage3-amd64-desktop-openrc-20240421T170413Z.tar.xz --xattrs-include='*.*' --numeric-owner

# Configure compile MAKEOPTS.
echo 'MAKEOPTS="-j8"' >> /etc/portage/make.conf

# Copy DNS info to the new system
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/

# Mount necessary filesystems
arch-chroot /mnt/gentoo

# Chroot into the new environment
chroot /mnt/gentoo /bin/bash
source /etc/profile
export PS1="(chroot) $PS1"

# Prepare bootloader.
mkdir /efi
mount /dev/sda1 /efi

# Configure portage.
mkdir --parents /etc/portage/repos.conf
cp /usr/share/portage/config/repos.conf /etc/portage/repos.conf/gentoo.conf

# Update the Gentoo ebuild repository
emerge-webrsync

# Select mirrors.
emerge --verbose --oneshot app-portage/mirrorselect
mirrorselect -i -o >> /etc/portage/make.conf

# Update repository.
emerge --sync

# View system profile.
eselect profile list

echo "This ends part 1 of the Gentoo installation script. Run ./install_gentoo_pt2.sh for part 2."
