#!/bin/bash
sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
git clone https://github.com/zsh-users/zsh-autosuggestions.git /home/$USER/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /home/$USER/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
cp -v /home/$USER/linux-stuff/Dotfiles/.zshrc /home/$USER/.zshrc

# Setup Catppuccin colors.
cd
git clone https://github.com/catppuccin/zsh-syntax-highlighting.git
cd zsh-syntax-highlighting/themes/
sudo mkdir -p /usr/local/etc/zsh
sudo cp -v *.zsh /usr/local/etc/zsh
sudo chown $USER:$USER /usr/local/etc/zsh/*.zsh
read -p "Which Catppuccin colors do you want for syntax highlighting?
1.) Latte
2.) Frappé
3.) Macchiato
4.) Mocha
-> " resp
if [ "$resp" = 1 ]; then
echo source /usr/local/etc/zsh/catppuccin_latte-zsh-syntax-highlighting.zsh >> /home/$USER/.zshrc
fi
if [ "$resp" = 2 ]; then
echo source /usr/local/etc/zsh/catppuccin_frappe-zsh-syntax-highlighting.zsh >> /home/$USER/.zshrc
fi
if [ "$resp" = 3 ]; then
echo source /usr/local/etc/zsh/catppuccin_macchiato-zsh-syntax-highlighting.zsh >> /home/$USER/.zshrc
fi
if [ "$resp" = 4 ]; then
echo source /usr/local/etc/zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh >> /home/$USER/.zshrc
fi
cd && rm -rf zsh-syntax-highlighting
sudo cp -v /home/$USER/.zshrc /etc/skel/.zshrc
sudo cp -v /etc/skel/.zshrc /root/.zshrc
echo pfetch >> /home/$USER/.zshrc
