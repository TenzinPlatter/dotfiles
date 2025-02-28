vim.opt.termguicolors = true
vim.g.mapleader = ' '

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
-- [[
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
	pattern = { "*" },
	command = "wall",
	nested = true,
})
-- ]]

-- Highlight Yanked area
vim.api.nvim_create_autocmd('TextYankPost', { group = vim.api.nvim_create_augroup('highlight_yank', {}), desc = 'Highlight selection on yank', pattern = '*',
  callback = function()
    vim.highlight.on_yank {
			higroup = 'Visual',
			timeout = 300,
			on_visual = false
		}
  end,
})

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
vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.mouse = ""

vim.g.rustaceanvim = {
  -- Plugin configuration
  tools = {
  },
  -- LSP configuration
  server = {
    on_attach = function(client, bufnr)
		--[[
				if client.server_capabilities.inlayHintProvider then
					vim.lsp.inlay_hint.enable(true, { bufnr = 0 })
				end
				]]
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
      ['rust-analyzer'] = {
      },
    },
  },
  -- DAP configuration
  dap = {
  },
}
