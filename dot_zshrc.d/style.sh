#!/bin/sh

# Every command here is guarded: this file is sourced by each new shell, so an
# unguarded call to a tool that isn't installed errors on every prompt.

if type vivid &>/dev/null; then
    export LS_COLORS="$(vivid generate lava)"
fi

if type brew &>/dev/null; then
    autosuggestions="$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    [ -r "$autosuggestions" ] && source "$autosuggestions"
    unset autosuggestions
fi

if type starship &>/dev/null; then
    eval "$(starship init zsh)"
fi
