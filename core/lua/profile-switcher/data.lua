-- /\/\/\/\ shared data

local M = {}

M.profile_file = vim.fn.expand("~/.config/nvim-active-profile")

M.switcher_path = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h") .. "/init.lua"

M.repo_root = vim.fn.fnamemodify(M.switcher_path, ":h:h:h")

M.profiles = {
  -- [PROFILES_START]
  { name = "Apostate", appname = "nvim-apostate" },
  { name = "Corporate", appname = "nvim-corporate" },
  { name = "Industrial", appname = "nvim-industrial" },
  { name = "Playground", appname = "nvim-playground" },
  { name = "Scribe", appname = "nvim-scribe" },
  { name = "Wired", appname = "nvim-wired" },
  -- [PROFILES_END]
}

return M
