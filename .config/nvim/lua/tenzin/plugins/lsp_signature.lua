return {
	"https://github.com/ray-x/lsp_signature.nvim",
	event = "InsertEnter",
	config = function()
		require("lsp_signature").setup({
			bind = true,
			handler_opts = {
				border = "rounded",
			},
		})
		vim.api.nvim_set_hl(0, "LspSignatureActiveParameter", { link = "LspInlayHint" })
	end,
	keys = {
		{
			"<C-S>",
			function()
				require("lsp_signature").toggle_float_win()
			end,
			mode = { "n", "i", "v" },
			desc = "LSP Signature Toggle",
		},
	},
}
