vim.g.mapleader = " "
vim.opt.termguicolors = true
---@diagnostic disable-next-line: duplicate-set-field
vim.deprecate = function() end

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

local mux = require("smart-splits.mux").get()
if mux == nil then
  return
end

vim.keymap.set("n", "<M-L>", function()
  vim.notify("In session: " .. tostring(mux.is_in_session()))
  vim.notify("Pane at edge in right direction: " .. tostring(mux.current_pane_at_edge("right")))
  mux.next_pane("right")
end)
