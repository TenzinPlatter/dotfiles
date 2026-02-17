-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
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

-- TypeScript/JavaScript build configuration
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
  callback = function()
    vim.opt_local.makeprg = "npm run build"
    vim.opt_local.errorformat = {
      -- TypeScript/JavaScript errors
      "%f(%l\\,%c): %trror TS%n: %m",
      "%f(%l\\,%c): %tarning TS%n: %m",
      -- ESBuild/Vite style
      "%f:%l:%c: %trror: %m",
      "%f:%l:%c: %tarning: %m",
      -- Webpack style
      "%EERROR in %f:%l:%c",
      "%EERROR in %f",
      "%WWARNING in %f:%l:%c",
      "%WWARNING in %f",
      "%Z%m",
      -- Generic catch-all
      "%E%f:%l:%m",
      "%W%f:%l:%m",
      -- Ignore lines that don't match
      "%-G%.%#",
    }
  end,
})

-- Custom build command using LLM
vim.api.nvim_create_user_command("Build", function(opts)
  local args = opts.args

  -- Set makeprg to use llm with build flag and provided args
  if args and args ~= "" then
    vim.opt.makeprg = "~/bin/llm --build " .. args
  else
    vim.opt.makeprg = "~/bin/llm --build"
  end

  -- Set errorformat for AI-parsed output
  vim.opt.errorformat = {
    "%f:%l:%c: %trror: %m",
    "%f:%l:%c: %tarning: %m",
    "%f:%l:%c: %m",
    "%f:%l: %trror: %m",
    "%f:%l: %tarning: %m",
    "%f:%l: %m",
    "%-G%.%#",
  }

  -- Run make
  vim.cmd("make!")
end, {
  nargs = "*",
  desc = "Build using ~/bin/llm --build with optional arguments",
})

-- Create custom LspLog command
vim.api.nvim_create_user_command("LspLog", function()
  vim.cmd("edit " .. vim.lsp.get_log_path())
end, { desc = "Open LSP log file" })

-- Tmux window renaming on Vim enter/leave
local uv = vim.uv
vim.api.nvim_create_autocmd({ "VimEnter", "VimLeave" }, {
  callback = function()
    if vim.env.TMUX_PLUGIN_MANAGER_PATH then
      uv.spawn(vim.env.TMUX_PLUGIN_MANAGER_PATH .. "/tmux-window-name/scripts/rename_session_windows.py", {})
    end
  end,
})
