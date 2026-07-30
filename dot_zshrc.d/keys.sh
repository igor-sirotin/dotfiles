#!/bin/sh

# History Search by Start of Line (↑ / ↓), leaving the cursor at end of input
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search    # Up Arrow
bindkey "^[[B" down-line-or-beginning-search  # Down Arrow

# Option+Left/Right Arrow for IDE-Like Word Navigation
function ide-word-move() {
  local direction=$1  # -1 for backward, 1 for forward
  # Stop at path separators, dots and hyphens the way an IDE does. Previously
  # / and \ were listed as word characters, so a jump skipped whole paths.
  local word_chars="[a-zA-Z0-9_]"
  local non_word_chars="[^a-zA-Z0-9_]"
  local buffer_length=${#BUFFER}
  
  # Boundary checks - only return if we can't move in the requested direction
  if (( direction == -1 && CURSOR == 0 )); then
    return
  fi
  if (( direction == 1 && CURSOR >= buffer_length )); then
    return
  fi
  
  # Get the character to check based on direction
  local check_pos=$(( direction == -1 ? CURSOR : CURSOR + 1 ))
  local current_char=${BUFFER[check_pos]}
  
  # Move through word or non-word characters
  if [[ $current_char =~ $word_chars ]]; then
    # Move through word characters
    while (( (direction == -1 && CURSOR > 0) || (direction == 1 && CURSOR < buffer_length) )); do
      local pos=$(( direction == -1 ? CURSOR : CURSOR + 1 ))
      [[ ${BUFFER[pos]} =~ $word_chars ]] || break
      (( CURSOR += direction ))
    done
  else
    # Skip non-word characters first
    while (( (direction == -1 && CURSOR > 0) || (direction == 1 && CURSOR < buffer_length) )); do
      local pos=$(( direction == -1 ? CURSOR : CURSOR + 1 ))
      [[ ${BUFFER[pos]} =~ $non_word_chars ]] || break
      (( CURSOR += direction ))
    done
    # Then move through the next word
    while (( (direction == -1 && CURSOR > 0) || (direction == 1 && CURSOR < buffer_length) )); do
      local pos=$(( direction == -1 ? CURSOR : CURSOR + 1 ))
      [[ ${BUFFER[pos]} =~ $word_chars ]] || break
      (( CURSOR += direction ))
    done
  fi
}

function backward-ide-word() {
  ide-word-move -1
}

function forward-ide-word() {
  ide-word-move 1
}

zle -N backward-ide-word
zle -N forward-ide-word
bindkey '^[^[[D' backward-ide-word  # Option+Left Arrow
bindkey '^[^[[C' forward-ide-word   # Option+Right Arrow

# Fn+Left/Right Arrow (or Cmd+Arrow) to Go to Start/End of Line
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line

# Skip Duplicate Commands in History
setopt hist_ignore_dups       # Ignore adjacent duplicates
setopt hist_ignore_all_dups   # Remove all duplicates from history
setopt hist_find_no_dups      # Skip duplicates during search
