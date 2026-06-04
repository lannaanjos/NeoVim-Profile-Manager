-- configurações de clipboard
vim.keymap.set("v", "<C-c>", '"+y', { desc = "Copia selecao pro clipboard" })
vim.keymap.set({ "n", "v" }, "<C-S-c>", '"+y', { desc = "Copia pro clipboard" })
vim.keymap.set("n", "<C-S-v>", '"+p', { desc = "Cola do clipboard" })
vim.keymap.set("i", "<C-S-v>", "<C-R>+", { desc = "Cola do clipboard (modo insert)" })

-- configurações do editor
vim.keymap.set("n", "<C-z>", "u", { desc = "desfaz" })
vim.keymap.set("i", "<C-z>", "<Esc>u", { desc = "desfaz" })

-- navegação
vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "neo-tree" }) -- abre e fecha neotree

