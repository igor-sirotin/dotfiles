#!/bin/sh

# Runs after the dotfiles are applied: vim-plug reads the plug#begin block in
# ~/.vimrc, so PlugInstall does nothing useful if it runs before chezmoi has
# written that file.
set -eu

curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim +PlugInstall +qall
