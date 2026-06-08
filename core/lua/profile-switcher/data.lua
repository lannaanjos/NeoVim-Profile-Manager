-- /\/\/\/\ shared data

local M = {}

M.profile_file = vim.fn.expand("~/.config/nvim-active-profile")

M.repo_root = vim.fn.fnamemodify(M.switcher_path, ":h:h:h")

M.profiles = {
  -- [PROFILES_START]
  { name = "Default", appname = "nvim-default" },
  { name = "Misc", appname = "nvim-misc" },
  -- [PROFILES_END]
}

return M
