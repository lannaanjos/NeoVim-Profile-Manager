-- /\/\/\/\ filesystem operations for the profile manager

local M = {}

function M.setup(switcher_path, repo_root)
  function M.register(name, appname)
    local f = io.open(switcher_path, "r")
    if not f then
      vim.notify("[ERROR] Couldn't read init.lua", vim.log.levels.ERROR)
      return false
    end
    local content = f:read("*a")
    f:close()

    local entry = string.format('  { name = "%s", appname = "%s" },\n  -- [PROFILES_END]', name, appname)
    local new_content = content:gsub("  %-%- %[PROFILES_END%]", entry)

    if new_content == content then
      vim.notify("[ERROR] 'PROFILES_END' marker could not be found!", vim.log.levels.ERROR)
      return false
    end

    f = io.open(switcher_path, "w")
    if not f then
      vim.notify("[ERROR] Couldn't write on init.lua", vim.log.levels.ERROR)
      return false
    end
    f:write(new_content)
    f:close()
    return true
  end

  function M.unregister(name)
    local f = io.open(switcher_path, "r")
    if not f then
      vim.notify("[ERROR] Couldn't read init.lua", vim.log.levels.ERROR)
      return false
    end
    local content = f:read("*a")
    f:close()

    local pattern = string.format('  { name = "%s", appname = "[^"]*" },\n', name)
    local new_content = content:gsub(pattern, "")

    if new_content == content then
      vim.notify("[ERROR] Entry not found on init.lua", vim.log.levels.ERROR)
      return false
    end

    f = io.open(switcher_path, "w")
    if not f then
      vim.notify("[ERROR] Couldn't write on init.lua", vim.log.levels.ERROR)
      return false
    end
    f:write(new_content)
    f:close()
    return true
  end

  function M.create_profile(name, appname)
    local profile_dir = repo_root .. "/profiles/" .. name
    local plugins_dir = profile_dir .. "/lua/plugins"

    vim.fn.mkdir(plugins_dir, "p")

    local init_content = [[-- Calculate folder path based on active profile directory
local profile_dir = vim.fn.resolve(vim.fn.stdpath("config"))
local repo_root = vim.fn.fnamemodify(profile_dir, ":h:h")
local core_lua = repo_root .. "/core/lua"

-- immediate effect for require()
package.path = core_lua .. "/?.lua;" .. core_lua .. "/?/init.lua;" .. package.path

-- add core/ to runtimepath for require("config.*") and plugins from core
vim.opt.rtp:prepend(repo_root .. "/core")

require("config.lazy")
]]

    local f = io.open(profile_dir .. "/init.lua", "w")
    if not f then
      vim.notify("[ERROR] Couldn't create init.lua", vim.log.levels.ERROR)
      return false
    end
    f:write(init_content)
    f:close()

    local base_content = string.format(
      [[-- Add the following alias to your ~/.bashrc:
--
-- %s() { echo "%s" > "$NVIM_PROFILE_FILE"; NVIM_APPNAME="%s" command nvim "$@"; }

return {}
]],
      name,
      appname,
      appname
    )

    f = io.open(plugins_dir .. "/base.lua", "w")
    if not f then
      vim.notify("[ERROR] Couldn't create base.lua", vim.log.levels.ERROR)
      return false
    end
    f:write(base_content)
    f:close()

    local symlink_dest = vim.fn.expand("~/.config/") .. appname
    vim.fn.system({ "ln", "-s", profile_dir, symlink_dest })

    return true, profile_dir
  end

  function M.delete_profile(name, appname)
    local profile_dir = repo_root .. "/profiles/" .. name
    local symlink_dest = vim.fn.expand("~/.config/") .. appname
    vim.fn.system({ "rm", "-rf", profile_dir })
    vim.fn.system({ "rm", "-f", symlink_dest })
  end
end

return M
