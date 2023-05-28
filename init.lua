local set = vim.o
set.number = true
set.relativenumber = true
set.clipboard = "unnamed"

-- copy后高亮
vim.api.nvim_create_autocmd({ "textyankpost" }, {
	pattern = { "*" },
	callback = function()
		vim.highlight.on_yank({
			timeout = 300,
		})
	end,
})

-- key bindings
local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<C-l>", "<C-w>l", opt)
vim.keymap.set("n", "<C-h>", "<C-w>h", opt)
vim.keymap.set("n", "<C-k>", "<C-w>k", opt)
vim.keymap.set("n", "<C-j>", "<C-w>j", opt)
