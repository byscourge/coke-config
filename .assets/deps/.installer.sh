#!/bin/bash

trap '' INT

insdate="$(date +%Y%m%d%H%M%S)"

[[ -n "$HOME" ]] || exit 1

cd $HOME/..

############# ============> FUNCTIONS

# COLORS
BOLD=$'\033[1m'
GREEN=$'\033[38;2;150;230;150m'
BRIGHT_GREEN=$'\033[1m\033[38;2;0;255;0m'
RED=$'\033[38;2;240;98;107m'
BRIGHT_RED=$'\033[1m\033[38;2;255;0;0m'
ORANGE=$'\033[38;2;255;120;0m'
CYAN=$'\033[38;2;0;250;255m'
BRIGHT_CYAN=$'\033[1m\033[38;2;0;255;255m'
WHITE=$'\033[38;2;255;255;255m'
BRIGHT_WHITE="\033[1m\033[38;2;255;255;255m"
BLUE=$'\033[1m\033[38;2;125;167;205m'
GRAY=$'\033[38;2;69;79;96m'
PINK=$'\033[38;2;255;0;255m'

NC=$'\033[0m'


BANNER="           _                           __ _
  ___ ___ | | _____    ___ ___  _ __  / _(_) __ _
 / __/ _ \| |/ / _ \  / __/ _ \| '_ \| |_| |/ _\` |
| (_| (_) |   <  __/ | (_| (_) | | | |  _| | (_| |
 \___\___/|_|\_\___|  \___\___/|_| |_|_| |_|\__, |
                                            |___/
 _           _        _ _       _   _               _
(_)_ __  ___| |_ __ _| | | __ _| |_(_) ___  _ __   | |
| | '_ \/ __| __/ _\` | | |/ _\` | __| |/ _ \| '_ \  | |
| | | | \__ \ || (_| | | | (_| | |_| | (_) | | | | |_|
|_|_| |_|___/\__\__,_|_|_|\__,_|\__|_|\___/|_| |_| (_)\n\n"

INSTALLCOMP="
 ___           _        _ _                             _      _         _
|_ _|_ __  ___| |_ __ _| | |   ___ ___  _ __ ___  _ __ | | ___| |_ ___  | |
 | || '_ \/ __| __/ _\` | | |  / __/ _ \| '_ \` _ \| '_ \| |/ _ \ __/ _ \ | |
 | || | | \__ \ || (_| | | | | (_| (_) | | | | | | |_) | |  __/ ||  __/ |_|
|___|_| |_|___/\__\__,_|_|_|  \___\___/|_| |_| |_| .__/|_|\___|\__\___| (_)
                                                 |_|"

## ============================

showbanner() {
  clear
  printf "${CYAN}${BANNER}${NC}\n\n"
}

runsilent() {
  {
    {
      eval "$*" # only meant to be used as one command
    } &>/dev/null && return 0
  } || return 1
}

pkgcheck() {
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


installDeps() {
  showbanner
  printf "${BRIGHT_GREEN}====> ${BLUE}Checking package manager..\n${NC}"
  pkgcheck
  case "$?" in
    1)
      printf "${BRIGHT_GREEN}====> ${BLUE}Package manager is pacman!\n${NC}"
      printf "${BRIGHT_GREEN}====> ${BLUE}Installing dependencies..\n${NC}"
      sleep 1
      sh <(curl -fsSL https://raw.githubusercontent.com/byscourge/coke-config/master/.assets/deps/.pacmandeps.sh)
      ;;
    2)
      printf "${BRIGHT_GREEN}====> ${BLUE}Package manager is apt!\n${NC}"
      printf "${BRIGHT_GREEN}====> ${BLUE}Installing dependencies..\n${NC}"
      sleep 1
      sh <(curl -fsSL https://raw.githubusercontent.com/byscourge/coke-config/master/.assets/deps/.aptdeps.sh)
      ;;
    3)
      printf "${RED}No usable package managers detected!${NC}\n"
      return
      ;;
    4)
      printf "${BRIGHT_GREEN}====> ${BLUE}It seems like you have two package managers.\nWould you like to use ${BRIGHT_CYAN}apt${BLUE} or${BRIGHT_CYAN} pacman${BLUE}?\n${NC}"
      printf "${NC}[ apt / pacman ]: "
      packageans=""
      read -r packageans
      case "$packageans" in
        apt)
          printf "${BRIGHT_GREEN}====> ${BLUE}Installing dependencies..\n${NC}"
          sleep 1
          sh <(curl -fsSL https://raw.githubusercontent.com/byscourge/coke-config/master/.assets/deps/.aptdeps.sh)
         ;;
        pacman)
          printf "${BRIGHT_GREEN}====> ${BLUE}Installing dependencies..\n${NC}"
          sleep 1
          sh <(curl -fsSL https://raw.githubusercontent.com/byscourge/coke-config/master/.assets/deps/.pacmandeps.sh)
          ;;
        *)
          printf "${BRIGHT_GREEN}====> ${RED}Invalid input! retry. . .\n${NC}"
          installDeps
          ;;
      esac
      ;;
  esac
}

backupHome() {
  [[ -d /data/data/com.termux/files/backup_home/ ]] || mkdir -p /data/data/com.termux/files/backup_home/
  showbanner
  printf "${BRIGHT_GREEN}====> ${BLUE}Backing up your home directory..\n${NC}"
  sleep 1.5
  cp -av $HOME "/data/data/com.termux/files/backup_home/${insdate}_home" && \
    printf "${BRIGHT_GREEN}====> ${GREEN}Success! HOME was copied to:\n${WHITE}/data/data/com.termux/files/backup_home/${insdate}_home${NC}"

}

installDotfiles() {
  showbanner
  printf "${BRIGHT_GREEN}====> ${BLUE}Installing coke-config..\n${NC}"
    cd $HOME/..
    # obscure name to ensure that no external files will be removed
    [[ -d TEMPFILEDIR000xx ]] && rm -rf TEMPFILEDIR000xx13
    git clone --depth=1 https://github.com/byscourge/coke-config TEMPFILEDIR000xx13 && \
    [[ -d TEMPFILEDIR000xx13 ]] && \
    printf "${BRIGHT_GREEN}====> ${BLUE}Replacing HOME..\n${NC}"
    sleep 1
    cd TEMPFILEDIR000xx13
    rm -rf .git README.md LICENSE
    cd ..
    rm -rf $HOME
    mv TEMPFILEDIR000xx13 home
}

setupConf() {
  printf "${BRIGHT_GREEN}====> ${BLUE}Changing default shell to ZSH..\n${NC}"
  sleep 1
  chsh -s zsh
  showbanner
  printf "${BRIGHT_GREEN}====> ${BLUE}Installing ZINIT..\n"
  sleep 1
  cd $HOME
  zsh -c -i "exit"
}

setupNeovim() {
  showbanner
  printf "${BRIGHT_GREEN}====> ${BLUE}Setting up neovim..\n"
  sleep 1.5
  nvim --headless -c 'q!' &>/dev/null && {
    nvim --headless "+Lazy! install" +qa
    nvim --headless "+Lazy! sync" +qa
  }
}

finishInstall() {

  clear
  printf "${BLUE}$INSTALLCOMP"
  sleep 2.5
  printf "\n${BLUE}3333333333"
  sleep 1
  printf "\n${BLUE}2222222222"
  sleep 1
  printf "\n${BLUE}1111111111"
  printf "${BRIGHT_WHITE}
         Closing termux! please reopen.
------------------------------------------------"
  sleep 2.5
  pkill -9 -f com.termux
}

############# ============> FUNCTIONS END

answer=""
showbanner

printf "Warning: this will overwrite files in your Home directory, your old home will be stored at: ${WHITE}[/data/data/com.termux/files/backup_home/${insdate}_home]${NC}\n\nYour current home is:\n$HOME"
printf "\n${BLUE}Continue with installation? [y/N]:${NC} "
read -r answer
case "$answer" in
  y|Y)
    really=""
    printf "\n${BLUE}Sure? [y/N]:${NC} "
    read -r really
    case "$really" in
      y|Y)
        installDeps || {
          showbanner
          printf "${RED}It seems like the dependencies couldnt be resolved, retrying..."
        clear
        installDeps || printf "${RED}Dependencies unsatisfied, Abort...\n"
      }
        showbanner
        backupHome && {
          installDotfiles && \
          setupConf
          setupNeovim
          finishInstall
        }
        ;;
      *)
        printf "${BRIGHT_WHITE}\nAbort.${NC}\n" ;;
    esac
   ;;
  *) printf "${BRIGHT_WHITE}\nAbort.${NC}\n" ;;
esac

# no need for a trap - INT, termux is forcefully killed
