case "$PKG" in
  apt)
    apt update && apt install $(cat ~/.assets/deps/apt.txt)
    ;;
  pacman)
    pacman -Syu $(cat ~/.assets/deps/pacman.txt) --needed
    ;;
esac
