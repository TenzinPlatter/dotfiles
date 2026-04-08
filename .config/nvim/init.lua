vim.g.mapleader = " "
vim.opt.termguicolors = true

require("vim._core.ui2").enable()

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
