alias cat="bat"
alias cp='cp -iv'
alias el="eza -l --git"
alias gd='git diff'
alias gs='git status'
alias l='eza -l --git'
alias ls='eza'
alias ll='l'
alias la='eza -la --git'
alias mv='mv -iv'
alias rg='rg -S'
alias rm='rm -iv'
alias scp='scp -C'
alias vi='nvim'
alias vim='nvim'
alias rc='source ~/.zshenv && source ~/.zshrc'

export BIND_IP=0.0.0.0
export EDITOR=nvim
export GIT_CEILING_DIRECTORIES=~
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export PAGER=less
export VISUAL=nvim

if [[ `uname` == Darwin ]]; then
    alias top='top -o -cpu'
else
   alias grep='grep --color=auto'
   alias fgrep='fgrep --color=auto'
   alias egrep='egrep --color=auto'
fi

function fn() {
    find . -iname "*${*}*" | grep -v "~"
}

function mcd() {
    mkdir -pv ${1} && cd ${1}
}


