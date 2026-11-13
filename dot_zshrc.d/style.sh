#!/bin/sh

# Every command here is guarded: this file is sourced by each new shell, so an
# unguarded call to a tool that isn't installed errors on every prompt.

# vivid re-derives the same few KB of LS_COLORS on every shell start. Generate
# it once and cache it; `rm` the cache file to pick up a theme change.
if type vivid &>/dev/null; then
    ls_colors_cache="${XDG_CACHE_HOME:-$HOME/.cache}/vivid-lava.ls_colors"
    if [ ! -s "$ls_colors_cache" ]; then
        mkdir -p "$(dirname "$ls_colors_cache")"
        vivid generate lava > "$ls_colors_cache"
    fi
    export LS_COLORS="$(< "$ls_colors_cache")"
    unset ls_colors_cache
fi

# $HOMEBREW_PREFIX comes from paths.sh, which sorts before this file.
if [ -n "$ZSH_VERSION" ]; then
    for autosuggestions in \
        "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
        /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh; do
        if [ -r "$autosuggestions" ]; then
            source "$autosuggestions"
            break
        fi
    done
    unset autosuggestions
fi

if type starship &>/dev/null; then
    eval "$(starship init "${ZSH_VERSION:+zsh}${BASH_VERSION:+bash}")"
fi
