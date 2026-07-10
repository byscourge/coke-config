# { https://github.com/Julow/Unexpected-Keyboard } reccomended for the best experience

## if you see "\n", it's a placeholder
## all commented due to safety reasons
## uncomment them yourself if you want

# bindkey -s '^[[19~' 'exit\n' # F8
# bindkey -s '\e[20~' 'pkill -9 -f com.termux\n' # F9
# bindkey -s '^[[21~' 'sz\n' # F10
# bindkey -s '^[[23~' 'ssz\n' # F11
# bindkey -s '^[[18~' 'se\n' # F7
# bindkey -s '^[[17~' '\n' # F6
# bindkey -s '^[OS'   '\n' # F4
# bindkey -s '^[OR'   'speedtest-go\n' # F3
# bindkey -s '^[[24~' 'nzsh\n' # F12
# if [[ $PKG == "apt" ]]; then
#   bindkey -s '^[OQ'   'apt update && apt upgrade -y\n' # F2
# elif [[ $PKG == "pacman" ]]; then
#   bindkey -s '^[OQ'   'pacman -Syu --noconfirm\n'
# fi
# bindkey -s '^[OP'   'cczsh\n' # F1
# bindkey -s '^[[15~' '\n' # F5
