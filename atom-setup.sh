#!/bin/bash
apm install atom-ui-tweaks
cp -rv /home/$USER/linux-stuff/Dotfiles/.atom /home/$USER/.atom
sudo cp -rv /home/$USER/linux-stuff/Dotfiles/.atom /etc/skel/.atom
