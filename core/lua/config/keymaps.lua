-- clipboard configuration
vim.keymap.set("v", "<C-c>", '"+y', { desc = "Copy selection to clipboard Visual" })
vim.keymap.set({ "n", "v" }, "<C-S-c>", '"+y', { desc = "Copy selection to clipboard Normal Visual" })
vim.keymap.set("n", "<C-S-v>", '"+p', { desc = "Paste from clipboard Normal" })
vim.keymap.set("i", "<C-S-v>", "<C-R>+", { desc = "Paste from clipboard Insert" })
vim.keymap.set("v", "<C-x>", '"+d', { desc = "Cut selection Visual" })

-- editor configuration
vim.keymap.set("n", "<C-z>", "u", { desc = "Undo Normal" })
vim.keymap.set("i", "<C-z>", "<Esc>u", { desc = "Undo Insert" })

-- file navigation
vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Open and close neo-tree" })

-- text navigation
vim.keymap.set("n", "<C-t>", "ggVG", { desc = "Select all Normal" })
vim.keymap.set("i", "<C-t>", "<Esc>ggVG", { desc = "Select all Insert" })
