return {
  "lervag/vimtex",
  lazy = false,
  init = function()
    vim.g.vimtex_view_method = "zathura"
    -- Uninstall latex treesitter parser to not conflict with this
    vim.g.vimtex_syntax_enabled = 1
  end
}
