-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Folding
vim.keymap.set("n", "zi", "za", { desc = "Toggle fold under cursor" })

-- Save all buffers
vim.keymap.set("n", "<leader>w", function()
  vim.cmd("wall")
end, { desc = "Save all buffers" })

-- Smart quit with session save (ZZ)
-- vim.keymap.set("n", "ZZ", function()
--   -- Save session
--   require("persistence").save()
--
--   -- Save and close all non-terminal buffers
--   for _, buf in ipairs(vim.api.nvim_list_bufs()) do
--     if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype ~= "terminal" then
--       if vim.bo[buf].modified then
--         vim.api.nvim_buf_call(buf, function()
--           vim.cmd("write")
--         end)
--       end
--       vim.api.nvim_buf_delete(buf, { force = false })
--     end
--   end
--   vim.cmd("quit")
-- end, { desc = "Save session, close all buffers and quit" })

-- Character swap
vim.keymap.set("n", "<C-l>", "xp", { desc = "Swap character with next" })
vim.keymap.set("n", "<C-h>", "xhP", { desc = "Swap character with previous" })

-- Clipboard operations
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "Copy to clipboard" })
vim.keymap.set("n", "<leader>yy", '"+yy', { desc = "Copy line to clipboard" })
vim.keymap.set("v", "<leader>p", '"+p', { desc = "Paste from clipboard" })
vim.keymap.set("n", "<leader>p", '"+p', { desc = "Paste from clipboard" })
vim.keymap.set("n", "<leader>%", "ggVG", { desc = "Select entire buffer" })

-- Quickfix navigation
vim.keymap.set("n", "<leader>j", function()
  vim.cmd("cnext")
end, { desc = "Next quickfix item" })
vim.keymap.set("n", "<leader>k", function()
  vim.cmd("cprev")
end, { desc = "Previous quickfix item" })
vim.keymap.set("n", "<leader>qf", function()
  vim.cmd("copen")
end, { desc = "Open quickfix list" })

-- Display line navigation
vim.keymap.set("n", "j", "gj", { desc = "Move down by display line" })
vim.keymap.set("n", "k", "gk", { desc = "Move up by display line" })

-- Clear search highlights
vim.keymap.set("n", "<C-c>", function()
  vim.cmd("nohlsearch")
end, { desc = "Clear search highlights" })

-- Window resizing
vim.keymap.set("n", "=", [[<cmd>vertical resize +5<cr>]], { desc = "Increase window width" })
vim.keymap.set("n", "-", [[<cmd>vertical resize -5<cr>]], { desc = "Decrease window width" })
vim.keymap.set("n", "+", [[<cmd>horizontal resize +2<cr>]], { desc = "Increase window height" })
vim.keymap.set("n", "_", [[<cmd>horizontal resize -2<cr>]], { desc = "Decrease window height" })

-- Move lines up/down
vim.keymap.set("v", "<C-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<C-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

vim.keymap.set("n", "<C-j>", function()
  vim.cmd("move .+1")
  vim.cmd("normal! ==")
end, { desc = "Move line down" })

vim.keymap.set("n", "<C-k>", function()
  vim.cmd("move .-2")
  vim.cmd("normal! ==")
end, { desc = "Move line up" })

-- Indent and reselect
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Split other windows with current buffer
vim.keymap.set('n', '<leader>wsh', function()
  require('config.helpers').split_window_with_current_buffer('h', false)
end, { desc = 'Split left window with current buffer' })

vim.keymap.set('n', '<leader>wsj', function()
  require('config.helpers').split_window_with_current_buffer('j', false)
end, { desc = 'Split bottom window with current buffer' })

vim.keymap.set('n', '<leader>wsk', function()
  require('config.helpers').split_window_with_current_buffer('k', false)
end, { desc = 'Split top window with current buffer' })

vim.keymap.set('n', '<leader>wsl', function()
  require('config.helpers').split_window_with_current_buffer('l', false)
end, { desc = 'Split right window with current buffer' })

vim.keymap.set('n', '<leader>wvh', function()
  require('config.helpers').split_window_with_current_buffer('h', true)
end, { desc = 'VSplit left window with current buffer' })

vim.keymap.set('n', '<leader>wvj', function()
  require('config.helpers').split_window_with_current_buffer('j', true)
end, { desc = 'VSplit bottom window with current buffer' })

vim.keymap.set('n', '<leader>wvk', function()
  require('config.helpers').split_window_with_current_buffer('k', true)
end, { desc = 'VSplit top window with current buffer' })

vim.keymap.set('n', '<leader>wvl', function()
  require('config.helpers').split_window_with_current_buffer('l', true)
end, { desc = 'VSplit right window with current buffer' })

-- LSP keybindings (override LazyVim + Neovim 0.10+ defaults on attach)
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local buf = args.buf
    -- Remove LazyVim defaults
    for _, key in ipairs({ "gr", "gI", "<leader>cr", "<leader>ca", "<leader>cA" }) do
      pcall(vim.keymap.del, "n", key, { buffer = buf })
    end
    -- Neovim 0.10+ gr-prefix bindings (overwrite built-ins with explicit buffer maps)
    vim.keymap.set("n", "grr", vim.lsp.buf.references, { buffer = buf, desc = "References" })
    vim.keymap.set("n", "gri", vim.lsp.buf.implementation, { buffer = buf, desc = "Go to Implementation" })
    vim.keymap.set("n", "grn", vim.lsp.buf.rename, { buffer = buf, desc = "Rename" })
    vim.keymap.set({ "n", "v" }, "gra", vim.lsp.buf.code_action, { buffer = buf, desc = "Code Action" })
  end,
})

vim.keymap.set("n", "<leader>th", function()
  local helpers = require("config.helpers")
  local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
  vim.lsp.inlay_hint.enable(not enabled, { bufnr = 0 })
  helpers.save_inlay_hint_preference(vim.bo.filetype, not enabled)
  vim.notify("Inlay hints " .. (enabled and "disabled" or "enabled") .. " for " .. vim.bo.filetype)
end, { desc = "Toggle inlay hints with persistence" })

vim.keymap.set("n", "<C-S>", function()
  require("config.helpers").show_hover_in_function_params()
end, { desc = "Show hover in function params" })

-- Smart insertions
vim.keymap.set("i", "<C-s>", function()
  require("config.helpers").insert_self()
end, { desc = "Insert self/this reference" })

vim.keymap.set("i", "t", function()
  require("config.helpers").insert_async_before_function()
end, { desc = "Insert 't' and add async if typing 'await'" })

vim.keymap.set("n", "ZZ", function()
  vim.cmd("silent! wall")
  vim.cmd("qa!")
end)
