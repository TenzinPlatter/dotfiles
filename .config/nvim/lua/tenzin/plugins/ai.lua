return {
	"https://github.com/zbirenbaum/copilot-cmp",
	dependencies = {
		"https://github.com/zbirenbaum/copilot.lua",
		"olimorris/codecompanion.nvim",
	},
	config = function()
		require("copilot").setup({})
		require("copilot_cmp").setup({})
		require("codecompanion").setup({})

		vim.api.nvim_create_user_command(
			'CC',
			'CodeCompanion',
			{ nargs = '*' }
		)

		vim.api.nvim_create_user_command(
			'CCC',
			'CodeCompanionChat',
			{ nargs = '*' }
		)
	end
}

-- return {}
