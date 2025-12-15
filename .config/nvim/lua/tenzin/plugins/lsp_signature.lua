return {
	"https://github.com/ray-x/lsp_signature.nvim",
	event = "InsertEnter",
	config = function()
		require("lsp_signature").setup({
			bind = true,
			handler_opts = {
				border = "rounded",
			},
			move_signature_window_key = { "<M-j>", "<M-k>", "<M-h>", "<M-l>" },
		})
		vim.api.nvim_set_hl(0, "LspSignatureActiveParameter", { fg = "#e5c07b", bold = true })
	end,
	keys = {
		{
			"<C-S>",
			function()
				require("lsp_signature").toggle_float_win()
			end,
			mode = { "i", "v" },
			desc = "LSP Signature Toggle",
		},
	},
}
