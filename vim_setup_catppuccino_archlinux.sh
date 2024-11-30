#!/bin/bash
# This script sets up Vim with the Catppuccino Mocha colorscheme and the Lightline plugin for Arch Linux.

# Install the Lightline plugin manager, vim-plug, and colorschemes.
paru -S vim-lightline-git vim-plug vim-colors-night-git vim-auto-pairs-git --noconfirm

# Configure the vimrc file.
vimrc_path=/etc/vimrc
sudo tee -a $vimrc_path > /dev/null << EOF
set number
set cursorline
set linebreak
set incsearch
set hlsearch
set spell
set smoothscroll
set termguicolors

let g:lightline = {'colorscheme': 'catppuccin_mocha'}
colorscheme catppuccin_mocha
set laststatus=2
set noshowmode
EOF

# Install the Lightline plugin.
sudo vim -es -u $vimrc_path -i NONE -c "PlugInstall" -c "qa"
