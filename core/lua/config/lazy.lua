-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- /\/\/\/\ carregamento direto dos specs do core por caminho absoluto
local core_plugins_dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h") .. "/core_plugins"

local function load_core_specs()
  local specs = {}
  for _, f in ipairs(vim.fn.glob(core_plugins_dir .. "/*.lua", false, true)) do
    local ok, result = pcall(dofile, f)
    if ok and type(result) == "table" then
      table.insert(specs, result)
    end
  end
  return specs
end

-- /\/\/\/\ configuracao do lazy.nvim
local core_specs = load_core_specs()

require("lazy").setup({
  spec = vim.list_extend(
    { { "LazyVim/LazyVim", import = "lazyvim.plugins" } },
    vim.list_extend(core_specs, { { import = "plugins" } })
  ),
  defaults = {
    lazy = false,
    version = false,
  },
  install = { colorscheme = { "habamax" } },
  checker = {
    enabled = true,
    notify = false,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

dofile(vim.fn.fnamemodify(core_plugins_dir, ":h") .. "/profile-switcher.lua")
