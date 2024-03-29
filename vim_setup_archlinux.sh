#!/bin/bash
# This script sets up Vim with the "sorbet" colorscheme and the Lightline plugin for Arch Linux.

# Install Vim.
sudo pacman -S vim --noconfirm

# Install the Lightline plugin manager and vim-plug.
paru -S vim-lightline-git vim-plug --noconfirm

# Configure the vimrc file.
vimrc_path=/etc/vimrc
sudo chmod o+x $vimrc_path
cat << EOF >> $vimrc_path
set number
set cursorline
set smoothscroll
set termguicolors

let g:lightline = {'colorscheme': 'one'}
colorscheme sorbet
set laststatus=2
set noshowmode
EOF
chmod o-x $vimrc_path
