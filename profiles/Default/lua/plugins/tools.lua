-- /\/\/\/\ tools configuration
--
-- This file configures language servers (LSP), formatters and linters.
-- LSP servers are managed by mason.nvim, which installs them automatically.
--
-- To add a new language server, add its name under opts.servers.
-- To add a new formatter, add it under opts.formatters_by_ft.
-- To add a new linter, add it under opts.linters_by_ft.

return {

  -- /\/\/\/\ LSP servers
  -- Full list of available servers: https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {

        -- Lua (useful for editing your own Neovim config)
        lua_ls = {},

        -- Python
        -- pyright = {},

        -- TypeScript / JavaScript
        -- ts_ls = {},

        -- Rust
        -- rust_analyzer = {},

        -- Go
        -- gopls = {},

        -- C / C++
        -- clangd = {},
      },
    },
  },

  -- /\/\/\/\ formatters
  -- Full list of available formatters: https://github.com/stevearc/conform.nvim
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {

        -- Lua
        lua = { "stylua" },

        -- Python (install one: "black", "ruff_format", "isort")
        -- python = { "black" },

        -- TypeScript / JavaScript
        -- typescript = { "prettier" },
        -- javascript = { "prettier" },

        -- Rust (comes with rust_analyzer, no extra setup needed)
        -- rust = { "rustfmt" },
      },
    },
  },

  -- /\/\/\/\ linters
  -- Full list of available linters: https://github.com/mfussenegger/nvim-lint
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {

        -- Python
        -- python = { "ruff" },

        -- TypeScript / JavaScript
        -- typescript = { "eslint_d" },
        -- javascript = { "eslint_d" },
      },
    },
  },
}
