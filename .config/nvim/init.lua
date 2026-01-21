vim.g.mapleader = " "
vim.opt.termguicolors = true

-- Tab settings: always use 2 spaces
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true

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

local lua_files = vim.fn.glob(vim.fn.stdpath("config") .. "/lua/tenzin/*.lua", false, true)
for _, file_path in ipairs(lua_files) do
  local file_name = vim.fn.fnamemodify(file_path, ":t:r")
  require("tenzin." .. file_name)
end

-- colorizer has to be setup after other plugins
require("colorizer").setup()

-- set highlight colours
vim.api.nvim_set_hl(0, "Visual", { bg = "#666666" })
-- vim.cmd('hi MatchParen guibg=White')
vim.cmd("hi Search guibg=#FEFFA7")
-- vim.cmd('hi CursorLineNr guibg=White')
vim.cmd("hi ColorColumn guibg=Black")
vim.api.nvim_set_hl(0, '@lsp.mod.mutable', { underline = true })
vim.api.nvim_set_hl(0, "@lsp.mod.usedAsMutableReference.cpp", { underline = true })

vim.cmd("hi SnippetTabstop guibg=None")

-- set nvim tree background transparent
-- vim.cmd("hi NvimTreeNormal guibg=None ctermbg=None")

vim.cmd("set mouse=a")
