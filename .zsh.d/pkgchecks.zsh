# https://github.com/byscourge/coke-config

## TERMUX package manager detection flow

PKGBASE="$HOME/.assets/"
PKGFILE="$PKGBASE/pkg"

[[ ! -d "$PKGBASE" ]] && mkdir -p "$PKGBASE"

local __echoToPkg() {
  echo "$1" > $PKGFILE
}

alias repkg='rm $PKGFILE && szsh'
alias szsh='clear && exec zsh'

runsilent() {
  {
    {
      eval "$*" # only meant to be used as one command
    } &>/dev/null && return 0
  } || return 1
}

pkgcheck() {

  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    printf "
${BLUE}Termux package manager detection${NC}
    ${RED}Caution: do not use with && or || chains, as it always returns an error.${NC}
  
  ${WHITE}Scripting usage${NC}:

    Capture \$?

    if return code is ${BLUE}1${NC}, usable package manager is ${WHITE}pacman${NC}
    if return code is ${BLUE}2${NC}, usable package manager is ${WHTIE}apt${NC}

    if return code is ${RED}3${NC}, there are no usable package managers.
    if return code is ${RED}4${NC}, both apt & pacman exist on the termux install.


    ${BRIGHT_WHITE}ACT ACCORDINGLY, it is up to the PARENT script to handle these.
    \n"
    return
    fi


    aptstate=false
    pacmanstate=false

    runsilent apt --version && aptstate=true
    runsilent pacman -V && pacmanstate=true

    if [[ "$aptstate" == "true" ]]; then
      if [[ "$pacmanstate" == "true" ]]; then
        return 4
      else
        return 2
      fi
    else
      if [[ "$pacmanstate" == "true" ]]; then
        return 1
      else
        return 3
      fi
    fi
}

setpkg() {
  [[ -n "$1" ]] || return 1

  case "$1" in
    apt)
      __echoToPkg apt
      pkg="apt"
      clear
      bc_info "APT was set as the primary package manager.\n"
    ;;

     pacman)
       __echoToPkg pacman
       pkg="pacman"
       clear
       bc_info "PACMAN was set as the primary package manager.\n"
      ;;

    *)
      return 1
      ;;
  esac
}


pkgdisplay() {
if [[ -z "$TMUX" ]]; then
  case "$-" in
    *i*)
      case "$pkg" in
        pacman) c_info "$(pacman -V)\n\n" ;;
        apt) ok "$(apt --version)\n" ;;
      esac
    ;;
    *)
      return
    ;;
  esac
fi
}

trap '' INT

if [[ ! -f $PKGFILE ]]; then
  touch $PKGFILE
fi

if [[ ! -s $PKGFILE ]]; then
  pkgcheck
  case "$?" in
    4) echo "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
        err "Unable to set package manager as you have two (apt + pacman).\n"
        info "Choose your primary [ apt / pacman ]: "
        local zzz
        read -r zzz
        case "$zzz" in
           Apt | apt | APT)
             setpkg apt
             return 0
             ;;
 
           Pacman | pacman | PACMAN)
             setpkg pacman
             return 0
             ;;

           *)
             err "Invalid prompt!"
             sleep 1
             repkg
             ;;
         esac
         ;;

       3) err "Unable to set package manager as no supported were detected.\n"
        rm $PKGFILE
        return
        ;;

      2)
        setpkg apt
        return 0
        ;;

      1)
        setpkg pacman
        return 0
        ;;
  esac
fi

filevalid="$(cat $PKGFILE)"


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

declare -g pkg=$(cat $PKGFILE)
declare -g PKG="$pkg"

trap - INT
