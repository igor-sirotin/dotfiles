#!/bin/sh

# Runs after the dotfiles are applied: vim-plug reads the plug#begin block in
# ~/.vimrc, so PlugInstall does nothing useful if it runs before chezmoi has
# written that file.
set -eu

curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/0.15.0/plug.vim
vim -N -es -u ~/.vimrc -i NONE +"PlugInstall --sync" \
    +'if len(filter(values(g:plugs), "!isdirectory(v:val.dir)")) | cquit | endif' \
    +qall </dev/null
