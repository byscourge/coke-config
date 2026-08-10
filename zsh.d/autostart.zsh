if [[ "$__missingmod" == "true" ]]; then
  info "Missing files were encountered during startup! please be sure to grab the latest modules alltogether from:\n${WHITE}https://github.com/byscourge/coke-config${NC}\n\n"
  return 1
fi

if [[ -z "$TMUX" ]]; then
if [[ -z $DISPLAY ]]; then
  case "$-" in
    *i*)
    if [[ $pkg == "pacman" ]]; then
       pacman -V | awk '{
        lights[1]=51; lights[2]=87; lights[3]=123
        text = $0
        len = length(text)
        step = 6  
        for(i=1;i<=len;i+=step){
            chunk = substr(text,i,step)
            color = lights[((i-1)/step) % 3 + 1]
            printf "\033[38;5;%sm%s\033[0m", color, chunk
        }
        printf "\n"
    }'
    elif [[ $pkg == "apt" ]]; then
      ok "$(apt --version)\n"
    fi
    ;;
    *)
    return
    ;;
  esac
else
  case "$pkg" in
    pacman)
      :
      ;;
    apt)
    apt --version
    ;;
  esac
fi
fi
