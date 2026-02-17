-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Custom highlights applied after colorscheme loads
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    -- Transparent backgrounds
    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    vim.api.nvim_set_hl(0, "CursorLine", { bg = "Black" })

    -- Window separator
    vim.api.nvim_set_hl(0, "WinSeparator", { link = "FloatBorder" })

    -- Custom visual selection
    vim.api.nvim_set_hl(0, "Visual", { bg = "#666666" })

    -- Custom search highlight
    vim.api.nvim_set_hl(0, "Search", { bg = "#FEFFA7", fg = "#000000" })

    -- ColorColumn
    vim.api.nvim_set_hl(0, "ColorColumn", { bg = "Black" })
  end,
})

-- Apply highlights immediately
vim.schedule(function()
  vim.cmd("doautocmd ColorScheme")
end)
