-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Autocmds are automatically loaded on the VeryLazy event
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- DISABLE LazyVim's auto-formatting
vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("disable_autoformat", { clear = true }),
  callback = function()
    vim.b.autoformat = false
    vim.g.autoformat = false
  end,
})

-- Autosave after 1 second of inactivity
vim.opt.updatetime = 1000 -- 1 second
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
  group = vim.api.nvim_create_augroup("autosave", { clear = true }),
  callback = function()
    if vim.bo.modified and vim.bo.buftype == "" and vim.bo.modifiable then
      vim.cmd("silent! write")
    end
  end,
})

-- Highlight yanked area
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight_yank", {}),
  desc = "Highlight selection on yank",
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({
      higroup = "Visual",
      timeout = 300,
      on_visual = false,
    })
  end,
})

-- C/C++ switch between source and header
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "h", "cpp", "hpp" },
  callback = function()
    vim.keymap.set("n", "<leader>sh", ":LspClangdSwitchSourceHeader<CR>", { buffer = true, desc = "Switch source/header" })
  end,
})
