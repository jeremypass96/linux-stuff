#!/bin/bash
bat --generate-config-file
sed -i s/#--theme="TwoDark"/--theme="1337"/g /home/$USER/.config/bat/config
sed -i s/#--italic-text=always/--italic-text=always/g /home/$USER/.config/bat/config
