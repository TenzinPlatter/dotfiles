return {
	"mrcjkb/rustaceanvim",
	lazy = false,
	config = function()
		vim.g.rustaceanvim = {
			tools = {},
			server = {
				on_attach = function(_client, _bufnr)
					vim.keymap.set("n", "<leader>th", function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())

						if vim.lsp.inlay_hint.is_enabled() then
							print("Enabled inlay hints")
						else
							print("Disabled inlay hints")
						end
					end)
				end,
				default_settings = {
					-- rust-analyzer language server configuration
					["rust-analyzer"] = {
						rust = {
							analyzerTargetDir = true,
						},
					},
				},
			},
		}
	end,
}
