if functions -q deactivate-lua
    deactivate-lua
end

function deactivate-lua
    if test -x '/data/data/com.termux/files/home/.local/share/nvim/lazy-rocks/hererocks/bin/lua'
        eval ('/data/data/com.termux/files/home/.local/share/nvim/lazy-rocks/hererocks/bin/lua' '/data/data/com.termux/files/home/.local/share/nvim/lazy-rocks/hererocks/bin/get_deactivated_path.lua' --fish)
    end

    functions -e deactivate-lua
end

set -gx PATH '/data/data/com.termux/files/home/.local/share/nvim/lazy-rocks/hererocks/bin' $PATH
