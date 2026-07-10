-- LuaRocks configuration

rocks_trees = {
   { name = "user", root = home .. "/.luarocks" };
   { name = "system", root = "/data/data/com.termux/files/home/.local/share/nvim/lazy-rocks/hererocks" };
}
variables = {
   LUA_DIR = "/data/data/com.termux/files/home/.local/share/nvim/lazy-rocks/hererocks";
   LUA_BINDIR = "/data/data/com.termux/files/home/.local/share/nvim/lazy-rocks/hererocks/bin";
   LUA_VERSION = "5.1";
   LUA = "/data/data/com.termux/files/home/.local/share/nvim/lazy-rocks/hererocks/bin/lua";
}
