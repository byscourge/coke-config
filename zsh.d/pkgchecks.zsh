if [[ ! -f ~/.pkg ]]; then
  touch ~/.pkg
fi

pkg=$(cat ~/.pkg)
if [[ ! -s ~/.pkg ]]; then
  echo -ne "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nif you input something incorrectly, you can run repkg to run this prompt again."
  echo -ne "\n\ninput your package manager. [apt = 1 / pacman = 2] "
  read zzz
    if [[ $zzz = "1" ]]; then
      echo "apt" > ~/.pkg
      pkg="apt"
      clear
    elif [[ $zzz = "2" ]]; then
      echo "pacman" > ~/.pkg
      pkg="pacman"
      clear
    else
      err "E: Invalid INT\n"
    fi
fi
