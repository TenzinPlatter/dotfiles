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
	end
}

-- return {}
