#!/bin/bash

# Define color codes
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m' # No color

# Checking to see if we're running as root.
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}Please run this script as root via 'su'! Thanks.${NC}"
    exit
fi

# Function to display messages with different colors
function echo_info {
    echo -e "${BLUE}$1${NC}"
}

function echo_success {
    echo -e "${GREEN}$1${NC}"
}

function echo_warning {
    echo -e "${YELLOW}$1${NC}"
}

function echo_error {
    echo -e "${RED}$1${NC}"
}

# Get the total installed RAM in kilobytes
TOTAL_RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')

# Convert RAM to gigabytes (GB)
TOTAL_RAM_GB=$(echo "$TOTAL_RAM_KB / 1024 / 1024" | bc)

# Calculate swap size. If RAM is larger than 8GB, create a 4GB swap file.
if [[ "$TOTAL_RAM_GB" -ge 8 ]]; then
    SWAP_SIZE_GB=4
else
    SWAP_SIZE_GB=$(echo "$TOTAL_RAM_GB * 2" | bc)
fi

# Convert swap size to megabytes (MB) for fallocate
SWAP_SIZE_MB=$(echo "$SWAP_SIZE_GB * 1024" | bc)

# Display the information
echo_info "Detected RAM: ${TOTAL_RAM_GB}GB"
echo_info "Creating a ${SWAP_SIZE_GB}GB swapfile..."

# Create the swapfile
if fallocate -l "${SWAP_SIZE_MB}M" /swapfile; then
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo_success "Swapfile created and enabled!"
else
    echo_error "Failed to create swapfile!"
    exit 1
fi

# Add swapfile to /etc/fstab for persistent swap across reboots
if ! grep -q '/swapfile' /etc/fstab; then
    echo_warning "Adding swapfile entry to /etc/fstab..."
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
fi