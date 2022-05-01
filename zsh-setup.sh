#!/bin/bash
sudo nala install -y zsh
cp -v /home/$USER/linux-stuff/Dotfiles/.zshrc /home/$USER/.zshrc
cp -v /home/$USER/.zshrc /etc/skel/.zshrc
git clone https://github.com/zsh-users/zsh-autosuggestions.git /home/$USER/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /home/$USER/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
