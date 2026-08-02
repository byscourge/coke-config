# built on zsh 5.9.1
if [[ "$OSTYPE" == "linux-android" ]]; then

ZDIR="$HOME/zsh.d/"

izload() {
  local mod="$1"
  if [[ -f "$mod" ]]; then
    source "$mod"
    return 0
  else
    critical "Uh-Oh! File could not be loaded: $mod\n"
    return 1
  fi
}


zmodload zsh/datetime

ZSHRC_START_TIME=$EPOCHREALTIME
# ---------------------------------------------------------------------
# color functions & color codes
# foreground color = \033[38;2
# background color = \033[48;2

BOLD=$'\033[1m'
GREEN=$'\033[38;2;150;230;150m'
BRIGHT_GREEN=$'\033[1m\033[38;2;0;255;0m'
RED=$'\033[38;2;240;98;107m'
BRIGHT_RED=$'\033[1m\033[38;2;255;0;0m'
ORANGE=$'\033[38;2;255;120;0m'
CYAN=$'\033[38;2;0;250;255m'
BRIGHT_CYAN=$'\033[1m\033[38;2;0;255;255m'
WHITE=$'\033[38;2;255;255;255m'
BLUE=$'\033[1m\033[38;2;125;167;205m'
GRAY=$'\033[38;2;69;79;96m'

NC=$'\033[0m'

critical() {
  printf "${BRIGHT_RED}$*${NC}" >&2; return 1
}

err() {
  printf "${RED}$*${NC}" >&2; return 1
}

warn() {
  printf "${ORANGE}$*${NC}" >&2; return 1
}

pf() {
  printf "$*"
}

ok() {
  printf "${GREEN}$*${NC}"; return 0
}

great() {
  printf "${BRIGHT_GREEN}$*${NC}"; return 0
}

info() {
  printf "${BLUE}$*${NC}";
}

c_info() {
  printf "${CYAN}$*${NC}";
}

bc_info() {
  printf "${BRIGHT_CYAN}$*${NC}"
}

w_info() {
  printf "${WHITE}$*${NC}"
}

g_info() {
  printf "${GRAY}$*${NC}"
}
# --------------------------------------------------------------------
# loading & startup logic

izload $ZDIR/pkgchecks.zsh # Script support: confirm whether user has apt or pacman

izload $ZDIR/exports.zsh # Enviroment variables

izload $ZDIR/plugins.zsh # ZSH Plugins

izload $ZDIR/hooks.zsh # Preloads

izload $ZDIR/themes.zsh # ZSH Themes

izload $ZDIR/unfunctions.zsh # Functions to be erased

izload $ZDIR/aliases.zsh # Aliases

izload $ZDIR/functions.zsh # Functions

izload $ZDIR/unaliases.zsh # Aliases to be erased

izload $ZDIR/aliases.zsh # Intentional duplicate

izload $ZDIR/keybinds.zsh # Keybindings

izload $ZDIR/exports.zsh # Intentional duplicate

izload $ZDIR/autostart.zsh # Autostart

ZSH_HIGHLIGHT_STYLES[command]='fg=183'
ZSH_HIGHLIGHT_STYLES[alias]='fg=183'
ZSH_HIGHLIGHT_STYLES[function]='fg=183'
ZSH_HIGHLIGHT_STYLES[path]='fg=135'

ZSHRC_END_TIME=$EPOCHREALTIME
printf -v ZSHRC_ELAPSED_MS '%.0f' $(( (ZSHRC_END_TIME - ZSHRC_START_TIME) * 1000 ))

info "Zsh took [${ZSHRC_ELAPSED_MS}ms] to load.\n"
printf "\n\n"

else
  printf "\n\n\033[38;2;255;0;0mInstalled operating system is not android, config could not load.\n"
  return 255;
fi
