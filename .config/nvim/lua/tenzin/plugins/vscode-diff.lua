return {
	"esmuellert/vscode-diff.nvim",
	branch = "next",
	dependencies = { "MunifTanjim/nui.nvim" },
	keys = {
		{
			"<leader>cd",
			":CodeDiff",
			desc = "Open prompt for VSCode-diff view",
		},
		{
			"<leader>cdm",
			function()
				vim.cmd("CodeDiff main")
			end,
			desc = "Open prompt for VSCode-diff view",
		},
		{
			"<leader>cdf",
			":CodeDiff file",
			desc = "Open prompt for VSCode-diff view",
		},
		{
			"<leader>cdd",
			function()
				vim.cmd("CodeDiff")
			end,
			desc = "Open prompt for VSCode-diff view",
		},
	},
}
