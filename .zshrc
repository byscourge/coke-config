if [[ "$OSTYPE" == "linux-android" ]]; then

# built for termux on android, not linux or any other os/terminal
# yes, some components are ai generated (STRICLY functions (just a few, i would say around 4.)), but its not 100% ai generated. when i cant figure something out i ask ai for help, and if it takes me over 2 weeks i'll just let it solve the problem and ill build ontop of it. nothing here is PURELY ai generated as i always code the base+concept first, with that said, 90% of functions are coded only by me. nothing else besides a few functions are ai generated.

ZSHRC_START_TIME=$(date +%s%N) # timer to count how long zsh takes to load

source ~/zsh.d/exports.zsh # env vars

source ~/zsh.d/plugins.zsh # zsh plugins, eg git fzf etc

source ~/zsh.d/themes.zsh # themes, eg powerlevel10k

source ~/zsh.d/pkgchecks.zsh # check if user has apt or pacman for scripts

source ~/zsh.d/unfunctions.zsh # functions to be forgotten

source ~/zsh.d/hooks.zsh # scripts that hook onto zsh, eg zoxide

source ~/zsh.d/aliases.zsh # aliases

source ~/zsh.d/functions.zsh # functions

source ~/zsh.d/autostart.zsh # things that run beforehand, eg sourcing .p10k.zsh, or misc like neofetch

source ~/zsh.d/unaliases.zsh # aliases to be forgotten

source ~/zsh.d/aliases.zsh # aliases duplicate, "why source aliases twice?", well, one before functions so the functions dont break, and the second one after it so ohmyzsh doesnt override them

source ~/zsh.d/keybinds.zsh # keybinds

source ~/zsh.d/exports.zsh # env vars duplicate to ensure not overrideb

ZSH_HIGHLIGHT_STYLES[command]='fg=183'
ZSH_HIGHLIGHT_STYLES[alias]='fg=183'
ZSH_HIGHLIGHT_STYLES[function]='fg=183'
ZSH_HIGHLIGHT_STYLES[path]='fg=135'

ZSHRC_END_TIME=$(date +%s%N) # timer end
ZSHRC_ELAPSED_MS=$(( (ZSHRC_END_TIME - ZSHRC_START_TIME) / 1000000 )) # how long zsh took to load in ms
pf "ZShell took [${ZSHRC_ELAPSED_MS}ms] to load.\n" # prints to buffer

source ~/zsh.d/.print.pkg.version # prints your pkg managers version


# the duplicates are intentional btw ❤️

else
  err "Uh-Oh! stderr: Critical[]; OS Type is not android :(\n"
  return 255;
fi
