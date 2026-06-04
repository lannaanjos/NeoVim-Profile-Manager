-- calc tamanho do repo a partir do diretório do perfil ativo
-- stdpath(config) resolve perfil
local repo_root = vim.fn.fnamemodify(vim.fn.stdpath("config"), ":h:h")

-- add core/ ao runtimepath pra q require(config) e plugins do core funcionem
vim.opt.rtp:prepend(repo_root .. "/core")

require("config.lazy")

