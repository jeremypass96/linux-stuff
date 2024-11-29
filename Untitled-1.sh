#!/bin/bash
# Define color codes
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}Stopping mkinitcpio from generating a fallback kernel image...${NC}"

# Check for the 'arch' kernel and use 'linux' preset
if uname -r | grep -q "arch"; then
    # Handle the 'arch' kernel using 'linux' preset
    preset="/etc/mkinitcpio.d/linux.preset"
    image="/boot/initramfs-linux-fallback.img"

    # Disable fallback image generation
    sudo sed -i "s/'PRESETS=('default' 'fallback')'/'PRESETS=('default')'/g" "$preset"
    sudo sed -i "s|fallback_image=\"$image\"|#fallback_image=\"$image\"|g" "$preset"
    sudo sed -i 's/fallback_options="-S autodetect"/#fallback_options="-S autodetect"/g' "$preset"

    # Regenerate initramfs and clean up
    sudo mkinitcpio -p linux
    sudo rm "$image"
    sudo grub-mkconfig -o /boot/grub/grub.cfg
fi

# Loop through other kernel types (hardened, lts, zen, realtime, rt-lts)
kernels=("hardened" "lts" "zen" "realtime" "rt-lts")
for kernel in "${kernels[@]}"; do
    if uname -r | grep -q "$kernel"; then
        preset="/etc/mkinitcpio.d/$kernel.preset"
        image="/boot/initramfs-$kernel-fallback.img"

        # Disable fallback image generation
        sudo sed -i "s/'PRESETS=('default' 'fallback')'/'PRESETS=('default')'/g" "$preset"
        sudo sed -i "s|fallback_image=\"$image\"|#fallback_image=\"$image\"|g" "$preset"
        sudo sed -i 's/fallback_options="-S autodetect"/#fallback_options="-S autodetect"/g' "$preset"

        # Regenerate initramfs and clean up
        sudo mkinitcpio -p "$kernel"
        sudo rm "$image"
        sudo grub-mkconfig -o /boot/grub/grub.cfg
    fi
done