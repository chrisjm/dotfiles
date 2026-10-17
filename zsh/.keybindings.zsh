export KEYTIMEOUT=1

bindkey "${key[Up]}" up-line-or-local-history
bindkey "${key[Down]}" down-line-or-local-history
bindkey "^[[A" up-line-or-local-history
bindkey "^[[B" down-line-or-local-history

up-line-or-local-history() {
    zle set-local-history 1
    zle up-line-or-history
    zle set-local-history 0
}
zle -N up-line-or-local-history
down-line-or-local-history() {
    zle set-local-history 1
    zle down-line-or-history
    zle set-local-history 0
}
zle -N down-line-or-local-history

# backspace and ^h working even after
# returning from command mode
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey "^[[3~" vi-delete-char

# ctrl-w removed word backwards
bindkey '^w' backward-kill-word
bindkey '^u' backward-kill-line
bindkey '^k' kill-line

bindkey '^[b' backward-word
bindkey '^[f' forward-word
bindkey '^E' end-of-line
bindkey '^A' beginning-of-line
