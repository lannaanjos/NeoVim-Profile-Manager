-- para de inserir comentário automático em cada linha
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions = vim.opt_local.formatoptions - { "r", "o" }
  end,
})
