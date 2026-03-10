-- disable deprecated messages on startup
vim.deprecate = function() end
-- Diagnostics: inline virtual text + circle signs in the gutter
vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.HINT] = " ",
      [vim.diagnostic.severity.INFO] = " ",
    },
  },
})

-- transparent background
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "CursorLine", { bg = "Black" })
-- vim.api.nvim_set_hl(0, 'Cursor', { bg = '#666666', fg = '#ffffff' })

-- for obsidian.nvim
vim.opt.conceallevel = 1

vim.opt.cursorline = true
-- vim.opt.cursorlineopt = 'number'
vim.opt.smartcase = true

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.colorcolumn = "100"
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.linebreak = true

-- borders between splits
vim.opt.fillchars = {
  vert = "│",
  horiz = "─",
  horizup = "┴",
  horizdown = "┬",
  vertleft = "┤",
  vertright = "├",
  verthoriz = "┼",
}
vim.api.nvim_set_hl(0, "WinSeparator", { link = "FloatBorder" })

-- folds
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldcolumn = "0"
vim.opt.foldtext = ""

vim.opt.foldlevel = 99
-- vim.opt.foldlevelstart = 1

vim.opt.rnu = true
vim.opt.nu = true

vim.opt.ignorecase = true
vim.opt.wrap = true

-- disables netrw
-- vim.g.loaded_netrw = 1
-- vim.g.loaded_netrwPlugin = 1
