-- /\/\/\/\ profile management commands

local M = {}

function M.setup(data, fs, switcher)
  -- /\/\/\/\ :NewProfile command
  vim.api.nvim_create_user_command("NewProfile", function(opts)
    local name = opts.args
    if name == "" then
      vim.notify("[ERROR] Insert new profile name", vim.log.levels.ERROR)
      return
    end

    if switcher.profile_exists(name) then
      vim.notify("[WARNING] Profile already exists: " .. name, vim.log.levels.WARN)
      return
    end

    local appname = "nvim-" .. name:lower()

    local ok, profile_dir = fs.create_profile(name, appname)
    if not ok then
      return
    end

    if not fs.register(name, appname) then
      return
    end

    table.insert(data.profiles, { name = name, appname = appname })

    vim.notify(
      string.format(
        "[NewProfile] Profile '%s' successfully created!\nRemember to add the alias to your ~/.bashrc (see %s/lua/plugins/base.lua)",
        name,
        profile_dir
      ),
      vim.log.levels.INFO
    )
  end, {
    nargs = 1,
    desc = "Create new NeoVim profile",
  })

  -- /\/\/\/\ :EditProfile command
  vim.api.nvim_create_user_command("EditProfile", function(opts)
    local name = opts.args
    if name == "" then
      vim.notify("[ERROR] Insert profile name", vim.log.levels.ERROR)
      return
    end

    if not switcher.profile_exists(name) then
      vim.notify("[ERROR] Profile not found: " .. name, vim.log.levels.ERROR)
      return
    end

    local profile_dir = data.repo_root .. "/profiles/" .. name
    Snacks.terminal(nil, { cwd = profile_dir })
  end, {
    nargs = 1,
    complete = function()
      return vim.tbl_map(function(p)
        return p.name
      end, data.profiles)
    end,
    desc = "Edit NeoVim profile",
  })

  -- /\/\/\/\ :DeleteProfile command
  vim.api.nvim_create_user_command("DeleteProfile", function(opts)
    local name = opts.args
    if name == "" then
      vim.notify("[ERROR] Insert profile name", vim.log.levels.ERROR)
      return
    end

    if not switcher.profile_exists(name) then
      vim.notify("[ERROR] Profile not found: " .. name, vim.log.levels.ERROR)
      return
    end

    vim.ui.select({ "Yes, delete", "Cancel" }, {
      prompt = string.format("Delete profile '%s'?", name),
    }, function(choice)
      if choice ~= "Yes, delete" then
        return
      end

      local appname = "nvim-" .. name:lower()

      fs.delete_profile(name, appname)

      if not fs.unregister(name) then
        return
      end

      for i, p in ipairs(data.profiles) do
        if p.name == name then
          table.remove(data.profiles, i)
          break
        end
      end

      vim.notify(
        string.format(
          "[DeleteProfile] Profile '%s' deleted.\nRemember to remove the alias from your ~/.bashrc manually.",
          name
        ),
        vim.log.levels.WARN
      )
    end)
  end, {
    nargs = 1,
    complete = function()
      return vim.tbl_map(function(p)
        return p.name
      end, data.profiles)
    end,
    desc = "Delete NeoVim profile",
  })
end

return M
