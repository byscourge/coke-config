# built on zsh 5.9.1
critical() {
  printf "\033[38;2;255;0;0m$*\033[0m" >&2; return 255
}

err() {
  printf "\033[31m$*\033[0m" >&2; return 1
}

warn() {
  printf "\033[38;5;208m$*\033[0m" >&2; return 1
}

pf() {
  printf "$*"
}

ok() {
  printf "\033[92m$*\033[0m"; return 0
}

info() {
  printf "\033[38;2;0;255;255m$*\033[0m";
}

# --------------------------------------------------------------------

if [[ "$OSTYPE" == "linux-android" ]]; then

ZDIR="$HOME/zsh.d/"

izload() {
  local mod="$1"
  if [[ -f "$mod" ]]; then
    source "$mod"
    return 0
  else
    critical "Uh-Oh! File could not be loaded: $mod"
    return 1
  fi
}


zmodload zsh/datetime

ZSHRC_START_TIME=$EPOCHREALTIME

izload $ZDIR/exports.zsh # Enviroment variables

izload $ZDIR/hooks.zsh # Preloads

izload $ZDIR/plugins.zsh # ZSH Plugins

izload $ZDIR/themes.zsh # ZSH Themes

izload $ZDIR/unfunctions.zsh # Functions to be erased

izload $ZDIR/aliases.zsh # Aliases

izload $ZDIR/functions.zsh # Functions

izload $ZDIR/unaliases.zsh # Aliases to be erased

izload $ZDIR/aliases.zsh # Intentional duplicate

izload $ZDIR/keybinds.zsh # Keybindings

izload $ZDIR/exports.zsh # Intentional duplicate

izload $ZDIR/pkgchecks.zsh # Script support: confirm whether user has apt or pacman

ZSH_HIGHLIGHT_STYLES[command]='fg=183'
ZSH_HIGHLIGHT_STYLES[alias]='fg=183'
ZSH_HIGHLIGHT_STYLES[function]='fg=183'
ZSH_HIGHLIGHT_STYLES[path]='fg=135'

ZSHRC_END_TIME=$EPOCHREALTIME
printf -v ZSHRC_ELAPSED_MS '%.0f' $(( (ZSHRC_END_TIME - ZSHRC_START_TIME) * 1000 ))
pf "Zsh took [${ZSHRC_ELAPSED_MS}ms] to load.\n"

izload $ZDIR/.print.pkg.version # Print package manager version

izload $ZDIR/autostart.zsh # Autostart

else
  err "Uh-Oh! OS Type is not android\n"
  return 255;
fi
