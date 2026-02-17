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

-- Autosave after 1 second of no file changes
local autosave_timer = nil
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
  group = vim.api.nvim_create_augroup("autosave", { clear = true }),
  callback = function()
    -- Cancel existing timer if any
    if autosave_timer and not autosave_timer:is_closing() then
      autosave_timer:stop()
      autosave_timer:close()
    end

    -- Create new timer that triggers after 1 second
    autosave_timer = vim.defer_fn(function()
      if vim.bo.modified and vim.bo.buftype == "" and vim.bo.modifiable then
        vim.cmd("silent! write")
      end
    end, 1000) -- 1 second delay
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
