#!/bin/bash
# This script sets up Vim with the "one" colorscheme and the Lightline plugin for Arch Linux.
tt
# install the lightline plugin manager, vim-plug, and colorschemes.
paru -s vim-lightline-git vim-plug vim-ayu-git --noconfirm

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

let g:lightline = {'colorscheme': 'ayu_mirage'}
let g:one_allow_italics = 1
let ayucolor="mirage"
colorscheme ayu
set laststatus=2
set noshowmode
EOF
chmod o-x $vimrc_path
