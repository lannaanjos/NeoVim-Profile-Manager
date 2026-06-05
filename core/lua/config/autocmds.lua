-- para de inserir comentário automático em cada linha
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions = vim.opt_local.formatoptions - { "r", "o" }
  end,
})

-- /\/\ PROFILE SWITCH
local profile_file = vim.fn.expand("~/.config/nvim-active-profile")

local profiles = {
  { name = "Apostate", appname = "nvim-apostate" },
  { name = "Corporate", appname = "nvim-corporate" },
  { name = "Industrial", appname = "nvim-industrial" },
  { name = "Playground", appname = "nvim-playground" },
  { name = "Scribe", appname = "nvim-scribe" },
  { name = "Wired", appname = "nvim-wired" },
}

local function read_current()
  local f = io.open(profile_file, "r")
  if not f then
    return ""
  end
  local p = vim.trim(f:read("*l") or "")
  f:close()
  return p
end

local function apply_switch(appname)
  local f = io.open(profile_file, "w")
  if f then
    f:write(appname)
    f:close()
  end
  vim.cmd("silent! wa")
  vim.cmd("qa!")
end

local function open_picker()
  local current = read_current()
  local choices = {}
  for _, p in ipairs(profiles) do
    local label = p.appname == current and p.name .. " (ativo)" or p.name
    table.insert(choices, { label = label, appname = p.appname })
  end
  vim.ui.select(choices, {
    prompt = "Selecionar perfil:",
    format_item = function(item)
      return item.label
    end,
  }, function(choice)
    if choice then
      apply_switch(choice.appname)
    end
  end)
end

vim.api.nvim_create_user_command("Profile", function(opts)
  if opts.args ~= "" then
    local arg = opts.args:lower()
    for _, p in ipairs(profiles) do
      if p.name:lower() == arg then
        apply_switch(p.appname)
        return
      end
    end
    vim.notify("perfil nao encontrado: " .. opts.args, vim.log.levels.ERROR)
  else
    open_picker()
  end
end, {
  nargs = "?",
  complete = function()
    return vim.tbl_map(function(p)
      return p.name
    end, profiles)
  end,
  desc = "trocar perfil do neovim",
})
