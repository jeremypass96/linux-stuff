#!/bin/bash
# This script sets up Vim with the "one" colorscheme and the Lightline plugin for Linux.

# Install vim-plug.
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
sudo mkdir -p /etc/skel/.vim/autoload
sudo cp -v ~/.vim/autoload/plug.vim /etc/skel/.vim/autoload/plug.vim

# Configure the vimrc file.
vimrc_path=~/.vim/vimrc
tee $vimrc_path > /dev/null << EOF
set number
set cursorline
set linebreak
set incsearch
set hlsearch
set spell
set smoothscroll
set termguicolors

call plug#begin('~/.vim/plugged')
Plug 'itchyny/lightline.vim'
Plug 'ayu-theme/ayu-vim'
Plug 'jiangmiao/auto-pairs'
call plug#end()

let g:lightline = {'colorscheme': 'ayu_mirage'}
let g:one_allow_italics = 1
let ayucolor="mirage"
colorscheme ayu
set laststatus=2
set noshowmode
set guifont=JetBrainsMonoNL\ NFM:h12:cDEFAULT
set lines=34
set columns=117
set backspace=indent,eol,start
EOF

# Configure vim.
vim -es -u $vimrc_path -i NONE -c "PlugInstall" -c "qa"
sudo cp -r ~/.vim/plugged /etc/skel/.vim/plugged
