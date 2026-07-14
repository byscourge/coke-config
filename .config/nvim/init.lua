vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "autocmds"

vim.schedule(function()
  require "mappings"
end)


-- Comprehensive comment styles for many languages
-- Line comments: string only
-- Block comments: "%s" placeholder
comment_styles = {
  lua = "--",
  python = "#",
  sh = "#",
  bash = "#",
  zsh = "#",
  vim = '"',
  ruby = "#",
  r = "#",
  perl = "#",
  php = "//",
  javascript = "/* %s */",
  js = "/* %s */",
  typescript = "/* %s */",
  ts = "/* %s */",
  java = "/* %s */",
  c = "/* %s */",
  cpp = "/* %s */",
  go = "//",
  rust = "//",
  kotlin = "//",
  swift = "//",
  html = "<!-- %s -->",
  xml = "<!-- %s -->",
  css = "/* %s */",
  scss = "/* %s */",
  sass = "/* %s */",
  json = "//",
  jsonc = "//",
  toml = "#",
  yaml = "#",
  markdown = "<!-- %s -->",
  dart = "//",
  sql = "--",
  lua51 = "--",
  cmake = "#",
  vimscript = '"',
  _default = "#", -- fallback
}

-- Global function to toggle comments in visual mode
function _G.toggle_comment()
  -- Get visual selection line numbers
  local s_start = vim.fn.getpos("'<")[2]
  local s_end = vim.fn.getpos("'>")[2]

  -- Determine comment style
  local ft = vim.bo.filetype
  local cstr = comment_styles[ft] or comment_styles._default

  local is_block = false
  local start_c, end_c = nil, nil
  if cstr:match("%%s") then
    is_block = true
    start_c, end_c = cstr:match("^(.-) %%s (.-)$")
    if not end_c then
      end_c = ""
    end
  end

  -- Get all lines in selection
  local lines = vim.fn.getline(s_start, s_end)

  if is_block then
    -- BLOCK COMMENT: wrap entire selection
    local first_line = lines[1]
    local last_line = lines[#lines]
    local already_commented = first_line:match("^%s*" .. vim.pesc(start_c)) and last_line:match(vim.pesc(end_c) .. "%s*$")

    if already_commented then
      -- Uncomment entire block
      lines[1] = lines[1]:gsub("^%s*" .. vim.pesc(start_c), "")
      lines[#lines] = lines[#lines]:gsub(vim.pesc(end_c) .. "%s*$", "")
    else
      -- Comment entire block
      lines[1] = start_c .. lines[1]
      lines[#lines] = lines[#lines] .. end_c
    end

    -- Replace selection with new lines
    vim.fn.setline(s_start, lines)
  else
    -- LINE COMMENT: toggle each line individually
    for i, line in ipairs(lines) do
      if line:match("^%s*" .. vim.pesc(cstr)) then
        -- Uncomment line
        lines[i] = line:gsub("^%s*" .. vim.pesc(cstr), "", 1)
      else
        -- Comment line
        lines[i] = cstr .. " " .. line
      end
    end

    vim.fn.setline(s_start, lines)
  end
end

-- Map F10 in visual mode to toggle comments
vim.api.nvim_set_keymap("v", "<F10>", ":<C-U>lua toggle_comment()<CR>", { noremap = true, silent = true })



vim.cmd [[
  hi Normal guibg=NONE ctermbg=NONE
  hi NormalNC guibg=NONE ctermbg=NONE
]]

vim.opt.guicursor = {
  "n:block",      -- normal mode = block
  "i:ver25",      -- insert mode = vertical bar
  "v:hor20",      -- visual mode = underscore
  "c:ver25"       -- command mode = vertical bar
}

vim.lsp.config.clangd = {
  cmd = {"clangd"},
  root_markers = {".clangd", "compile_commands.json", "compile_flags.txt"},
  filetypes = {"c", "cpp", "objc", "objcpp"},
}
vim.lsp.config.pyright = {
  cmd = {"pyright-langserver", "--stdio"},
  root_markers = {"pyproject.toml", "setup.py", "requirements.txt"},
  filetypes = {"python"},
}
-- Add others similarly
vim.lsp.enable({"clangd", "pyright", "ts_ls", "html", "cssls"})

-- vim.api.nvim_create_autocmd("BufNewFile", {
--   pattern = "*.html",
--   callback = function()
--     vim.api.nvim_buf_set_lines(0, 0, -1, false, {
--       "<!DOCTYPE html>",
--       ""
--     })
--   end,
-- })
