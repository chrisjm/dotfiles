#!/bin/bash
# Installs the CLI tools and plugin managers this dotfiles repo depends on.
# Supports macOS (Homebrew) and Debian/Ubuntu (apt, including WSL).
set -euo pipefail

mkdir -p ~/bin ~/.local/bin

# --- plugin managers --------------------------------------------------------
if [[ ! -d ~/.zplug ]]; then
  echo "Installing zplug"
  curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
fi

if [[ ! -d ~/.tmux/plugins/tpm ]]; then
  echo "Installing tmux plugin manager"
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# --- CLI tools --------------------------------------------------------------
# fd + ripgrep + fzf + zoxide power the find commands in .zshrc.
FIND_TOOLS=(fd ripgrep fzf zoxide)
EXTRA_TOOLS=(bat eza starship stow neovim uv)

if command -v brew >/dev/null 2>&1; then
  brew install "${FIND_TOOLS[@]}" "${EXTRA_TOOLS[@]}"
elif command -v apt >/dev/null 2>&1; then
  # Debian/Ubuntu package names differ from upstream.
  sudo apt update
  sudo apt install -y fd-find ripgrep fzf zoxide bat stow neovim

  # ...and two of the binaries are renamed. Symlink the names .zshrc expects
  # into ~/.local/bin, which is already on PATH.
  for pair in fdfind:fd batcat:bat; do
    src=${pair%%:*}
    dest=${pair##*:}
    if command -v "$src" >/dev/null 2>&1; then
      ln -sf "$(command -v "$src")" ~/.local/bin/"$dest"
    fi
  done

  # eza isn't packaged on every Debian/Ubuntu release; fall back to cargo.
  if ! command -v eza >/dev/null 2>&1; then
    if ! sudo apt install -y eza 2>/dev/null; then
      command -v cargo >/dev/null 2>&1 && cargo install eza || echo "warning: could not install eza"
    fi
  fi
else
  echo "No supported package manager (brew or apt) found." >&2
  echo "Install fd, ripgrep, fzf, and zoxide manually." >&2
fi

# uv (Python toolchain), for systems whose package manager lacks it.
command -v uv >/dev/null 2>&1 || curl -LsSf https://astral.sh/uv/install.sh | sh

# --- Neovim plugins ---------------------------------------------------------
python3 -m pip install --user --upgrade pynvim \
  || echo "warning: could not install pynvim (neovim python provider may need manual setup)"
nvim +PlugInstall +qall
nvim +UpdateRemotePlugins +qall
