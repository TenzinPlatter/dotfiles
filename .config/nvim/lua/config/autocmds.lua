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

-- Autosave with delay after leaving insert mode
local autosave_timer = nil
local autosave_delay = 1000
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
  group = vim.api.nvim_create_augroup("autosave", { clear = true }),
  callback = function()
    if autosave_timer and not autosave_timer:is_closing() then
      autosave_timer:stop()
      autosave_timer:close()
    end

    if vim.bo.modified and vim.bo.buftype == "" and vim.bo.modifiable then
      if vim.bo.filetype == "rust" then
        vim.cmd("silent! write")
        return
      end

      autosave_timer = vim.defer_fn(function()
        if vim.bo.modified and vim.bo.buftype == "" and vim.bo.modifiable then
          vim.cmd("silent! write")
        end
      end, autosave_delay)
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
