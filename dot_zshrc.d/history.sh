#!/bin/sh

# Share history live across all running sessions.
#
# By default zsh only appends to $HISTFILE when a shell exits, and only reads
# it once at startup — so a command typed in one terminal shows up in another
# only after opening a new session. share_history makes every command land in
# $HISTFILE the moment it's entered, and makes each new prompt pull in whatever
# other sessions have written since.
setopt share_history          # Import other sessions' commands + append ours immediately
setopt extended_history       # Save timestamps, required to interleave sessions correctly
setopt append_history         # Add to $HISTFILE rather than overwriting it

HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000               # Commands kept in memory per session
SAVEHIST=100000               # Commands kept in $HISTFILE

# Skip Duplicate Commands in History
setopt hist_ignore_dups       # Ignore adjacent duplicates
setopt hist_ignore_all_dups   # Remove all duplicates from history
setopt hist_find_no_dups      # Skip duplicates during search
setopt hist_reduce_blanks     # Strip superfluous whitespace before saving
