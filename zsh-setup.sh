#!/bin/bash

# Install Oh My Zsh and change shell to Zsh
sudo ZSH=/usr/share/oh-my-zsh sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
chsh -s /usr/bin/zsh "$USER"

# Set proper permissions.
sudo chmod 755 /usr/share/oh-my-zsh
sudo chmod 755 /usr/share/oh-my-zsh/oh-my-zsh.sh
sudo chmod 755 /usr/share/oh-my-zsh/cache
sudo chmod 755 /usr/share/oh-my-zsh/custom
sudo chmod -R 755 /usr/share/oh-my-zsh/lib
sudo chmod -R 755 /usr/share/oh-my-zsh/log
sudo chmod -R 755 /usr/share/oh-my-zsh/plugins
sudo chmod -R 755 /usr/share/oh-my-zsh/templates
sudo chmod -R 755 /usr/share/oh-my-zsh/themes
sudo chmod -R 755 /usr/share/oh-my-zsh/tools

# Clone and set up zsh-autosuggestions and zsh-syntax-highlighting plugins
ZSH_CUSTOM=/usr/share/oh-my-zsh/custom
sudo git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM}/plugins/zsh-autosuggestions
sudo git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting
unset ZSH_CUSTOM
sudo chmod 755 /usr/share/oh-my-zsh/custom/plugins/zsh-autosuggestions
sudo chmod 755 /usr/share/oh-my-zsh/custom/plugins/zsh-autosuggestions/*.zsh
sudo chmod 755 /usr/share/oh-my-zsh/custom/plugins/zsh-syntax-highlighting
sudo chmod -R 755 /usr/share/oh-my-zsh/custom/plugins/zsh-syntax-highlighting/docs
sudo chmod -R 755 /usr/share/oh-my-zsh/custom/plugins/zsh-syntax-highlighting/highlighters
sudo chmod -R 755 /usr/share/oh-my-zsh/custom/plugins/zsh-syntax-highlighting/images
sudo chmod -R 755 /usr/share/oh-my-zsh/custom/plugins/zsh-syntax-highlighting/tests
sudo chmod 755 /usr/share/oh-my-zsh/custom/plugins/zsh-syntax-highlighting/*.zsh
sudo chmod 755 /usr/share/oh-my-zsh/custom/plugins/zsh-syntax-highlighting/.*

# Copy .zshrc configuration
cp -v "$HOME"/linux-stuff/Dotfiles/.zshrc "$HOME"/.zshrc

# Copy custom Oh My Zsh theme.
sudo cp -v "$HOME"/linux-stuff/jpassarelli.zsh-theme /usr/share/oh-my-zsh/custom/themes

# Setup Catppuccin syntax highlighting colors
read -rp "Do you want to setup syntax highlighting colors with the Catppuccin colorscheme? (y/N) " resp
resp=${resp:-N}

if [ "$resp" = y ]; then
    cd || exit
    git clone https://github.com/catppuccin/zsh-syntax-highlighting.git
    sudo mkdir -p /usr/local/etc/zsh
    sudo cp -v zsh-syntax-highlighting/themes/*.zsh /usr/local/etc/zsh
    sudo chmod -R 755 /usr/local/etc

    # Choose Catppuccin color scheme for syntax highlighting
    echo "Choose Catppuccin colors for syntax highlighting:"
    select scheme in "Latte" "Frappé" "Macchiato" "Mocha"; do
        case $scheme in
        Latte)
            echo "source /usr/local/etc/zsh/catppuccin_latte-zsh-syntax-highlighting.zsh" >> "$HOME"/.zshrc
            break
            ;;
        Frappé)
            echo "source /usr/local/etc/zsh/catppuccin_frappe-zsh-syntax-highlighting.zsh" >> "$HOME"/.zshrc
            break
            ;;
        Macchiato)
            echo "source /usr/local/etc/zsh/catppuccin_macchiato-zsh-syntax-highlighting.zsh" >> "$HOME"/.zshrc
            break
            ;;
        Mocha)
            echo "source /usr/local/etc/zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh" >> "$HOME"/.zshrc
            break
            ;;
        *)
            echo "Invalid selection. Please choose a valid option."
            ;;
        esac
    done
else
    echo "Continuing..."
fi

# Clean up and copy configurations for future users and root
rm -rf zsh-syntax-highlighting
sudo cp -v "$HOME"/.zshrc /etc/skel/.zshrc
sudo cp -v /etc/skel/.zshrc /root/.zshrc

# Add 'fastfetch' to .zshrc
echo fastfetch >> "$HOME"/.zshrc

# Change root's shell.
sudo chsh -s /usr/bin/zsh root

echo "Zsh has been sucessfully set up."