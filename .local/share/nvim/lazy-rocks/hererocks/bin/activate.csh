which deactivate-lua >&/dev/null && deactivate-lua

alias deactivate-lua 'if ( -x '\''/data/data/com.termux/files/home/.local/share/nvim/lazy-rocks/hererocks/bin/lua'\'' ) then; setenv PATH `'\''/data/data/com.termux/files/home/.local/share/nvim/lazy-rocks/hererocks/bin/lua'\'' '\''/data/data/com.termux/files/home/.local/share/nvim/lazy-rocks/hererocks/bin/get_deactivated_path.lua'\''`; rehash; endif; unalias deactivate-lua'

setenv PATH '/data/data/com.termux/files/home/.local/share/nvim/lazy-rocks/hererocks/bin':"$PATH"
rehash
