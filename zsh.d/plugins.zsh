### bootstrap zinit (self-installs on first run) ###
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[[ -d $ZINIT_HOME ]] || mkdir -p "$(dirname $ZINIT_HOME)"
[[ -d $ZINIT_HOME/.git ]] || git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

### plugins ###
zinit snippet OMZP::git
zinit snippet OMZL::history.zsh
zinit snippet OMZL::key-bindings.zsh
zinit snippet OMZL::termsupport.zsh
zinit snippet OMZL::functions.zsh
zinit snippet OMZL::completion.zsh

zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light joshskidmore/zsh-fzf-history-search

### completions ###
autoload -Uz compinit && compinit
