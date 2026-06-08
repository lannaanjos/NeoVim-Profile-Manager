-- /\/\/\/\ extra plugins
--
-- This file is for adding plugins beyond what LazyVim and the core already provide.
-- Each plugin entry follows the lazy.nvim spec:
-- https://lazy.folke.io/spec
--
-- To add a plugin, uncomment its block or create a new one following the same pattern.

return {

  -- /\/\/\/\ editing

  -- nvim-surround: add, change and delete surrounding pairs (quotes, brackets, tags)
  -- Usage: ys<motion><char> to add, cs<old><new> to change, ds<char> to delete
  -- Example: ysiw" wraps word in quotes, cs"' changes " to ', ds" removes "
  -- https://github.com/kylechui/nvim-surround
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup()
    end,
  },

  -- /\/\/\/\ git

  -- vim-fugitive: full Git integration inside Neovim
  -- Usage: :Git <command> runs any git command, :Git opens a status summary
  -- Example: :Git commit, :Git push, :Git log
  -- https://github.com/tpope/vim-fugitive
  -- {
  --   "tpope/vim-fugitive",
  --   cmd = "Git",
  -- },

  -- /\/\/\/\ ui

  -- todo-comments: highlight and search TODO, FIXME, NOTE and similar tags
  -- Usage: ]t / [t to jump between todos, :TodoTelescope to search all
  -- https://github.com/folke/todo-comments.nvim
  -- {
  --   "folke/todo-comments.nvim",
  --   event = "VeryLazy",
  --   dependencies = { "nvim-lua/plenary.nvim" },
  --   opts = {},
  -- },

  -- /\/\/\/\ navigation

  -- harpoon: bookmark files and jump between them instantly
  -- Usage: <leader>ha to add, <leader>hh to open menu
  -- https://github.com/ThePrimeagen/harpoon
  -- {
  --   "ThePrimeagen/harpoon",
  --   branch = "harpoon2",
  --   dependencies = { "nvim-lua/plenary.nvim" },
  --   config = function()
  --     local harpoon = require("harpoon")
  --     harpoon:setup()
  --     vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end, { desc = "Harpoon add file" })
  --     vim.keymap.set("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon menu" })
  --   end,
  -- },

  -- /\/\/\/\ ai

  -- copilot: GitHub Copilot integration
  -- Requires a GitHub account with Copilot access
  -- Run :Copilot auth to authenticate on first use
  -- https://github.com/zbirenbaum/copilot.lua
  -- {
  --   "zbirenbaum/copilot.lua",
  --   event = "InsertEnter",
  --   opts = {
  --     suggestion = {
  --       enabled = true,
  --       auto_trigger = true,
  --       keymap = {
  --         accept = "<Tab>",
  --         dismiss = "<Esc>",
  --       },
  --     },
  --   },
  -- },
}
