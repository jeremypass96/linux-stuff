#!/bin/bash
# This script sets up Vim with the Catppuccino Mocha colorscheme and the Lightline plugin for Arch Linux.

# Install Vim.
sudo pacman -S vim --noconfirm

# Install lightline plugin manager and vim-plug.
paru -S vim-lightline-git vim-plug --noconfirm

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

call plug#begin('/usr/share/vim/vimfiles/plugin')
Plug 'catppuccin/vim', { 'as': 'catppuccin' }
call plug#end()

let g:lightline = {'colorscheme': 'catppuccin_mocha'}
colorscheme catppuccin_mocha
set laststatus=2
set noshowmode
EOF
chmod o-x $vimrc_path

# Install Catppuccin colors plugin.
sudo vim -es -u $vimrc_path -i NONE -c "PlugInstall" -c "qa"

# Set correct permissions.
sudo chmod 755 /usr/share/vim/vimfiles/plugin/catppuccin
sudo chmod 755 /usr/share/vim/vimfiles/plugin/catppuccin/assets
sudo chmod 755 /usr/share/vim/vimfiles/plugin/catppuccin/autoload
sudo chmod -R 755 /usr/share/vim/vimfiles/plugin/catppuccin/colors
sudo chmod 755 /usr/share/vim/vimfiles/plugin/catppuccin/autoload/lightline
sudo chmod -R 755 /usr/share/vim/vimfiles/plugin/catppuccin/autoload/lightline/colorscheme
