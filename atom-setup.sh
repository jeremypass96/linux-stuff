#!/bin/bash
apm install atom-ui-tweaks
mkdir /home/$USER/.atom
sudo mkdir /etc/skel/.atom
cp -v /home/$USER/linux-stuff/Dotfiles/.atom/config.cson /home/$USER/.atom/config.cson
sudo cp -v /home/$USER/linux-stuff/Dotfiles/.atom/config.cson /etc/skel/.atom/config.cson
