local repo_root = vim.fn.fnamemodify(vim.fn.stdpath("config"), ":h:h")
vim.opt.rtp:prepend(repo_root .. "/core")

require("config.lazy")
