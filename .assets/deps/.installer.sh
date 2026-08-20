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



asci3="
 #####  
#     # 
      # 
 #####  
      # 
#     # 
 #####\n"
asci2="
 #####  
#     # 
      # 
 #####  
#       
#       
#######\n"
asci1="
  #   
 ##   
# #   
  #   
  #   
  #   
#####\n"


## ============================

termux-setup-storage() {

  local -a filepaths=(
    "$HOME/storage/dcim"
    "$HOME/storage/downloads"
    "$HOME/storage/movies"
    "$HOME/storage/music"
    "$HOME/storage/pictures"
    "$HOME/storage/shared"
  )

  local -a storagepaths=(
    "/storage/emulated/0/DCIM"
    "/storage/emulated/0/Download"
    "/storage/emulated/0/Movies"
    "/storage/emulated/0/Music"
    "/storage/emulated/0/Pictures"
    "/storage/emulated/0"
  )

  if [[ -d "$HOME/storage" ]]; then
    printf "

    It appears that directory '~/storage' already exists.
    This script is going to rebuild its structure from
    scratch, wiping all dangling files. The actual storage
    content IS NOT going to be deleted.\n"
    read -re -p "Do you want to continue? (y/n) " CHOICE

    if ! [[ "${CHOICE}" =~ (Y|y) ]]; then
      echo "Aborting configuration and leaving directory '~/storage' intact."
      return 1
    fi
  fi

  case "${TERMUX__USER_ID:-}" in ''|*[!0-9]*|0[0-9]*) TERMUX__USER_ID=0;; esac

  am broadcast --user "$TERMUX__USER_ID" \
    -a "com.termux.app.reload_style" \
    --es "com.termux.app.reload_style" "storage" \
     "com.termux" > /dev/null

  mkdir -p "$HOME/storage/" 2>/dev/null

    for file in "${filepaths[@]}"; do
      if [[ -L "$file" ]]; then
        rm "$file" 2>/dev/null
      fi
    done

    for i in {0..5}; do
      ln -sf "${storagepaths[i]}" "${filepaths[i]}"
    done

}


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

setupStorage() {
  printf "${BRIGHT_GREEN}====> ${BLUE}Setting up storage..${NC}\n"
  printf "${BRIGHT_CYAN}Please accept the permissions popup.\n"
  termux-setup-storage
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
      sh <(curl -fsSL https://raw.githubusercontent.com/byscourge/coke-config/master/.assets/deps/.pacmandeps.sh) && return 0
      ;;
    2)
      printf "${BRIGHT_GREEN}====> ${BLUE}Package manager is apt!\n${NC}"
      printf "${BRIGHT_GREEN}====> ${BLUE}Installing dependencies..\n${NC}"
      sleep 1
      sh <(curl -fsSL https://raw.githubusercontent.com/byscourge/coke-config/master/.assets/deps/.aptdeps.sh) && return 0
      ;;
    3)
      printf "${RED}No usable package managers detected!${NC}\n"
      exit 1
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
          sh <(curl -fsSL https://raw.githubusercontent.com/byscourge/coke-config/master/.assets/deps/.aptdeps.sh) && return 0
         ;;
        pacman)
          printf "${BRIGHT_GREEN}====> ${BLUE}Installing dependencies..\n${NC}"
          sleep 1
          sh <(curl -fsSL https://raw.githubusercontent.com/byscourge/coke-config/master/.assets/deps/.pacmandeps.sh) && return 0
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
    exit 1
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

  showbanner
  setupStorage

  clear
  printf "${BLUE}$INSTALLCOMP"
  printf "\n\n\n\n"
  printf "${BRIGHT_WHITE}
  Closing termux in:
-----------------------"
  sleep 2.5
  printf "\n${BLUE}$asci3"
  sleep 1
  printf "\n${BLUE}$asci2"
  sleep 1
  printf "\n${BLUE}$asci1"
  sleep 1
  printf "${BRIGHT_WHITE}
         Please reopen termux!.
----------------------------------------"
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
          printf "${BRIGHT_RED} Dependencies could not be satisfied!\n"
          exit 1
        }

        showbanner

        backupHome || {
          showbanner
          printf "${BRIGHT_RED}\$HOME Could not be backed up!\n"
          exit 1
        }

        installDotfiles || {
          showbanner
          printf "${RED}Installation failed!\n"
          rm -rfv "$nanodatebk"
          exit 1
        }

          setupConf
          finishInstall

        ;;
      *)
        printf "${BRIGHT_WHITE}\nAbort.${NC}\n" ;;
    esac
   ;;
  *) printf "${BRIGHT_WHITE}\nAbort.${NC}\n" ;;
esac

# no need for a trap - INT, termux is forcefully killed
