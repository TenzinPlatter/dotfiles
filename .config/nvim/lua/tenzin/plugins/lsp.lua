return {
	{
		"neovim/nvim-lspconfig",
		keys = {
			{ "<C-S>", vim.diagnostic.open_float, desc = "Line Diagnostics" },
		},
	},
	{
		"mason-org/mason.nvim",
		opts = {
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		},
	},
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = {
			"neovim/nvim-lspconfig",
			"mason-org/mason.nvim",
		},
		opts = {
			ensure_installed = {},
			handlers = {
				-- Default handler for all servers
				function(server_name)
					vim.lsp.config(server_name).setup({})
				end,
				-- Ruff: disable diagnostics, use only for formatting
				["ruff"] = function()
					vim.lsp.config("ruff").setup({
						on_attach = function(client)
							client.server_capabilities.diagnosticProvider = false
						end,
					})
				end,
			},
		},
	},
}
