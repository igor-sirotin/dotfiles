#!/bin/sh

# Install brew packages
brew install lsd tree vivid stats
brew install --cask font-jetbrains-mono-nerd-font

# Configure Vim
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim +PlugInstall +qall
