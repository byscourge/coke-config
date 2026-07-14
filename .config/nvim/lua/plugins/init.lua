return {
  {
    "stevearc/conform.nvim",
    opts = require "configs.conform",
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    main = "nvim-treesitter",
    config = function()
      require("nvim-treesitter").install({
        "c", "cpp", "python", "javascript", "typescript",
        "html", "css", "lua", "bash",
        "fish", "zsh", "tsx",
      })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "c", "cpp", "python", "javascript", "typescript",
          "html", "css", "lua", "bash",
          "sh", "zsh", "fish", "tsx", "python",
        },
        callback = function()
          vim.treesitter.start()
        end,
      })
    end,
  },
}
