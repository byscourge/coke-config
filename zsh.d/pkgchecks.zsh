if [[ ! -f ~/.pkg ]]; then
  touch ~/.pkg
fi

pkg=$(cat ~/.pkg)
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
      echo "apt" > ~/.pkg
      pkg="apt"
      clear
      bc_info "APT was chosen as the primary package manager.\n"
      ;;
    Pacman | pacman | PACMAN)
      echo "pacman" > ~/.pkg
      pkg="pacman"
      clear
      bc_info "PACMAN was chosen as the primary package manager.\n"
      ;;
    Default | default | DEFAULT)
      echo "apt" > ~/.pkg
      pkg="apt"
      clear
      bc_info "APT was chosen as the primary package manager.\n"
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


PKG="$pkg"
