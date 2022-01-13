#!/bin/bash
# This script cleans up and makes bootup faster.

# Checking to see if we're running as root.
if [ $(id -u) -ne 0 ] ; then
echo "Please run this script as root! Thanks."
exit
fi

systemctl disable NetworkManager-wait-online.service
systemctl disable pppd-dns.service
systemctl disable wpa_supplicant.service
systemctl mask lvm2-monitor.service
systemctl disable systemd-udev-settle.service
systemctl mask accounts-daemon.service
systemctl stop bluetooth.service
systemctl disable bluetooth.service
systemctl disable brltty.service
systemctl disable debug-shell.service
systemctl disable ModemManager.service