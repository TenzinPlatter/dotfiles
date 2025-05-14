return {
  "folke/which-key.nvim",
	dependencies = { 'nvim-tree/nvim-web-devicons' },
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 250
  end,
  opts = {},
}
