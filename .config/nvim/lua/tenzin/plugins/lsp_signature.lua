return {
	"ray-x/lsp_signature.nvim",
	event = "InsertEnter",
	opts = {
		handler_opts = {
			border = "rounded",
		},
	},
	keys = {
		{
			"<C-s>",
			function()
				require("lsp_signature").toggle_float_win()
			end,
			mode = "i",
			desc = "Toggle signature",
		},
	},
}
