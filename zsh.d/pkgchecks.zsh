if [[ ! -f ~/.pkg ]]; then
  touch ~/.pkg
fi

local __echoToPkg() {
  echo "$1" > ~/.pkg
}
alias repkg='rm ~/.pkg && szsh'
alias szsh='clear && source ~/.zshrc'

if [[ ! -s ~/.pkg ]]; then
  warn "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nif you input something incorrectly, you can run the command"
  c_info " repkg "
  warn "to run this prompt again."
  w_info "\n\nif you're unsure which package manager you have and you have not modified it, then type in"
  c_info " default "
  w_info "to choose the default package manager that termux comes with."
  info "\n\ninput your package manager. [default / apt / pacman]: "
  read zzz
  case "$zzz" in
    Apt | apt | APT)
      __echoToPkg apt
      pkg="apt"
      clear
      bc_info "APT was chosen as the primary package manager.\n"
      return 0
      ;;
    Pacman | pacman | PACMAN)
      __echoToPkg pacman
      pkg="pacman"
      clear
      bc_info "PACMAN was chosen as the primary package manager.\n"
      return 0
      ;;
    Default | default | DEFAULT)
      __echoToPkg apt
      pkg="apt"
      clear
      bc_info "APT was chosen as the primary package manager.\n"
      return 0
      ;;
    *)
      critical "\ncritical: BAD input given, retry"
      sleep 0.6
      critical "."
      sleep 0.6
      critical "."
      sleep 0.6
      critical "."
      repkg
      ;;
  esac
fi

if [[ "$(cat ~/.pkg)" != "apt" && "$(cat ~/.pkg)" != "pacman" ]]; then
  clear
  for i in {1..40}; do     
    err "Invalid package variable detected!\n"
    sleep 0.005
  done
  sleep 0.5
  repkg
fi

declare -g pkg=$(cat ~/.pkg)
declare -g PKG="$pkg"
