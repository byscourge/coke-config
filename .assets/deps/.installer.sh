#!/bin/bash

trap '' INT

insdate="$(date +%Y%m%d%H%M%S)"
nanodate="$(date +%N)"

[[ -n "$HOME" ]] || exit 1

cd "$HOME"/..
currentworkingdir="$(realpath $HOME/..)"

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
  cp -av "$HOME" "/data/data/com.termux/files/backup_home/${insdate}_home" && \
    printf "${BRIGHT_GREEN}====> ${GREEN}Success! HOME was copied to:\n${WHITE}/data/data/com.termux/files/backup_home/${insdate}_home${NC}"

}

installDotfiles() {
  showbanner
  printf "${BRIGHT_GREEN}====> ${BLUE}Installing coke-config..\n${NC}"

  nanodatebk="$currentworkingdir/$nanodate"

  git clone --depth=1 https://github.com/byscourge/coke-config "$nanodatebk"
  [[ -d "$nanodatebk" ]] || {
    printf "${RED}Failed to clone dir!${NC}\n"
    return 1
  }

  printf "${BRIGHT_GREEN}====> ${BLUE}Replacing HOME..\n${NC}"
  sleep 1

  rm -rf "$nanodatebk/.git"
  rm -rfv "$nanodatebk/README.md"
  rm -rfv "$nanodatebk/LICENSE"

  rm -rfv "$HOME"
  mv "$nanodatebk" "${currentworkingdir}/home"
}

setupConf() {
  showbanner
  printf "${BRIGHT_GREEN}====> ${BLUE}Changing default shell to ZSH..\n${NC}"
  sleep 1
  chsh -s zsh
  printf "${BRIGHT_GREEN}====> ${BLUE}Installing ZINIT..\n"
  printf "${BRIGHT_GREEN}====> ${BLUE}Setting up neovim..${NC}\n"
  sleep 1
  cd "$HOME"
  zsh -c -i "nvim --headless '+Lazy! install' +qa ; exit"
}

finishInstall() {

  clear
  printf "${BLUE}$INSTALLCOMP"
  sleep 2.5
  printf "\n${BLUE}3"
  sleep 1
  printf "\n${BLUE}2"
  sleep 1
  printf "\n${BLUE}1"
  sleep 0.5
  printf "${BRIGHT_WHITE}
         Closing termux! please reopen.
------------------------------------------------"
  sleep 2.5
  pkill -9 -f com.termux
}

############# ============> FUNCTIONS END

answer=""
showbanner

printf "
${RED}Warning: this will overwrite all files in your home directory,${NC}
${BLUE}BUT your old home will be backed up & stored at:${NC}

${WHITE}/data/data/com.termux/files/backup_home/${insdate}_home${NC}

${BRIGHT_WHITE}make sure to WRITE DOWN the path above as it is the only backup of your current configurations.${NC}

Your current home is: ${WHITE}$HOME${NC}\n"
printf "\n${CYAN}Continue with installation? [y/N]:${NC} "
read -r answer
case "$answer" in
  y|Y)
    really=""
    printf "\n${CYAN}Are you sure? [y/N]:${NC} "
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
          installDotfiles && {
          setupConf
          finishInstall
          } || \
          clear && printf "${RED}installation failed! abort..\n" && exit 1

        } || \
          clear && printf "${RED}Backup failed! abort..\n" && exit 1
        ;;
      *)
        printf "${BRIGHT_WHITE}\nAbort.${NC}\n" ;;
    esac
   ;;
  *) printf "${BRIGHT_WHITE}\nAbort.${NC}\n" ;;
esac

# no need for a trap - INT, termux is forcefully killed
