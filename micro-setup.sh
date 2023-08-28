#!/bin/bash

USER_HOME="$HOME"
CONFIG_DIR="$USER_HOME/.config/micro"
COLOR_SCHEMES=("Catppuccin Latte" "Catppuccin Frappé" "Catppuccin Macchiato" "Catppuccin Mocha")
SCHEME_NAMES=("catppuccin-latte" "catppuccin-frappe" "catppuccin-macchiato" "catppuccin-mocha")

# Function to copy settings and color scheme
copy_settings_and_colors() {
    # Create directory structure
    mkdir -p "$CONFIG_DIR"
    sudo mkdir -p /etc/skel/.config/micro
    sudo mkdir -p /root/.config/micro

    # Copy settings file
    cp -v "$HOME/linux-stuff/Dotfiles/config/micro/settings.json" "$CONFIG_DIR/settings.json"
    sudo cp -v "$CONFIG_DIR/settings.json" /etc/skel/.config/micro/
    sudo cp -v "$CONFIG_DIR/settings.json" /root/.config/micro/

    # Set correct ownership
    chown -R "$USER:$USER" "$CONFIG_DIR"

    # Setup Catppuccin colors
    cd "$USER_HOME" || exit
    git clone https://github.com/catppuccin/micro.git
    mkdir -p "$CONFIG_DIR/colorschemes"
    sudo mkdir -p /etc/skel/.config/micro/colorschemes
    sudo mkdir -p /root/.config/micro/colorschemes
    cp -v micro/src/*.micro "$CONFIG_DIR/colorschemes"
    sudo cp -v micro/src/*.micro /etc/skel/.config/micro/colorschemes
    sudo cp -v micro/src/*.micro /root/.config/micro/colorschemes
    rm -rf micro/

    # Install micro plugins
    micro -plugin install quoter wc

    # Update color scheme in settings
    sed -i "s/\"colorscheme\": \"[^\"]*\"/\"colorscheme\": \"$selected_scheme\"/" "$CONFIG_DIR/settings.json"

    echo "Micro text editor configuration has been set up with the \"$selected_scheme\" color scheme."
}

# Display available color schemes
echo "Available color schemes:"
for ((i=0; i<${#COLOR_SCHEMES[@]}; i++)); do
    echo "$((i+1)). ${COLOR_SCHEMES[i]}"
done

default_choice="Catppuccin Mocha"
read -p "Choose a color scheme (1-${#COLOR_SCHEMES[@]}, default: $default_choice): " choice
choice="${choice:-$default_choice}"

# Find selected scheme
selected_scheme=""
for ((i=0; i<${#COLOR_SCHEMES[@]}; i++)); do
    if [ "$choice" == "${COLOR_SCHEMES[i]}" ]; then
        selected_scheme="${SCHEME_NAMES[i]}"
        break
    fi
done

if [ -z "$selected_scheme" ]; then
    echo "Invalid choice. Using default color scheme: $default_choice"
    selected_scheme="${SCHEME_NAMES[3]}"
fi

copy_settings_and_colors
