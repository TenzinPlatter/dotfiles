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
			"<leader>cdd",
			function()
				vim.cmd("CodeDiff")
			end,
			desc = "Open prompt for VSCode-diff view",
		},
	},
}
