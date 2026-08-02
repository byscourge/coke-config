if [[ ! -f ~/.pkg ]]; then
  touch ~/.pkg
fi

local __echoToPkg() {
  echo "$1" > ~/.pkg
}

alias repkg='rm ~/.pkg && szsh'
alias szsh='clear && exec zsh'

if [[ ! -s ~/.pkg ]]; then
      if [[ -f $PREFIX/bin/apt && -f $PREFIX/bin/pacman ]]; then
        echo "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
        err "Unable to set package manager as you have two (apt + pacman).\n"
        info "Choose your primary [ apt / pacman ]: "
        local zzz
        read -r zzz
        case "$zzz" in
           Apt | apt | APT)
             __echoToPkg apt
             pkg="apt"
             clear
             bc_info "APT was set as the primary package manager.\n"
             return 0
             ;;
 
           Pacman | pacman | PACMAN)
             __echoToPkg pacman
             pkg="pacman"
             clear
             bc_info "PACMAN was set as the primary package manager.\n"
             return 0
             ;;

           *)
             err "Invalid prompt!"
             sleep 1
             repkg
             ;;
         esac
      fi

      if [[ ! -f $PREFIX/bin/apt && ! -f $PREFIX/bin/pacman ]]; then
        err "Unable to set package manager as no supported were detected.\n"
        rm ~/.pkg
        return
      fi

      if [[ -f $PREFIX/bin/apt ]]; then
        __echoToPkg apt
        pkg="apt"
        clear
        bc_info "APT was set as the primary package manager.\n"
        return 0
      fi

      if [[ -f $PREFIX/bin/pacman ]]; then
        __echoToPkg pacman
        pkg="pacman"
        clear
        bc_info "PACMAN was set as the primary package manager.\n"
        return 0
      fi
fi

filevalid="$(cat ~/.pkg)"





if [[ "$filevalid" != "apt" && "$filevalid" != "pacman" ]]; then
  clear
  for i in {1..30}; do     
    err "Invalid package variable detected!\n"
    sleep 0.005
  done
  repkg
fi

if [[ "$filevalid" == "apt" ]]; then
  if [[ ! -f $PREFIX/bin/apt ]]; then
    for i in {1..30}; do     
      err "Invalid package variable detected!\n"
      sleep 0.005
    done
    repkg
  fi
fi

if [[ "$filevalid" == "pacman" ]]; then
  if [[ ! -f $PREFIX/bin/pacman ]]; then
    for i in {1..30}; do     
      err "Invalid package variable detected!\n"
      sleep 0.005
    done
    repkg
  fi
fi

declare -g pkg=$(cat ~/.pkg)
declare -g PKG="$pkg"
