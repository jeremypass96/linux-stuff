#!/bin/bash
# This script sets up Vim with the "one" colorscheme and the Lightline plugin for Arch Linux.
# install the lightline plugin manager, vim-plug, and colorschemes.
paru -S vim-lightline-git vim-plug vim-ayu-git vim-auto-pairs-git  --noconfirm

# Configure the vimrc file.
sudo tee -a /etc/vimrc > /dev/null << EOF
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