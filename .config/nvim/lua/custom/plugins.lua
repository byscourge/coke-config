-- One single place — all LSPs with the simple {} style
local lspconfig = require("lspconfig")
local configs   = require("nvchad.configs.lspconfig")  -- keeps NvChad keymaps + cmp

local servers = {
  "clangd",
  "pyright",
  "ts_ls",
  "html",
  "cssls",

  "jdtls",
  "kotlin_language_server",
  "gradle_ls",
  "jsonls",
  "yamlls",
  "taplo",           -- TOML
  "bufls",           -- Protobuf
  "marksman",        -- Markdown
  "cmake",
  "bashls",
  "lua_ls",
  "rust_analyzer",
  "gopls",
}

-- Simple one-liner for 99 % of servers
for _, server in ipairs(servers) do
  lspconfig[server].setup {
    on_attach    = configs.on_attach,
    capabilities = configs.capabilities,
  }
end

-- Only the 3 that actually need a tiny bit more love
lspconfig.jsonls.setup {
  on_attach    = configs.on_attach,
  capabilities = configs.capabilities,
  settings = { json = { schemas = require("schemastore").json.schemas(), validate = { enable = true } } },
}

lspconfig.yamlls.setup {
  on_attach    = configs.on_attach,
  capabilities = configs.capabilities,
  settings = { yaml = { schemaStore = { enable = true, url = "" }, schemas = require("schemastore").yaml.schemas() } },
}

lspconfig.lua_ls.setup {
  on_attach    = configs.on_attach,
  capabilities = configs.capabilities,
  settings = { Lua = { diagnostics = { globals = { "vim" } } } },
}




-- Auto-install everything (including the original 5)
{
  "williamboman/mason-lspconfig.nvim",
  after = "nvim-lspconfig",
  dependencies = { "b0o/schemastore.nvim" },
  config = function()
    require("mason-lspconfig").setup {
      ensure_installed = {
        "clangd", "pyright", "ts_ls", "html", "cssls",
        "jdtls", "kotlin_language_server", "gradle_ls",
        "jsonls", "yamlls", "taplo", "bufls",
        "marksman", "cmake", "bashls", "lua_ls",
        "rust_analyzer", "gopls",
      },
      automatic_installation = true,
    }
  end,
},

{ "b0o/schemastore.nvim" },


