#!/bin/bash
# This script cleans up and makes bootup faster.

# Checking to see if we're running as root.
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script as root! Thanks."
    exit 1
fi

services_to_disable=(
    NetworkManager-wait-online.service
    pppd-dns.service
    wpa_supplicant.service
    lvm2-monitor.service
    systemd-udev-settle.service
    bluetooth.service
    brltty.service
    debug-shell.service
    ModemManager.service
)

for service in "${services_to_disable[@]}"; do
    if [ "$service" = "lvm2-monitor.service" ]; then
        systemctl mask "$service"
    else
        systemctl disable "$service"
        systemctl stop "$service"
    fi
done

echo "Services have been disabled and stopped (except lvm2-monitor.service, which has been masked) to help improve bootup speed."
