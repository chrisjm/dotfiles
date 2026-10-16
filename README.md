# Dotfiles

Personal dotfiles for **macOS** and **Linux (including WSL)**, managed with
[GNU Stow](https://www.gnu.org/software/stow/).

## Installation

1. Set your shell to zsh.
2. Clone this repository.
3. `cd dotfiles && ./install.sh && ./stow.sh -R`

To use only part of the config, stow a single directory instead, e.g. `stow -R zsh`.

`install.sh` detects Homebrew or apt and installs the CLI tools below. On
apt-based systems it symlinks `fdfind`→`fd` and `batcat`→`bat`, which is what
the shell config expects.

## Finding things

The core workflow is fuzzy-finding files, paths, and contents:

- **`fd`** – fast file finder (`find` replacement)
- **`ripgrep` (`rg`)** – fast content search
- **`fzf`** – fuzzy picker. Binds `Ctrl-R` (history), `Ctrl-T` (files), `Alt-C` (cd)
- **`zoxide` (`z`)** – jump to frecent directories

| Command    | Does                                                      |
| ---------- | --------------------------------------------------------- |
| `z <name>` | jump to a frecent directory                               |
| `fz`       | fuzzy-pick a tracked directory and `cd`                   |
| `fo`       | fuzzy-pick a file, preview it, open in `$EDITOR`          |
| `fr`       | like `fo`, scoped to the current git repository           |
| `fgr`      | ripgrep content search → pick → open at the matching line |
| `fh`       | fuzzy history search                                      |
| `fgb`      | fuzzy-checkout one of the 30 most recent branches         |

## Utilities

- `eza` instead of `ls`
- `bat` instead of `cat`
- `uv` for Python environments and dependencies

## Shell helpers

- `fn <text>` – find files by name under the current tree
- `mcd <dir>` – make a directory and `cd` into it
- `cdgr` – `cd` to the git root

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

## Design notes

The principles behind this repo, and the things not to reintroduce, live in
[`AGENTS.md`](./AGENTS.md).
