vim.api.nvim_create_autocmd("BufWritePost", {
  callback = function()
    require("fidget").notify(vim.fn.expand("%:t") .. " written", vim.log.levels.INFO)
  end,
})

-- Force redraw on InsertLeave to clear floating window artifacts
vim.api.nvim_create_autocmd("InsertLeave", {
  group = vim.api.nvim_create_augroup("redraw_on_insert_leave", {}),
  callback = function()
    vim.schedule(function()
      vim.cmd("redraw")
    end)
  end,
})

-- Highlight Yanked area
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

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "h", "cpp", "hpp" },
  callback = function()
    vim.keymap.set("n", "<leader>sh", ":LspClangdSwitchSourceHeader<CR>", { buffer = true })
  end,
})

-- Highlight matching parens using theme's Search group
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("match_paren_hl", {}),
  callback = function()
    vim.api.nvim_set_hl(0, "MatchParen", { link = "Search" })
  end,
})

-- Start treesitter for every buffer
vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
  callback = function()
    pcall(vim.treesitter.start)
  end,
})

-- Tmux window renaming on Vim enter/leave
local uv = vim.uv
vim.api.nvim_create_autocmd({ "VimEnter", "VimLeave" }, {
  callback = function()
    if vim.env.TMUX_PLUGIN_MANAGER_PATH then
      uv.spawn(
        vim.env.TMUX_PLUGIN_MANAGER_PATH .. "/tmux-window-name/scripts/rename_session_windows.py",
        {},
        function() end
      )
    end
  end,
})
