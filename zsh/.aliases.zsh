alias cat="bat"
alias cp='cp -iv'
alias el="exa -l --git"
alias gd='git diff'
alias gs='git status'
alias ig="sk -i --ansi -c 'rg --color=always --line-number "{}"'"
alias j="just"
alias l='exa -l --git'
alias ls='exa'
alias ll='l'
alias la='exa -la --git'
alias mv='mv -iv'
alias py3env='source ~/py3env/bin/activate'
alias rg='rg -S'
alias rm='rm -iv'
alias scp='scp -C'
alias vi='nvim'
alias vim='nvim'
alias rc='source ~/.zshenv && source ~/.zshrc'
alias ec='code ~/dotfiles'

export BIND_IP=0.0.0.0
export EDITOR=nvim
export GIT_CEILING_DIRECTORIES=~
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export PAGER=less
export VISUAL=nvim

if [[ `uname` == Darwin ]]; then
    alias top='top -o -cpu'
    alias l='exa -l --git'
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

