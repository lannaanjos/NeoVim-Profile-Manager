-- calcula o caminho do repo a partir do diretorio do perfil ativo
local profile_dir = vim.fn.resolve(vim.fn.stdpath("config"))
local repo_root = vim.fn.fnamemodify(profile_dir, ":h:h")
local core_lua = repo_root .. "/core/lua"

-- efeito imediato para require()
package.path = core_lua .. "/?.lua;" .. core_lua .. "/?/init.lua;" .. package.path

-- add core/ ao runtimepath para require("config.*") e plugins do core
vim.opt.rtp:prepend(repo_root .. "/core")

require("config.lazy")
