# flash - random access to the commands and aliases in this config
#
#   flash          show a random card
#   flash <text>   show cards matching <text>
#   flash -l       list every card
#   flash -q       quiz: show the description, reveal the command on Enter

typeset -ga FLASHCARDS=(
  "z <name>|jump to a frecent directory (zoxide)"
  "zi|interactive zoxide picker: fuzzy-find a tracked directory and cd into it"
  "fo|fuzzy-pick a file, preview it, open in \$EDITOR"
  "fr|like fo, scoped to the current git repository"
  "fgr|ripgrep a pattern, pick a hit, open at that line"
  "fh|fuzzy-search your command history"
  "fgb|fuzzy-checkout one of the 30 most recent branches"
  "ftm [name]|fuzzy-pick a tmux session to attach/switch, or create it if absent"
  "ftmk [name]|fuzzy-pick a tmux session to kill"
  "fn <text>|find files by name under the current tree"
  "mcd <dir>|make a directory and cd into it"
  "cdgr|cd to the root of the current git repository"
  "delete-branches|fuzzy-pick local branches and delete them"
  "l / ll|long listing with eza (ll is an alias for l)"
  "el / la|long listing with git status (la includes hidden files)"
  "gd / gs|git diff / git status"
  "rg|ripgrep search (case-insensitive unless you type uppercase)"
  "cat|runs bat: syntax-highlighted with line numbers"
  "vi / vim|runs nvim"
  "rm / cp / mv|aliased to -i: prompts before deleting/overwriting"
  "scp|aliased to scp -C (compression enabled)"
  "rc|re-source .zshenv + .zshrc after editing config"
  "Ctrl-R|fzf fuzzy history search"
  "Ctrl-T|fzf fuzzy file picker"
  "Alt-C|fzf fuzzy cd"
  "delta|git diff/log -p are paged through delta; n/N jump between files"
)

_flash_card() {
  printf '\033[1;36m%s\033[0m  %s\n' "${1%%|*}" "${1#*|}"
}

flash() {
  local card query found=0
  case "$1" in
    -l|--list)
      for card in "${FLASHCARDS[@]}"; do
        printf '%s\t%s\n' "${card%%|*}" "${card#*|}"
      done | column -t -s $'\t'
      return
      ;;
    -q|--quiz)
      card="${FLASHCARDS[$((RANDOM % ${#FLASHCARDS} + 1))]}"
      print
      print "  ${card#*|}"
      print
      read -r "?  press Enter to reveal..."
      print
      print "  ${card%%|*}"
      print
      return
      ;;
  esac

  query="$1"
  if [[ -n "$query" ]]; then
    # match command names first; fall back to descriptions
    for card in "${FLASHCARDS[@]}"; do
      if [[ "${card%%|*}" == *"$query"* ]]; then
        _flash_card "$card"
        found=1
      fi
    done
    if (( ! found )); then
      for card in "${FLASHCARDS[@]}"; do
        if [[ "${card#*|}" == *"$query"* ]]; then
          _flash_card "$card"
          found=1
        fi
      done
    fi
    (( found )) || print "no cards match '$query'"
  else
    _flash_card "${FLASHCARDS[$((RANDOM % ${#FLASHCARDS} + 1))]}"
  fi
}
