# built on zsh 5.9.1
# https://github.com/byscourge/coke-config

if [[ "$OSTYPE" == "linux-android" ]]; then # check if operating system is android

typeset -g ZDIR="$HOME/.zsh.d/" # set main configuration path variable
typeset -g ZDIR_NAME="\$HOME/$(basename $ZDIR)/" # set string for scripts to use when showing ZDIR path
typeset -g ZFILE="${ZDOTDIR:-$HOME}/.zshrc" # set reusable path for scripts

izload() {
  local mod="$1"
  if [[ -f "$mod" ]]; then
    source "$mod"
    return 0
  else
    critical "File could not be loaded: ${WHITE}$mod${NC}\n"
    __missingmod=true
    return 1
  fi
} # if file exists, continue, if not then print error and set __missingmod variable



ZMODS=( # set main modules array
  $ZDIR/pkgchecks.zsh # Script support: confirm whether user has apt or pacman

  $ZDIR/exports.zsh # Enviroment variables

  $ZDIR/plugins.zsh # ZSH Plugins

  $ZDIR/hooks.zsh # Preloads

  $ZDIR/unfunctions.zsh # Functions to be erased

  $ZDIR/aliases.zsh # Aliases

  $ZDIR/functions.zsh # Functions

  $ZDIR/unaliases.zsh # Aliases to be erased

  $ZDIR/aliases.zsh # Intentional duplicate

  $ZDIR/keybinds.zsh # Keybindings

  $ZDIR/exports.zsh # Intentional duplicate

  $ZDIR/themes.zsh # ZSH Themes

  $ZDIR/autostart.zsh # Autostart
)


zmodload zsh/datetime # load needed zsh module for EPOCHREALTIME

ZSHRC_START_TIME=$EPOCHREALTIME # capture start time
# ---------------------------------------------------------------------
# color functions & color codes
# foreground color = \033[38;2
# background color = \033[48;2

# non-colors
BOLD=$'\033[1m'
NC=$'\033[0m'

# colors
GREEN=$'\033[38;2;150;230;150m'
BRIGHT_GREEN=$'\033[1m\033[38;2;0;255;0m'

ORANGE=$'\033[38;2;255;100;0m'
RED=$'\033[38;2;240;98;107m'
BRIGHT_RED=$'\033[1m\033[38;2;255;0;0m'

BLUE=$'\033[1m\033[38;2;125;167;205m'
CYAN=$'\033[38;2;0;250;255m'
BRIGHT_CYAN=$'\033[1m\033[38;2;0;255;255m'

WHITE=$'\033[38;2;255;255;255m'
BRIGHT_WHITE=$'\033[1m\033[38;2;255;255;255m'

PINK=$'\033[38;2;255;0;255m'
PURPLE=$'\033[38;2;150;150;255m'
DARK_PURPLE=$'\033[38;2;130;85;255m'

GRAY=$'\033[38;2;69;79;96m'
BLACK=$'\033[38;2;0;0;0m'

# background colors
BG_GREEN=$'\033[48;2;150;230;150m'
BG_BRIGHT_GREEN=$'\033[1m\033[48;2;0;255;0m'

BG_ORANGE=$'\033[48;2;255;100;0m'
BG_RED=$'\033[48;2;240;98;107m'
BG_BRIGHT_RED=$'\033[1m\033[48;2;255;0;0m'

BG_BLUE=$'\033[1m\033[48;2;125;167;205m'
BG_CYAN=$'\033[48;2;0;250;255m'
BG_BRIGHT_CYAN=$'\033[1m\033[48;2;0;255;255m'

BG_WHITE=$'\033[48;2;255;255;255m'
BG_BRIGHT_WHITE=$'\033[1m\033[48;2;255;255;255m'

BG_PINK=$'\033[48;2;255;0;255m'
BG_PURPLE=$'\033[48;2;150;150;255m'
BG_DARK_PURPLE=$'\033[48;2;130;85;255m'

BG_GRAY=$'\033[48;2;69;79;96m'
BG_BLACK=$'\033[48;2;0;0;0m'

# color functions
# errors & debugging
critical() { printf "${BRIGHT_RED}%b${NC}" "$*" >&2; }
err() { printf "${RED}%b${NC}" "$*" >&2; }
warn() { printf "${ORANGE}%b${NC}" "$*" >&2; }
debug() { printf "${PURPLE}%b${NC}" "$*" >&2; }

# shorthand for printf
pf() { printf "%b" "$*"; }

# successes
ok() { printf "${GREEN}%b${NC}" "$*"; }
great() { printf "${BRIGHT_GREEN}%b${NC}" "$*"; }

# information
info() { printf "${BLUE}%b${NC}" "$*"; }
c_info() { printf "${CYAN}%b${NC}" "$*"; }
bc_info() { printf "${BRIGHT_CYAN}%b${NC}" "$*"; }
w_info() { printf "${WHITE}%b${NC}" "$*"; }
bw_info() { printf "${BRIGHT_WHITE}%b${NC}" "$*"; }
g_info() { printf "${GRAY}%b${NC}" "$*"; }

# asking questions & prompting
prompt() { printf "${DARK_PURPLE}%b${NC}" "$*"; }

# --------------------------------------------------------------------
# --------------------------------------------------------------------
#                     loading & startup logic
# --------------------------------------------------------------------
# --------------------------------------------------------------------

for module in "${ZMODS[@]}"; do
  izload "$module"
done

ZSHRC_END_TIME=$EPOCHREALTIME # capture zsh end time
printf -v ZSHRC_ELAPSED_MS '%.0f' $(( (ZSHRC_END_TIME - ZSHRC_START_TIME) * 1000 ))

# if a module was missing, print nothing
[[ "$__missingmod" == "true" ]] || info "Zsh took [${ZSHRC_ELAPSED_MS}ms] to load.\n\n\n"

# if operating system isnt android, then dont load anything
else
  printf "\n\n\033[38;2;255;0;0mInstalled operating system is not android, config could not load.\n"
  return 255;
fi
