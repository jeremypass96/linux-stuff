#!/bin/bash
# Simple one-liner script to enable and start SDDM after a Void Linux install.

# Checking to see if we're running as root.
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script as root via 'sudo'! Thanks."
    exit
fi

ln -s /etc/sv/sddm /var/service/sddm