# https://github.com/byscourge/coke-config

zinit ice depth=1
zinit light romkatv/powerlevel10k

source $HOME/.config/lf/icons
ZSH_HIGHLIGHT_STYLES[command]='fg=183'
ZSH_HIGHLIGHT_STYLES[alias]='fg=183'
ZSH_HIGHLIGHT_STYLES[function]='fg=183'
ZSH_HIGHLIGHT_STYLES[path]='fg=135'

[[ ! -d "$HOME/.p10k.themes" || -f "$p10kthemes" ]] && rm ~/.p10k.themes/ 2>/dev/null ; mkdir -p "~/.p10k.themes/"

chp10k() {
  P10K_THEMES=(~/.p10k.themes/*)

  [[ -z "$1" ]] && {
    i=1
    printf "Available themes:\n\n"
    for theme in "${P10K_THEMES[@]}"; do
      printf "${WHITE}$i) ${BLUE}$(basename $theme)${NC}\n"
      ((i++))
    done
    return 0
  }

if [[ -n "$1" ]]; then
  chtheme="$1"
  if [[ -n "${P10K_THEMES[$chtheme]}" ]]; then
    ln -sf "${P10K_THEMES[$chtheme]}" ~/.p10k.zsh
    ssz
  fi
fi
}

source ~/.p10k.zsh

se
