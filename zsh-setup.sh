#!/bin/bash
sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
cp -v /home/$USER/linux-stuff/Dotfiles/.zshrc /home/$USER/.zshrc
sudo cp -v /home/$USER/.zshrc /etc/skel/.zshrc
