#!/bin/bash
# This script cleans up an Arch Linux KDE install installed with "archinstall." Must be run as root!

# Checking to see if we're running as root.
if [ $(id -u) -ne 0 ]; then
echo "Please run this script as root! Thanks."
exit
fi

# Update environment variables.
# Configure pfetch.
echo PF_INFO='"ascii os kernel uptime pkgs shell de memory"' >> /etc/environment
# Set BROWSER variable.
echo BROWSER=/usr/bin/brave >> /etc/environment
# Set EDITOR variable.
echo EDITOR=/usr/bin/micro >> /etc/environment
# Set MICRO_TRUECOLOR variable.
echo MICRO_TRUECOLOR=1 >> /etc/environment

# Fix /etc/os-release logo line.
sed -i 's/LOGO=archlinux-logo/LOGO=distributor-logo-archlinux'/g /etc/os-release
