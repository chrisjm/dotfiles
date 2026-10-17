source ~/.zplug/init.zsh

# ## FZF FUNCTIONS ##

export FZF_COMPLETION_TRIGGER='`'
export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_DEFAULT_OPTS="--bind 'ctrl-a:select-all'"

_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}

_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}

# fo [FUZZY PATTERN] - Open the selected file with the default editor
#   - Bypass fuzzy finder if there's only one match (--select-1)
#   - Exit if there's no match (--exit-0)
fo() {
  local files
  IFS=$'\n' files=($(fzf --query="$1" --multi --select-1 --exit-0 --preview 'bat --style=numbers --color=always --line-range :500 {}'))
  [[ -n "$files" ]] && ${EDITOR:-nvim} "${files[@]}"
}

# fr [FUZZY PATTERN] - Open the selected file with the default editor. Search the entire repository
#   - Bypass fuzzy finder if there's only one match (--select-1)
#   - Exit if there's no match (--exit-0)
fr() {
  local files
  IFS=$'\n' files=($(fd --type f --search-path $(git rev-parse --show-toplevel) | fzf --query="$1" --multi --select-1 --exit-0 --preview 'bat --style=numbers --color=always --line-range :500 {}'))
  [[ -n "$files" ]] && ${EDITOR:-nvim} "${files[@]}"
}

# fh [FUZZY PATTERN] - Search in command history
fh() {
  print -z $(fc -l 1 | fzf +s --tac | sed 's/ *[0-9]* *//')
}

# fgb [FUZZY PATTERN] - Checkout specified branch
# Include remote branches, sorted by most recent commit and limited to 30
fgb() {
  local branches branch query

  query="--query="
  if [[ -n "$1" ]]; then
    query="--query=$1"
  fi

  branches=$(git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format="%(refname:short)") &&
  branch=$(echo "$branches" |
    fzf +m "$query" ) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# ftm [SESSION_NAME | FUZZY PATTERN] - create new tmux session, or switch to existing one.
# Running `ftm` will let you fuzzy-find a session name
# Passing an argument will switch to that session if it exists or create it otherwise
ftm() {
  [[ -n "$TMUX" ]] && change="switch-client" || change="attach-session"
  if [ $1 ]; then
    (tmux $change -t "$1" 2>/dev/null) || (tmux new-session -d -s $1 && tmux $change -t "$1"); return
  fi
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) &&  tmux $change -t "$session" || echo "No sessions found."
}

# ftmk [SESSION_NAME | FUZZY PATTERN] - delete tmux session
# Running `ftmk` will let you fuzzy-find a session name to delete
# Passing an argument will delete that session if it exists
ftmk() {
  if [ $1 ]; then
    tmux kill-session -t "$1"; return
  fi
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) &&  tmux kill-session -t "$session" || echo "No session found to delete."
}

# fuzzy grep via rg and open in $EDITOR with line number
fgr() {
  local file
  local line

  IFS=" " read -r file line <<<"$(rg --no-heading --line-number $@ | fzf -0 -1 | awk -F: '{print $1, $2}')"

  if [[ -n $file ]]
  then
     $EDITOR "$file" +$line
  fi
}

# cd to git root
cdgr() {
  cd "$(git rev-parse --show-toplevel)" || return
}

function delete-branches() {
  git branch |
    grep --invert-match '\*' |
    cut -c 3- |
    fzf --multi --preview="git log {}" |
    while read -r branch; do git branch --delete --force "$branch"; done
}

SAVEHIST=10000
HISTSIZE=10000
HISTFILE=~/.zsh_history
setopt share_history

# Must go before zsh-syntax-highlighting
autoload -U select-word-style && select-word-style bash

zplug 'zplug/zplug', hook-build:'zplug --self-manage'
zplug "plugins/ssh-agent", from:oh-my-zsh
zplug "plugins/git", from:oh-my-zsh
zplug "Aloxaf/fzf-tab", defer:2
zplug "zsh-users/zsh-syntax-highlighting", defer:3

zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:git-switch:*' sort false
# Enable completion list colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'

if ! zplug check; then
    zplug install
fi
zplug load

source ~/.aliases.zsh
source ~/.keybindings.zsh
[ -f ~/.flashcards.zsh ] && source ~/.flashcards.zsh

[ -f ~/.zprofile ] && source ~/.zprofile

# fzf key bindings + completion (works with brew, apt, and git installs)
if command -v fzf >/dev/null 2>&1 && fzf --zsh >/dev/null 2>&1; then
  source <(fzf --zsh)
elif [ -f ~/.fzf.zsh ]; then
  source ~/.fzf.zsh
fi

eval "$(zoxide init zsh)"

# Show a random command card when a new shell opens.
# Set FLASH_QUIET=1 to skip it; won't repeat when `rc` re-sources this file.
if (( ! ${+_FLASH_WELCOMED} )) && (( $+functions[flash] )) && [[ -z "$FLASH_QUIET" ]]; then
  _FLASH_WELCOMED=1
  flash
fi

eval "$(starship init zsh)"
command -v uv >/dev/null 2>&1 && eval "$(uv generate-shell-completion zsh)"

setopt auto_pushd

# Better autocompletion
autoload -Uz compinit && compinit

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# https://github.com/nvm-sh/nvm#zsh
autoload -U add-zsh-hook

load-nvmrc() {
  local nvmrc_path
  nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version
    nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$(nvm version)" ]; then
      nvm use
    fi
  elif [ -n "$(PWD=$OLDPWD nvm_find_nvmrc)" ] && [ "$(nvm version)" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}

add-zsh-hook chpwd load-nvmrc
load-nvmrc

# zsh's `path` array is the source of truth; PATH follows it.
# typeset -U dedupes, so re-sourcing is safe.
typeset -U path
path=(
  "$HOME/bin"
  "$HOME/.local/bin"
  "$HOME/.cargo/bin"
  $path
)
