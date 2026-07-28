HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
bindkey -e
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify
setopt INTERACTIVE_COMMENTS
export pkg
export PREFIX="/data/data/com.termux/files/usr" #most termux bins usually use prefix plus its handy
export PATH="$PREFIX/bin:$HOME/.local/bin" ## cleaned up and removed :PATH so it doesnt show like 5 fucking instances of the same paths, if i do need another path i can just add it here.
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export TERM=xterm-256color ## pretty colors
export EDITOR=nvim
export COLUMNS LINES
export bin="$PREFIX/bin/"
export lib="$PREFIX/lib/"
export libexec="$PREFIX/libexec/"
export etc="$PREFIX/etc/"
export usr="$PREFIX"
export prefix="$PREFIX"
export share="$PREFIX/share/"
export PKG=$pkg
export ct="/data/data/com.termux/"
