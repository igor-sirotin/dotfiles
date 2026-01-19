#!/bin/sh
export LS_COLORS="$(vivid generate lava)"
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
eval "$(starship init zsh)"
