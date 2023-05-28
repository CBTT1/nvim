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
vim.g.mapleader = " "

vim.keymap.set("n", "<S-s>", ":w<CR>", opt)
vim.keymap.set("n", "<S-q>", ":q<CR>", opt)
vim.keymap.set("n", "<S-j>", "5j", opt)
vim.keymap.set("n", "<S-k>", "5k", opt)

vim.keymap.set("n", "<C-l>", "<C-w>l", opt)
vim.keymap.set("n", "<C-h>", "<C-w>h", opt)
vim.keymap.set("n", "<C-k>", "<C-w>k", opt)
vim.keymap.set("n", "<C-j>", "<C-w>j", opt)
vim.keymap.set("n", "<Leader>v", "<C-w>v", opt)
vim.keymap.set("n", "<Leader>s", "<C-w>s", opt)
vim.keymap.set("n", "<Leader>[", "<C-o>", opt)
vim.keymap.set("n", "<Leader>]", "<C-i>", opt)

vim.keymap.set("n", "j", [[v:count ? 'j' : 'gj']], { noremap = true, expr = true })
vim.keymap.set("n", "k", [[v:count ? 'k' : 'gk']], { noremap = true, expr = true })

--lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
	{
		"RRethy/nvim-base16", 
		lazy = true,
	}, 
	{
	  	event = "VeryLazy",
		"neovim/nvim-lspconfig", 
	}, 
	{
	  	"folke/persistence.nvim",
	  	event = "BufReadPre", -- this will only start session saving when an actual file was opened
	  	opts = {
	  	  -- add any custom options here
	  	},
	},
	{
	  	event = "VeryLazy",
	  	"folke/which-key.nvim",
	  	init = function()
	  	  vim.o.timeout = true
	  	  vim.o.timeoutlen = 300
	  	end,
	  	opts = {
	  	  -- your configuration comes here
	  	  -- or leave it empty to use the default settings
	  	  -- refer to the configuration section below
	  	}
	},
	{
   		keys = {
    		  { "<leader>p", ":Telescope find_files<CR>", desc = "find files" },
    		  { "<leader>P", ":Telescope live_grep<CR>", desc = "grep files" },
    		  { "<leader>rs", ":Telescope resume<CR>", desc = "resume" },
    		  { "<leader>q", ":Telescope oldfiles<CR>", desc = "old files" },
    		},
		cmd = "Telescope",
    		'nvim-telescope/telescope.nvim', 
		tag = '0.1.1',
		branch = '0.1.1',
      		dependencies = { 'nvim-lua/plenary.nvim' }
    	},
	{
		"williamboman/mason.nvim",
		event = "VeryLazy",
		build = ":MasonUpdate", -- :MasonUpdate updates registry contents
		config = function()
			require("mason").setup()
		end
	}
})

