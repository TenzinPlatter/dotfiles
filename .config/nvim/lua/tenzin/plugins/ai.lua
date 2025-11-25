return {
	{
		"https://github.com/zbirenbaum/copilot.lua",
		config = function()
			require("copilot").setup({
				suggestion = {
					enabled = true,
				},
				panel = {
					enabled = false,
				},
				-- filetypes = {
				-- 	["*"] = true,
				-- 	help = false,
				-- 	text = false,
				-- },
			})
		end,
		keys = {
			{"<leader>aie", function() vim.cmd("Copilot enable") end, desc = "Enable copilot"},
			{"<leader>aid", function() vim.cmd("Copilot disable") end, desc = "Disable copilot"},
		}
	},
	{
		"https://github.com/zbirenbaum/copilot-cmp",
		config = function()
			require("copilot_cmp").setup({
				formatting = {
					format = require("copilot_cmp.format").format,
				},
				experimental = {
					ghost_text = true,
				},
			})
		end,
	},
	{
		"olimorris/codecompanion.nvim",
		opts = {
			chat = {
				enabled = true,
				keymaps = {
					toggle = "<leader>co",
					send = "<C-Enter>",
				},
			},
			commands = {
				enabled = true,
			},
		},
	},
	keys = {
		{
			"<leader>co",
			function()
				vim.cmd("CodeCompanion")
			end,
			desc = "Code Companion",
		},
		{
			"<leader>coc",
			function()
				vim.cmd("CodeCompanionChat")
			end,
			desc = "Code Companion Chat",
		},
	},
}
