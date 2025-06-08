return {
	{
		"https://github.com/zbirenbaum/copilot.lua",
		config = function()
			require("copilot").setup({
			suggestion = {
				enabled = false,
			},
			panel = {
				enabled = false,
			},
			filetypes = {
				["*"] = true,
				markdown = false,
				help = false,
				text = false,
			},
			})

		vim.cmd("silent! Copilot disable")
	end
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
		end
	},
	{
		"olimorris/codecompanion.nvim",
		config = function()
			require("codecompanion").setup({
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
			})
			vim.keymap.set("n", "<leader>co", function() vim.cmd("CodeCompanion") end)
			vim.keymap.set("n", "<leader>coc", function() vim.cmd("CodeCompanionChat") end)
		end
	}
}
