-- Calculate folder path based on active profile directory
local profile_dir = vim.fn.resolve(vim.fn.stdpath("config"))
local repo_root = vim.fn.fnamemodify(profile_dir, ":h:h")
local core_lua = repo_root .. "/core/lua"

-- immediate effect for require()
package.path = core_lua .. "/?.lua;" .. core_lua .. "/?/init.lua;" .. package.path

-- add core/ to runtimepath for require("config.*") and plugins from core
vim.opt.rtp:prepend(repo_root .. "/core")

require("config.lazy")
