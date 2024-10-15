#!/bin/bash
# This script sets up Vim with the "one" colorscheme and the Lightline plugin for Arch Linux.

# Install the Lightline plugin manager, vim-plug, and colorschemes.
paru -S vim-lightline-git vim-plug vim-colors-night-git --noconfirm

# Configure the vimrc file.
vimrc_path=/etc/vimrc
sudo chmod o+x $vimrc_path
cat << EOF >> $vimrc_path
set number
set cursorline
set linebreak
set incsearch
set hlsearch
set spell
set smoothscroll
set termguicolors

let g:lightline = {'colorscheme': 'one'}
let g:one_allow_italics = 1
colorscheme one
set laststatus=2
set noshowmode
EOF
chmod o-x $vimrc_path
