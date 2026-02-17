-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Disable deprecated messages on startup
vim.deprecate = function() end

-- Diagnostic configuration
vim.diagnostic.config({ virtual_text = true })

-- For obsidian.nvim - allow concealing
vim.opt.conceallevel = 1

-- Editor options
vim.opt.cursorline = true
vim.opt.smartcase = true

-- Indentation (2 spaces)
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- Visual guides
vim.opt.colorcolumn = "100"

-- Window behavior
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.linebreak = true

-- Borders between splits
vim.opt.fillchars = {
  vert = "│",
  horiz = "─",
  horizup = "┴",
  horizdown = "┬",
  vertleft = "┤",
  vertright = "├",
  verthoriz = "┼"
}

-- Folding with treesitter
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldcolumn = "0"
vim.opt.foldtext = ""
vim.opt.foldlevel = 99

-- Line numbers
vim.opt.rnu = true
vim.opt.nu = true

-- Search
vim.opt.ignorecase = true
vim.opt.wrap = true
