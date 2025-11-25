return {
	"pwntester/octo.nvim",
	event = "VeryLazy",
	cond = function()
		return vim.fn.executable("gh") == 1
	end,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		require("octo").setup({
			mappings = {
				issue = {
					close_issue = { "<C-c>", "Close issue" },
					reopen_issue = { "<C-r>", "Reopen issue" },
					create_issue_link = { "<C-l>", "Create issue link" },
				},
				pull_request = {
					merge_pr = { "<C-m>", "Merge pull request" },
					close_pr = { "<C-c>", "Close pull request" },
				},
			},
		})
	end,
}
