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
    echo -ne "\033[1m\033[38;2;255;0;0mFile could not be loaded: ${WHITE}$mod${NC}\n\033[0m" >&2
    __missingmod=true
    return 1
  fi
} # if file exists, continue, if not then print error and set __missingmod variable

ZMODS=( # set main modules array
  $ZDIR/exports.zsh # Enviroment variables

  $ZDIR/pkgchecks.zsh # Script support: confirm whether user has apt or pacman

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
