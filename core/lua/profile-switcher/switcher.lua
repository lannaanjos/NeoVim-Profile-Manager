-- /\/\/\/\ profile switching logic

local M = {}

function M.setup(data)
  local function read_current()
    local f = io.open(data.profile_file, "r")
    if not f then
      return ""
    end
    local p = vim.trim(f:read("*l") or "")
    f:close()
    return p
  end

  local function apply_switch(appname)
    local f = io.open(data.profile_file, "w")
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
    for _, p in ipairs(data.profiles) do
      local label = p.appname == current and p.name .. " (active)" or p.name
      table.insert(choices, { label = label, appname = p.appname })
    end
    vim.ui.select(choices, {
      prompt = "Select profile:",
      format_item = function(item)
        return item.label
      end,
    }, function(choice)
      if choice then
        apply_switch(choice.appname)
      end
    end)
  end

  function M.profile_exists(name)
    for _, p in ipairs(data.profiles) do
      if p.name:lower() == name:lower() then
        return true
      end
    end
    return false
  end

  -- /\/\/\/\ :Profile command
  vim.api.nvim_create_user_command("Profile", function(opts)
    if opts.args ~= "" then
      local arg = opts.args:lower()
      for _, p in ipairs(data.profiles) do
        if p.name:lower() == arg then
          apply_switch(p.appname)
          return
        end
      end
      vim.notify("Profile not found: " .. opts.args, vim.log.levels.ERROR)
    else
      open_picker()
    end
  end, {
    nargs = "?",
    complete = function()
      return vim.tbl_map(function(p)
        return p.name
      end, data.profiles)
    end,
    desc = "Change NeoVim profile",
  })
end

return M
