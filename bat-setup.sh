#!/bin/bash
bat --generate-config-file
sed -i s/#--theme='"TwoDark"'/--theme='"1337"'/g /home/$USER/.config/bat/config
sed -i s/#--italic-text=always/--italic-text=always/g /home/$USER/.config/bat/config
sudo mkdir -p /etc/skel/.config/bat && sudo cp -v /home/$USER/.config/bat/config /etc/skel/.config/bat
