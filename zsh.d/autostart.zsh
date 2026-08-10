if [[ "$__missingmod" == "true" ]]; then
  info "Missing files were encountered during startup! please be sure to grab the latest modules alltogether from:\n${WHITE}https://github.com/byscourge/coke-config${NC}\n\n"
else
  pkgdisplay
fi
