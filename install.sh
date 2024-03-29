#!/bin/bash
set -x

mkdir -p ~/bin

echo "Installing zplug"
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh

echo "Installing tmux plugin manager"
mkdir -p ~/.tmux/plugins
if [[ ! -d ~/.tmux/plugins/tpm ]]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

if [[ `which cargo` ]]; then
  # Prefer cargo for rust utils, if it's installed
  cargo install bat cargo-update exa git-delta ripgrep zoxide

  if [[ `which brew` ]]; then
    brew install fzf nvim stow starship
  elif [[ `which apt` ]]; then
    sudo apt install nvim stow
    echo 'Installing fzf'
    ./install_fzf.sh
  fi
elif [[ `which brew ` ]]; then
  brew install bat exa git-delta ripgrep starship fzf stow nvim zoxide
elif [[ `which apt ` ]]; then
  echo 'Installing starship'
  curl -fsSL https://starship.rs/install.sh | bash
  echo 'Installing fzf'
  ./install_fzf.sh
  sudo apt install bat exa git-delta ripgrep stow nvim zoxide
fi

python3 -m pip install --user --upgrade pynvim
nvim +PlugInstall +qall
nvim +UpdateRemotePlugins +qall
