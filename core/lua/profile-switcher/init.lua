-- /\/\/\/\ profile switcher entry point

local dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h")

local data = dofile(dir .. "/data.lua")
local fs = dofile(dir .. "/fs.lua")
local switcher = dofile(dir .. "/switcher.lua")
local manager = dofile(dir .. "/manager.lua")

data.switcher_path = dir .. "/data.lua"
data.repo_root = vim.fn.fnamemodify(dir, ":h:h:h")

fs.setup(data.switcher_path, data.repo_root)
switcher.setup(data)
manager.setup(data, fs, switcher)
