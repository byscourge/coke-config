# https://github.com/byscourge/coke-config

# --------------------------------------------------
# --------------------------------------------------
# color functions & color codes
# foreground color = \033[38;2
# background color = \033[48;2

# non-colors
BOLD=$'\033[1m'
NC=$'\033[0m'

# colors
GREEN=$'\033[38;2;150;230;150m'
BRIGHT_GREEN=$'\033[1m\033[38;2;0;255;0m'

ORANGE=$'\033[38;2;255;100;0m'
RED=$'\033[38;2;240;98;107m'
BRIGHT_RED=$'\033[1m\033[38;2;255;0;0m'

BLUE=$'\033[1m\033[38;2;125;167;205m'
CYAN=$'\033[38;2;0;250;255m'
BRIGHT_CYAN=$'\033[1m\033[38;2;0;255;255m'

WHITE=$'\033[38;2;255;255;255m'
BRIGHT_WHITE=$'\033[1m\033[38;2;255;255;255m'

PINK=$'\033[38;2;255;0;255m'
PURPLE=$'\033[38;2;150;150;255m'
DARK_PURPLE=$'\033[38;2;130;85;255m'

GRAY=$'\033[38;2;69;79;96m'
BLACK=$'\033[38;2;0;0;0m'

# background colors
BG_GREEN=$'\033[48;2;150;230;150m'
BG_BRIGHT_GREEN=$'\033[1m\033[48;2;0;255;0m'

BG_ORANGE=$'\033[48;2;255;100;0m'
BG_RED=$'\033[48;2;240;98;107m'
BG_BRIGHT_RED=$'\033[1m\033[48;2;255;0;0m'

BG_BLUE=$'\033[1m\033[48;2;125;167;205m'
BG_CYAN=$'\033[48;2;0;250;255m'
BG_BRIGHT_CYAN=$'\033[1m\033[48;2;0;255;255m'

BG_WHITE=$'\033[48;2;255;255;255m'
BG_BRIGHT_WHITE=$'\033[1m\033[48;2;255;255;255m'

BG_PINK=$'\033[48;2;255;0;255m'
BG_PURPLE=$'\033[48;2;150;150;255m'
BG_DARK_PURPLE=$'\033[48;2;130;85;255m'

BG_GRAY=$'\033[48;2;69;79;96m'
BG_BLACK=$'\033[48;2;0;0;0m'

# color functions
# errors & debugging
critical() { printf "${BRIGHT_RED}%b${NC}" "$*" >&2; }
err() { printf "${RED}%b${NC}" "$*" >&2; }
warn() { printf "${ORANGE}%b${NC}" "$*" >&2; }
debug() { printf "${PURPLE}%b${NC}" "$*" >&2; }

# shorthand for printf
pf() { printf "%b" "$*"; }

# successes
ok() { printf "${GREEN}%b${NC}" "$*"; }
great() { printf "${BRIGHT_GREEN}%b${NC}" "$*"; }

# information
info() { printf "${BLUE}%b${NC}" "$*"; }
c_info() { printf "${CYAN}%b${NC}" "$*"; }
bc_info() { printf "${BRIGHT_CYAN}%b${NC}" "$*"; }
w_info() { printf "${WHITE}%b${NC}" "$*"; }
bw_info() { printf "${BRIGHT_WHITE}%b${NC}" "$*"; }
g_info() { printf "${GRAY}%b${NC}" "$*"; }

# asking questions & prompting
prompt() { printf "${DARK_PURPLE}%b${NC}" "$*"; }

# --------------------------------------------------
# --------------------------------------------------

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
export ct="/data/data/com.termux/"
