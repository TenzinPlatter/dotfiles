return {
  "lervag/vimtex",
  lazy = false,
  init = function()
    vim.g.vimtex_view_method = "zathura"
    -- Uninstall latex treesitter parser to not conflict with this
    vim.g.vimtex_syntax_enabled = 1
    -- Don't auto-open qf list when there are compile errors/warnings
    vim.g.vimtex_quickfix_mode = 0
  end
}
