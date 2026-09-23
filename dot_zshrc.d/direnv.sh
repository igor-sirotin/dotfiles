#!/bin/sh

# Load and unload per-directory .envrc files (secrets, project env) on cd.
# Guarded so a shell without direnv installed doesn't error on every start.
if type direnv &>/dev/null; then
    eval "$(direnv hook zsh)"
fi
