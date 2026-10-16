# AGENTS.md

Guidance for AI agents working in this repo, and a reminder for future me of
what this setup is *for*.

## What this is

Personal dotfiles for macOS and Linux/WSL, managed with GNU Stow. The goal is a
small, portable setup built around **finding things quickly** — not around
learning a large toolset.

## Principles

- **Find things first.** `fd`, `ripgrep`, `fzf`, and `zoxide` are the point.
  Keep the fuzzy-finding workflow working.
- **Minimal by default.** Prefer built-in behavior over plugins, custom
  scripts, and configuration. If a tool's defaults are good enough, don't add
  config.
- **Portable.** Everything must work on macOS and Linux/WSL. Never hardcode a
  username, `/Users/...`, Homebrew-only paths, or distro-specific package
  names without a fallback.
- **`uv` owns Python.** No virtualenv-activation hooks; `uv run` / `uv sync`
  manage environments.
- **Delete over accumulate.** Remove dead config rather than commenting it out.
- **Deferred, not forbidden.** tmux and remote/SSH work are parked until
  there's a real need.

## Layout

Each top-level directory is a Stow package that mirrors the target layout:
`zsh/`, `nvim/`, `tmux/`, `git/`, `starship/`, `psql/`.

## Conventions

- `install.sh` installs tools (Homebrew on macOS, apt on Debian/Ubuntu).
- Shell config lives in `zsh/.zshrc`, with aliases and keybindings split out.
- `zsh/.flashcards.zsh` is the curated command list behind `flash`; keep it in
  sync when you add or remove a command.
- Neovim is intentionally plugin-free.

## Don't reintroduce

- Plugin managers or plugin stacks (vim-plug, coc, extra zplug add-ons).
- Deprecated tools (exa instead of eza).
- Hardcoded machine paths (`/Users/chris`, `node@16`, `/snap/bin`).
- Aliases and config for tools that aren't in active use.

## Verifying changes

- `zsh -n zsh/.zshrc zsh/.aliases.zsh zsh/.keybindings.zsh zsh/.flashcards.zsh`
- `bash -n install.sh`
- `nvim --headless -u nvim/.config/nvim/init.lua +qa`
- After adding a file to a Stow package, re-link it: `stow -R <package>`
- Open a fresh shell to confirm it loads.
