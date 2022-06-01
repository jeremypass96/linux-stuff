#!/bin/bash
git clone https://github.com/zsh-users/zsh-autosuggestions.git /home/$USER/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /home/$USER/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
cp -v /home/$USER/linux-stuff/Dotfiles/.zshrc /home/$USER/.zshrc
sudo cp -v /home/$USER/.zshrc /etc/skel/.zshrc
