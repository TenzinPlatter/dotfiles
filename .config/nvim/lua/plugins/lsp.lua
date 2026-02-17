return {
  {
    "neovim/nvim-lspconfig",
    opts = { autoformat = false },
    keys = {
			{
			"<C-S>",
			function()
				vim.diagnostic.open_float({ border = "rounded" })
			end,
			desc = "Line Diagnostics",
		},
    }
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {},
    },
  },
}
