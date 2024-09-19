#!/bin/bash
# This script sets up Vim with the "onehalfdark" colorscheme and the Lightline plugin for Linux.

# Install vim-plug.
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
sudo mkdir -p /etc/skel/.vim/autoload
sudo cp -v ~/.vim/autoload/plug.vim /etc/skel/.vim/autoload/plug.vim

# Configure the vimrc file.
sudo touch /etc/vimrc
vimrc_path=/etc/vimrc
sudo chmod o+w $vimrc_path
cat << EOF >> $vimrc_path
set number
set cursorline
set linebreak
set incsearch
set hlsearch
set spell
set smoothscroll
set termguicolors

call plug#begin()
Plug 'itchyny/lightline.vim'
call plug#end()

let g:lightline = {'colorscheme': 'one'}
colorscheme onehalfdark
set laststatus=2
set noshowmode
EOF
chmod o-w $vimrc_path
