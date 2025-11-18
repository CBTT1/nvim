local set = vim.o
set.number = true
set.encoding = "UTF-8"
set.relativenumber = true
set.clipboard = "unnamed"
set.shiftwidth = 4
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
local opt = { noremap = true, silent = true }
vim.g.mapleader = " "
vim.keymap.set("n", "<S-s>", ":w<CR>", opt)
vim.keymap.set("n", "<S-q>", ":q<CR>", opt)
vim.keymap.set("n", "<S-j>", "5j", opt)
vim.keymap.set("n", "<S-k>", "5k", opt)
vim.keymap.set({ "n", "t" }, "<C-h>", "<CMD>NavigatorLeft<CR>")
vim.keymap.set({ "n", "t" }, "<C-l>", "<CMD>NavigatorRight<CR>")
vim.keymap.set({ "n", "t" }, "<C-k>", "<CMD>NavigatorUp<CR>")
vim.keymap.set({ "n", "t" }, "<C-j>", "<CMD>NavigatorDown<CR>")
vim.keymap.set("n", "<Leader>v", "<C-w>v", opt)
vim.keymap.set("n", "<Leader>s", "<C-w>s", opt)
vim.keymap.set("n", "<Leader>[", "<C-o>", opt)
vim.keymap.set("n", "<Leader>]", "<C-i>", opt)
vim.keymap.set("n", "j", [[v:count ? 'j' : 'gj']], { noremap = true, expr = true })
vim.keymap.set("n", "k", [[v:count ? 'k' : 'gk']], { noremap = true, expr = true })
vim.keymap.set('n', '<Esc>', ':noh<CR><Esc>', { silent = true, noremap = true })

-- 选择折叠方法
vim.opt.foldmethod = "expr" -- 推荐：表达式模式（结合 Treesitter）
vim.opt.foldexpr = "nvim_treesitter#foldexpr()" -- 如果安装 Treesitter

-- C/C++ 缩进修复：禁用 cindent 回退，保持一致缩进
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "c", "cpp" },
	callback = function()
		vim.opt_local.expandtab = true -- 用空格（非 Tab）
		vim.opt_local.shiftwidth = 4 -- 4 空格缩进
		vim.opt_local.softtabstop = 4
		vim.opt_local.autoindent = true -- 保留基本缩进
		vim.opt_local.smartindent = true -- 启用智能（处理 { } 但不回退）
		vim.opt_local.cindent = false -- 关键：禁用 cindent，避免 { 回退
		-- 如果想微调 cinoptions（备选，保留 cindent）
		-- vim.opt_local.cinoptions = { "(0", ":0", "Ws" }  -- { 不额外缩进，switch case 不缩进
	end,
})

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
		"Mofiqul/dracula.nvim",
	},
	{
		event = "VeryLazy",
		"hrsh7th/nvim-cmp",
		dependencies = {
			"neovim/nvim-lspconfig",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/nvim-cmp",
			"L3MON4D3/LuaSnip",
		},
	},
	{
		"RRethy/nvim-base16",
	},
	{
		keys = {
			{ "tt", ":NERDTreeToggle<CR>", desc = "toggle nerdtree" },
			{ "tf", ":NERDTreeFind<CR>", desc = "nerdtree find" },
		},
		cmd = { "NERDTreeToggle", "NERDTree", "NERDTreeFind" },
		"preservim/nerdtree",
		config = function()
			vim.cmd([[
				let NERDTreeShowLineNumber=1
				autocmd FileType nerdtree setlocal relativenumber
			]])
		end,
		dependencies = {
			"Xuyuanp/nerdtree-git-plugin",
			"ryanoasis/vim-devicons",
		},
	},
	{
		"nvim-treesitter/nvim-treesitter",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = { "c", "python", "lua", "vim", "vimdoc" },
				sync_install = false,
				ignore_install = {},

				auto_install = true,
				highlight = {
					enable = true,
				},
				incremental_selection = {
					enable = true,
					keymaps = {
						node_incremental = "v",
						node_decremental = "<BS>",
					},
				},
			})
		end,
	},
	{
		"kevinhwang91/nvim-ufo",
		dependencies = {
			"kevinhwang91/promise-async", -- 必需依赖
		},
		event = "BufReadPost", -- 延迟加载，提高启动速度
		config = function()
			-- 配置见下一步
			-- 全局折叠设置（nvim-ufo 要求 foldlevel 高值）
			vim.o.foldcolumn = "1" -- 左侧折叠列（0=无，1=最小）
			vim.o.foldlevel = 99 -- 初始展开所有（可调低到 10）
			vim.o.foldlevelstart = 99
			vim.o.foldenable = true

			-- 键映射（覆盖默认 zR/zM）
			vim.keymap.set("n", "zR", require("ufo").openAllFolds)
			vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
			vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds) -- 展开除注释外的所有
			vim.keymap.set("n", "zM", require("ufo").closeAllFolds) -- 全折叠

			-- nvim-ufo setup（用 Treesitter + indent 提供者）
			require("ufo").setup({
				provider_selector = function(bufnr, filetype, buftype)
					return { "treesitter", "indent" } -- Treesitter 优先，fallback 到缩进
				end,
				-- 可选：预览功能（鼠标悬停或 K 键查看折叠内容）
				preview = {
					win_config = {
						border = { "", "─", "", "", "", "─", "", "" }, -- 边框样式
						winhighlight = "Normal:Folded",
						winblend = 0,
					},
					mappings = {
						scrollU = "<C-u>",
						scrollE = "<C-e>",
						close = "q",
					},
				},
				-- 关闭 Treesitter 冲突（可选，如果你之前设置了 foldexpr）
				fold_virt_text_handler = function(virt_text)
					-- 自定义折叠文本（默认是 ...）
				end,
			})

			-- 禁用 Treesitter 的旧折叠（避免冲突）
			vim.opt.foldmethod = "manual" -- nvim-ufo 会自动管理
		end,
	},
	{
		event = "VeryLazy",
		"nvimtools/none-ls.nvim",
		config = function()
			local null_ls = require("null-ls")
			local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
			null_ls.setup({
				sources = {
					null_ls.builtins.formatting.stylua,
					null_ls.builtins.formatting.black,
				},
				-- you can reuse a shared lspconfig on_attach callback here
				on_attach = function(client, bufnr)
					if client.supports_method("textDocument/formatting") then
						vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
						vim.api.nvim_create_autocmd("BufWritePre", {
							group = augroup,
							buffer = bufnr,
							callback = function()
								-- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
								-- vim.lsp.buf.format({ bufnr = bufnr })
							end,
						})
					end
				end,
			})
		end,
	},
	{
		"windwp/nvim-autopairs",
		event = "VeryLazy",
		config = function()
			require("nvim-autopairs").setup({})
		end,
	},
	{
		"folke/neodev.nvim",
		opts = {},
	},
	{
		event = "VeryLazy",
		"iamcco/markdown-preview.nvim",
		build = "cd app && yarn install",
		ft = { "markdown" },
		config = function()
			-- 如果需要额外配置，可以在这里添加
		end,
	},
	{
		"numToStr/Navigator.nvim",
		config = function()
			require("Navigator").setup({})
		end,
	},
	{
		"folke/persistence.nvim",
		event = "BufReadPre", -- this will only start session saving when an actual file was opened
		config = function()
			require("persistence").setup()
		end,
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
		},
	},
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{ "<leader>p", ":Telescope find_files<CR>", desc = "find files" },
			{ "<leader>P", ":Telescope live_grep<CR>", desc = "grep files" },
			{ "<leader>rs", ":Telescope resume<CR>", desc = "resume" },
			{ "<leader>Q", ":Telescope oldfiles<CR>", desc = "old files" },
		},
	},
	{
		event = "VeryLazy",
		"tpope/vim-fugitive",
		cmd = "Git",
		config = function()
			-- convert
			vim.cmd.cnoreabbrev([[git Git]])
			vim.cmd.cnoreabbrev([[gp Git push]])
		end,
	},
	{
		event = "VeryLazy",
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup()
		end,
	},
	{
		event = "VeryLazy",
		"rhysd/conflict-marker.vim",
		config = function()
			vim.cmd([[
		let g:conflict_marker_highlight_group = ''
		
		" Include text after begin and end markers
		let g:conflict_marker_begin = '^<<<<<<< .*$'
		let g:conflict_marker_end   = '^>>>>>>> .*$'
		
		highlight ConflictMarkerBegin guibg=#2f7366
		highlight ConflictMarkerOurs guibg=#2e5049
		highlight ConflictMarkerTheirs guibg=#344f69
		highlight ConflictMarkerEnd guibg=#2f628e
		highlight ConflictMarkerCommonAncestorsHunk guibg=#754a81
			]])
		end,
	},
	{
		event = "VeryLazy",
		"neovim/nvim-lspconfig",
		dependencies = { "williamboman/mason-lspconfig.nvim" },
	},
	{
		"williamboman/mason.nvim",
		event = "VeryLazy",
		build = ":MasonUpdate", -- :MasonUpdate updates registry contents
	},
})
-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)
-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		-- Enable completion triggered by <c-x><c-o>
		vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
		-- Buffer local mappings.
		-- See `:help vim.lsp.*` for documentation on any of the below functions
		local opts = { buffer = ev.buf }
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		-- vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
		-- vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
		vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
		vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
		vim.keymap.set("n", "<leader>wl", function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, opts)
		vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, opts)
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
		vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
		vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
		vim.keymap.set("n", "<leader>f", function()
			vim.lsp.buf.format({ async = true })
		end, opts)
	end,
})
require("mason").setup()
-- require("mason-lspconfig").setup({
-- 	ensure_installed = { "lua_ls", "pyright", "clangd" },
-- })

-- Set up lspconfig.
local capabilities = require("cmp_nvim_lsp").default_capabilities()
-- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
-- require('lspconfig')['<YOUR_LSP_SERVER>'].setup {
-- 	capabilities = capabilities
-- }
require("neodev").setup({
	-- add any options here, or leave empty to use the default settings
})

-- lsp config
vim.lsp.config("lua_ls", {
	capabilities = capabilities,
	settings = {
		Lua = {
			runtime = {
				-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
				version = "LuaJIT",
			},
			diagnostics = {
				-- Get the language server to recognize the `vim` global
				globals = { "vim", "hs" },
			},
			workspace = {
				checkThirdParty = false,
				-- Make the server aware of Neovim runtime files
				library = {
					vim.api.nvim_get_runtime_file("", true),
					"/Applications/Hammerspoon.app/Contents/Resources/extensions/hs/",
					vim.fn.expand("~/lualib/share/lua/5.4"),
					vim.fn.expand("~/lualib/lib/luarocks/rocks-5.4"),
					"/opt/homebrew/opt/openresty/lualib",
				},
			},
			completion = {
				callSnippet = "Replace",
			},
			-- Do not send telemetry data containing a randomized but unique identifier
			telemetry = {
				enable = false,
			},
		},
	},
})
vim.lsp.config("pyright", {
	capabilities = capabilities,
	settings = {
		python = {
			pythonPath = "/Users/cbtt1/miniconda3/envs/pytorch/bin/python",
			analysis = {
				extraPaths = "/Users/cbtt1/code/Python/LearnPy/dl_learn/DeepLearningFromScratch",
			},
		},
	},
})
local util = require("lspconfig.util")
vim.lsp.config("clangd", {
	capabilities = capabilities,
	cmd = { "clangd" },
	filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
	root_dir = util.root_pattern(
		".clangd",
		".clang-tidy",
		".clang-format",
		"compile_commands.json",
		"compile_flags.txt",
		"configure.ac",
		".git"
	),
	single_file_support = true,
})

-- 自动启用 LSP（按文件类型，避免全局加载）
local ft_to_server = {
	lua = "lua_ls",
	python = "pyright",
	c = "clangd",
	cpp = "clangd", -- C++ 文件类型
}

vim.api.nvim_create_autocmd("FileType", {
	pattern = vim.tbl_keys(ft_to_server), -- 自动匹配你的文件类型
	callback = function(ev)
		local server = ft_to_server[ev.match]
		if server then
			vim.lsp.enable(server)
		end
	end,
})

-- VSCode 插件禁用Treesitter
if vim.g.vscode then
	-- VSCode 模式：禁用 Treesitter indent
	require("nvim-treesitter.configs").setup({
		indent = { enable = false }, -- 全局禁用在 VSCode 中
	})
end

--nvim cmp
-- Set up nvim-cmp.
local has_words_before = function()
	unpack = unpack or table.unpack
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end
local luasnip = require("luasnip")
local cmp = require("cmp")
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
cmp.setup({
	snippet = {
		-- REQUIRED - you must specify a snippet engine
		expand = function(args)
			require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
			-- require('snippy').expand_snippet(args.body) -- For `snippy` users.
			-- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
		end,
	},
	window = {
		-- completion = cmp.config.window.bordered(),
		-- documentation = cmp.config.window.bordered(),
	},
	mapping = cmp.mapping.preset.insert({
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
				-- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
				-- they way you will only jump inside the snippet region
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			elseif has_words_before() then
				cmp.complete()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
		-- ... Your other mappings ...
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
		["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "vsnip" }, -- For vsnip users.
		-- { name = 'luasnip' }, -- For luasnip users.
		-- { name = 'ultisnips' }, -- For ultisnips users.
		-- { name = 'snippy' }, -- For snippy users.
	}, {
		{ name = "buffer" },
	}),
})
-- Set configuration for specific filetype.
cmp.setup.filetype("gitcommit", {
	sources = cmp.config.sources({
		{ name = "cmp_git" }, -- You can specify the `cmp_git` source if you were installed it.
	}, {
		{ name = "buffer" },
	}),
})
-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ "/", "?" }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = "buffer" },
	},
})
-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = "path" },
	}, {
		{ name = "cmdline" },
	}),
})
vim.cmd([[
		let g:conflict_marker_highlight_group = ''
		
		" Include text after begin and end markers
		let g:conflict_marker_begin = '^<<<<<<< .*$'
		let g:conflict_marker_end   = '^>>>>>>> .*$'
		
		highlight ConflictMarkerBegin guibg=#2f7366
		highlight ConflictMarkerOurs guibg=#2e5049
		highlight ConflictMarkerTheirs guibg=#344f69
		highlight ConflictMarkerEnd guibg=#2f628e
		highlight ConflictMarkerCommonAncestorsHunk guibg=#754a81
]])
--dracula
vim.cmd([[colorscheme dracula]])
-- persistence onset
local args = vim.api.nvim_get_vvar("argv")
if #args > 2 then
else
	require("persistence").load({ last = true })
end
