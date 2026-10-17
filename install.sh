#!/bin/bash
# Installs the CLI tools and runtimes this dotfiles repo depends on.
# Supports macOS (Homebrew) and Debian/Ubuntu (apt, including WSL).
set -euo pipefail

# On EOL macOS releases Homebrew has no bottles, so `brew install`/`brew
# upgrade` builds from source and can drag in llvm + cmake for an hour. Skip
# brew's auto-update, and never let a plain `brew install` upgrade something
# already present. Build the Rust tools with cargo instead.
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_INSTALL_UPGRADE=1

mkdir -p ~/bin ~/.local/bin

# --- language runtimes ------------------------------------------------------
# Rust: cargo builds the Rust-based CLI tools below. Use the minimal profile so
# we get cargo/rustc/std without docs or the extra toolchain weight, and leave
# the shell profiles alone -- .zshrc already puts ~/.cargo/bin on PATH.
if ! command -v cargo >/dev/null 2>&1; then
  echo "Installing rustup (minimal profile)"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
    | sh -s -- -y --profile minimal --no-modify-path
  # shellcheck disable=SC1091
  . "${CARGO_HOME:-$HOME/.cargo}/env"
fi

# Node: use nvm, which behaves the same on macOS and Linux. .zshrc already
# sources $NVM_DIR/nvm.sh, so the installer must not touch shell profiles.
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
  echo "Installing nvm"
  PROFILE=/dev/null bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash'
fi
# nvm.sh assumes no `set -u`.
set +u
. "$NVM_DIR/nvm.sh"
nvm install --lts
set -u

# --- CLI tools --------------------------------------------------------------
# fd + ripgrep + fzf + zoxide power the find commands in .zshrc.
#
# Rust tools are built with cargo when a rustup toolchain is present. --locked
# pins each crate's own dependency versions; unconstrained latest releases have
# shipped broken on this toolchain before.
RUST_TOOLS=(bat:bat fd-find:fd eza:eza git-delta:delta ripgrep:rg zoxide:zoxide starship:starship)
# The same tools under their Homebrew formula names (fd and delta differ),
# used only when no cargo is available.
RUST_FORMULAE=(bat fd eza git-delta ripgrep zoxide starship)
# Non-Rust tools that only the package manager provides.
PACKAGE_TOOLS=(fzf stow neovim gh tmux git-lfs)

if command -v brew >/dev/null 2>&1; then
  if command -v cargo >/dev/null 2>&1; then
    cargo_bin="${CARGO_HOME:-$HOME/.cargo}/bin"
    for tool in "${RUST_TOOLS[@]}"; do
      bin="${tool##*:}"
      if [[ -x "$cargo_bin/$bin" ]]; then
        continue
      fi
      cargo install --locked "${tool%%:*}"
    done
  else
    brew install "${RUST_FORMULAE[@]}"
  fi
  # Install only what is missing: brew list is a no-op for present formulae.
  for tool in "${PACKAGE_TOOLS[@]}"; do
    if brew list --formula "$tool" >/dev/null 2>&1; then
      continue
    fi
    brew install "$tool"
  done
elif command -v apt >/dev/null 2>&1; then
  # Debian/Ubuntu package names differ from upstream.
  sudo apt update
  sudo apt install -y fd-find ripgrep fzf zoxide bat stow neovim zsh gh tmux git-lfs

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
      command -v cargo >/dev/null 2>&1 && cargo install --locked eza || echo "warning: could not install eza"
    fi
  fi

  # starship and delta aren't packaged on Debian/Ubuntu: starship goes through
  # its installer into ~/.local/bin (already on PATH), delta through cargo.
  # Expect a few minutes of compiling on a fresh machine.
  if ! command -v starship >/dev/null 2>&1; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y -b ~/.local/bin
  fi
  if ! command -v delta >/dev/null 2>&1 && command -v cargo >/dev/null 2>&1; then
    cargo install --locked git-delta
  fi
else
  echo "No supported package manager (brew or apt) found." >&2
  echo "Install fd, ripgrep, fzf, and zoxide manually." >&2
fi

# --- plugin manager ---------------------------------------------------------
# Runs after the package installs above: on a fresh Debian box zsh doesn't
# exist until apt puts it there, and piping the installer to a missing zsh
# aborts the script before gh and friends install.
if command -v zsh >/dev/null 2>&1 && [[ ! -d ~/.zplug ]]; then
  echo "Installing zplug"
  curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
fi

# Make zsh the login shell once it's installed (apt branch above adds it).
# No-op on macOS where zsh is already the default.
if command -v zsh >/dev/null 2>&1 && [[ $(basename "${SHELL:-}") != zsh ]]; then
  echo "Setting login shell to zsh (may prompt for password)"
  chsh -s "$(command -v zsh)"
fi

# uv (Python toolchain), for systems whose package manager lacks it.
command -v uv >/dev/null 2>&1 || curl -LsSf https://astral.sh/uv/install.sh | sh

# Pi coding agent: installs to ~/.pi/agent, symlinks ~/bin/pi (already on
# PATH). Needs Node >=22.19, provided by the nvm LTS installed above. API keys
# and skills are configured manually afterwards.
command -v pi >/dev/null 2>&1 || curl -LsSf https://pi.dev/install.sh | sh
