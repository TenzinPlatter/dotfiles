vim.g.mapleader = ' '
vim.opt.termguicolors = true

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
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

require("lazy").setup("tenzin.plugins", {})
require("tenzin.remaps")

-- colorizer has to be setup after
require('colorizer').setup()

-- disable deprecated messages on startup
vim.deprecate = function() end

-- Autosave on exit of insert if text has been changed
-- remove space below to comment out autosave while editing config
--[[
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
	pattern = "*",
	nested = true,
	callback = function()
		if vim.bo.buftype ~= "" then
			return
		end

		if vim.bo.modifiable then
			vim.cmd("w")
			-- vim.lsp.buf.format({ bufnr = 0, async = false })
		end
	end,
})
-- ]]

-- Highlight Yanked area
vim.api.nvim_create_autocmd('TextYankPost',
	{
		group = vim.api.nvim_create_augroup('highlight_yank', {}),
		desc = 'Highlight selection on yank',
		pattern = '*',
		callback = function()
			vim.highlight.on_yank {
				higroup = 'Visual',
				timeout = 300,
				on_visual = false
			}
		end,
	})

-- inline diagnositcs
-- vim.diagnostic.config({ virtual_lines = true })
vim.diagnostic.config({ virtual_text = true })

-- transparent background
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

-- set highlight colours
vim.cmd('hi Visual guibg=Black gui=none')
-- vim.cmd('hi MatchParen guibg=#82aaff')
vim.cmd('hi Search guibg=#FEFFA7')
-- vim.cmd('hi CursorLineNr guibg=White')
vim.cmd('hi ColorColumn guibg=Black')

-- disables netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set nvim tree background transparent
vim.cmd("hi NvimTreeNormal guibg=None ctermbg=None")

-- for obsidian.nvim
vim.opt.conceallevel = 1

vim.opt.cursorline = true
vim.opt.cursorlineopt = 'number'

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.colorcolumn = "80"
vim.opt.mouse = ""
vim.opt.splitright = true
vim.opt.splitbelow = true

-- folds
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldcolumn = "0"
vim.opt.foldtext = ""

vim.opt.foldlevel = 99
-- vim.opt.foldlevelstart = 1
vim.opt.foldnestmax = 4

vim.opt.rnu = true
vim.opt.nu = true

vim.g.rustaceanvim = {
	tools = {
	},
	server = {
		on_attach = function(_client, _bufnr)
			vim.keymap.set('n', '<leader>th', function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())

				if vim.lsp.inlay_hint.is_enabled() then
					print("Enabled inlay hints")
				else
					print("Disabled inlay hints")
				end
			end)
		end,
		default_settings = {
			-- rust-analyzer language server configuration
			-- needs to be empty for rustaceanvim plugin
			['rust-analyzer'] = {
			},
		},
	},
}
