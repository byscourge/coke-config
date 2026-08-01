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
export PREFIX="/data/data/com.termux/files/usr"
export PATH="$PREFIX/bin:$HOME/.local/bin"
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export TERM=xterm-256color
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
