return {
	"https://github.com/olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	keys = {
		{
			"<leader>cc",
			function()
				local input = vim.fn.input("CodeCompanion prompt: ")
				if input ~= "" then
					vim.cmd("CodeCompanion #{buffer} " .. input)
				end
			end,
			desc = "CodeCompanion with buffer context",
			mode = { "n", "v" }
		},
	},
	opts = {},
}
