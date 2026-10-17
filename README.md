# Dotfiles

Personal dotfiles for **macOS** and **Linux (including WSL)**, managed with
[GNU Stow](https://www.gnu.org/software/stow/).

## Installation

1. Clone this repository.
2. `cd dotfiles && ./install.sh && ./stow.sh -R`
3. Log out and back in if `install.sh` changed your login shell to zsh.

To use only part of the config, stow a single directory instead, e.g. `stow -R zsh`.
On WSL, a `BUG in find_stowed_path` warning means a symlink in `~` (e.g.
`~/.aws`, `~/.azure`) points at an absolute `/mnt/c/...` path; `ln -sfn
../../mnt/c/...` to make it relative and the warning goes away.

`install.sh` detects Homebrew or apt and installs the CLI tools below
(including `gh`, `tmux`, `git-lfs`, and `zsh` — it runs `chsh` if zsh isn't
already your login shell). On apt-based systems it symlinks `fdfind`→`fd` and
`batcat`→`bat`, which is what the shell config expects, and installs starship
via its installer script and delta via cargo since neither is packaged. On
macOS the Rust-based tools (bat, eza, fd, delta, ripgrep, zoxide, starship)
are built with the rustup toolchain, because EOL macOS releases have no
Homebrew bottles and would otherwise compile from source under Homebrew
anyway.

It also bootstraps the language runtimes:

- **Rust** – rustup, with the minimal profile (`cargo`, `rustc`, `std`).
- **Node** – [nvm](https://github.com/nvm-sh/nvm) from the official install
  script, then the current LTS release. `nvm` is the cross-platform default;
  do not install it from Homebrew.

R is installed manually per platform (see below), because the right source
differs by system and the packages are large.

## Finding things

The core workflow is fuzzy-finding files, paths, and contents:

- **`fd`** – fast file finder (`find` replacement)
- **`ripgrep` (`rg`)** – fast content search
- **`fzf`** – fuzzy picker. Binds `Ctrl-R` (history), `Ctrl-T` (files), `Alt-C` (cd)
- **`zoxide`** – `z <name>` jumps to a frecent directory; `zi` opens the interactive picker

| Command    | Does                                                      |
| ---------- | --------------------------------------------------------- |
| `z <name>` | jump to a frecent directory                               |
| `zi`       | interactive zoxide picker: fuzzy-find a tracked dir, `cd` |
| `fo`       | fuzzy-pick a file, preview it, open in `$EDITOR`          |
| `fr`       | like `fo`, scoped to the current git repository           |
| `fgr`      | ripgrep content search → pick → open at the matching line |
| `fh`       | fuzzy history search                                      |
| `fgb`      | fuzzy-checkout one of the 30 most recent branches         |

## Utilities

- `eza` instead of `ls`
- `bat` instead of `cat`
- `delta` as the git pager (`n`/`N` jump between files in a diff)
- `uv` for Python environments and dependencies
- `nvm` for Node versions; `nvm install --lts` and `nvm use`

## R and data science

R is installed manually, per platform, because the packages are large and the
right source differs by system:

- **macOS (Homebrew):** `brew install r`, then install the packages from CRAN:
  `Rscript -e 'install.packages("tidyverse")'`
- **Debian/Ubuntu:** `sudo apt install r-base`, then
  `sudo apt install r-cran-tidyverse` (binary, no compiling)

This keeps `install.sh` from dragging a large, compile-heavy toolchain into a
fresh setup. Add more packages as needed.

## Shell helpers

- `fn <text>` – find files by name under the current tree
- `mcd <dir>` – make a directory and `cd` into it
- `cdgr` – `cd` to the git root

## Remembering commands

`flash` surfaces the commands and aliases in this setup so you don't have to
hold them all in your head:

- `flash` – a random card
- `flash <text>` – cards matching `<text>`
- `flash -l` – list every card
- `flash -q` – quiz yourself; the description shows first, the command on Enter

## Neovim

Stock Neovim with a small set of editor defaults — line numbers, 4-space
indent (EditorConfig overrides per project), system clipboard, and persistent
undo — and no plugins. `EDITOR` and `VISUAL` both point at `nvim`.

## tmux

Prefix is `Ctrl-b`.

- `Prefix ,` – rename window
- `Prefix s` / `Prefix v` – split horizontal / vertical
- `Prefix z` – maximize / restore pane
- `Prefix h/j/k/l` – move between panes

Session helpers from the shell:

- `ftm [name]` – fuzzy-pick a tmux session to attach or switch to; with a name,
  switch to it or create it if it doesn't exist
- `ftmk [name]` – fuzzy-pick a tmux session to kill

## AI tooling

`install.sh` installs the [Pi](https://pi.dev) coding agent via its managed
installer (`~/.pi/agent`, symlinked to `~/bin/pi`). Update it with `pi update`.
API keys, skills, and extensions are configured manually after install — the
Pi config directory is intentionally not part of this repo.

## Design notes

The principles behind this repo, and the things not to reintroduce, live in
[`AGENTS.md`](./AGENTS.md).
