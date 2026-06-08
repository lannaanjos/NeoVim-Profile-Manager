-- /\/\/\/\ theme configuration
--
-- To swap themes, replace the plugin repository, name, opts, and colorscheme.
-- Only one theme should be active at a time, so comment out the others.

return {

  -- Active theme: gruvbox
  -- Repository: https://github.com/ellisonleao/gruvbox.nvim
  {
    "ellisonleao/gruvbox.nvim",
    lazy = false, -- load at startup
    priority = 1000, -- load before other plugins to avoid flicker
    opts = {
      contrast = "hard", -- "hard", "medium" or "soft"
      transparent_mode = false, -- true to remove background color
      italic = {
        strings = true,
        comments = true,
        operators = false,
        folds = true,
      },
    },
  },

  -- Tell LazyVim which colorscheme to activate
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },

  -- /\/\/\/\ other themes (uncomment one to use instead)

  -- Catppuccin - https://github.com/catppuccin/nvim
  -- {
  --   "catppuccin/nvim",
  --   name = "catppuccin",
  --   lazy = false,
  --   priority = 1000,
  --   opts = {
  --     flavour = "mocha", -- "latte", "frappe", "macchiato", "mocha"
  --   },
  -- },
  -- { "LazyVim/LazyVim", opts = { colorscheme = "catppuccin" } },

  -- Tokyo Night - https://github.com/folke/tokyonight.nvim
  -- {
  --   "folke/tokyonight.nvim",
  --   lazy = false,
  --   priority = 1000,
  --   opts = {
  --     style = "night", -- "storm", "moon", "night", "day"
  --   },
  -- },
  -- { "LazyVim/LazyVim", opts = { colorscheme = "tokyonight" } },

  -- Monokai Pro - https://github.com/loctvl842/monokai-pro.nvim
  -- {
  --   "loctvl842/monokai-pro.nvim",
  --   lazy = false,
  --   priority = 1000,
  --   opts = {
  --     filter = "pro", -- "pro", "classic", "octagon", "machine", "ristretto", "spectrum"
  --   },
  -- },
  -- { "LazyVim/LazyVim", opts = { colorscheme = "monokai-pro" } },
}
