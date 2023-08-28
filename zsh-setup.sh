#!/bin/bash

# Install Oh My Zsh and change shell to Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
chsh -s /usr/bin/zsh $USER

# Clone and set up zsh-autosuggestions and zsh-syntax-highlighting plugins
git clone https://github.com/zsh-users/zsh-autosuggestions.git /home/$USER/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /home/$USER/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# Copy .zshrc configuration
cp -v /home/$USER/linux-stuff/Dotfiles/.zshrc /home/$USER/.zshrc

# Setup Catppuccin syntax highlighting colors
cd "$HOME" || exit
git clone https://github.com/catppuccin/zsh-syntax-highlighting.git
cd zsh-syntax-highlighting/themes/
sudo mkdir -p /usr/local/etc/zsh
sudo cp -v *.zsh /usr/local/etc/zsh
sudo chown $USER:$USER /usr/local/etc/zsh/*.zsh

# Choose Catppuccin color scheme for syntax highlighting
echo "Choose Catppuccin colors for syntax highlighting:"
select scheme in "Latte" "Frappé" "Macchiato" "Mocha"; do
    case $scheme in
        Latte)
            echo "source /usr/local/etc/zsh/catppuccin_latte-zsh-syntax-highlighting.zsh" >> /home/$USER/.zshrc
            break
            ;;
        Frappé)
            echo "source /usr/local/etc/zsh/catppuccin_frappe-zsh-syntax-highlighting.zsh" >> /home/$USER/.zshrc
            break
            ;;
        Macchiato)
            echo "source /usr/local/etc/zsh/catppuccin_macchiato-zsh-syntax-highlighting.zsh" >> /home/$USER/.zshrc
            break
            ;;
        Mocha)
            echo "source /usr/local/etc/zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh" >> /home/$USER/.zshrc
            break
            ;;
        *)
            echo "Invalid selection. Please choose a valid option."
            ;;
    esac
done

# Clean up and copy configurations for future users and root
cd && rm -rf zsh-syntax-highlighting
sudo cp -v /home/$USER/.zshrc /etc/skel/.zshrc
sudo cp -v /etc/skel/.zshrc /root/.zshrc

# Add 'pfetch' to .zshrc
echo "pfetch" >> /home/$USER/.zshrc

echo "Zsh and related configurations have been set up with the chosen Catppuccin syntax highlighting."
