return {
	{
		"neovim/nvim-lspconfig",
		cmd = { "LspInfo", "LspStart", "LspStop", "LspRestart", "LspLog" },
		keys = {
			-- NOTE: references, definition, implementation is done in snacks
			 { "<C-S>", vim.diagnostic.open_float, desc = "Line Diagnostics" },
			{
			"K",
			function()
				require("tenzin.lsp_hover_enhanced").hover()
			end,
			desc = "Show hover documentation",
		},
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
					require("lspconfig")[server_name].setup({})
				end,
				-- Ruff: disable diagnostics, use only for formatting
				["ruff"] = function()
					require("lspconfig").ruff.setup({
						on_attach = function(client)
							client.server_capabilities.diagnosticProvider = false
						end,
					})
				end,
			},
		},
	},
}
