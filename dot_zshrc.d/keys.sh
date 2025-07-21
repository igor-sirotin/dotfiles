#!/bin/sh

# History Search by Start of Line (↑ / ↓)
bindkey "^[[A" history-beginning-search-backward  # Up Arrow
bindkey "^[[B" history-beginning-search-forward   # Down Arrow

# Cursor Moves to End of Input on History Search
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

# Option+Left/Right Arrow for IDE-Like Word Navigation
function backward-ide-word() {
  local cursor_position=${#BUFFER[1,CURSOR]}
  local word_start_regex="[a-zA-Z0-9_.-]"
  
  # Move left until a non-word character is found
  while (( CURSOR > 0 )) && [[ ${BUFFER[CURSOR-1]} =~ $word_start_regex ]]; do
    (( CURSOR-- ))
  done
}
function forward-ide-word() {
  local buffer_length=${#BUFFER}
  local word_start_regex="[a-zA-Z0-9_.-]"
  
  # Move right until a non-word character is found
  while (( CURSOR < buffer_length )) && [[ ${BUFFER[CURSOR]} =~ $word_start_regex ]]; do
    (( CURSOR++ ))
  done
}
zle -N backward-ide-word
zle -N forward-ide-word
bindkey '^[b' backward-ide-word
bindkey '^[f' forward-ide-word

# Fn+Left/Right Arrow (or Cmd+Arrow) to Go to Start/End of Line
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line

# Skip Duplicate Commands in History
setopt hist_ignore_dups       # Ignore adjacent duplicates
setopt hist_ignore_all_dups   # Remove all duplicates from history
setopt hist_find_no_dups      # Skip duplicates during search
