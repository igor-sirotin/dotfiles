#!/bin/sh

# Abort on the first failure. Without this a failed `brew install` still exits 0,
# and chezmoi records this run_once_ script as done — so the missing packages are
# never installed on any later apply. Failing loudly makes chezmoi retry instead.
set -eu

# Install brew packages
brew install lsd tree vivid stats
brew install --cask font-jetbrains-mono-nerd-font
brew install --cask alt-tab
brew install zsh-autosuggestions

brew install zsh-completions

# compinit refuses to load completions from group/world-writable directories.
# Derive the prefix rather than hardcoding it: it is /opt/homebrew on Apple
# Silicon but /usr/local on Intel.
brew_prefix="$(brew --prefix)"
chmod go-w "$brew_prefix/share"
chmod -R go-w "$brew_prefix/share/zsh"

# Configure Vim
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim +PlugInstall +qall
