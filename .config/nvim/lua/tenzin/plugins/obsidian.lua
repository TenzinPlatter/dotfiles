return {
	"epwalsh/obsidian.nvim",
	dependencies = {
		"hrsh7th/nvim-cmp",
		"nvim-telescope/telescope.nvim",
		"nvim-lua/plenary.nvim",
	},
	version = "*", -- recommended, use latest release instead of latest commit
	lazy = true,
	event = {
		-- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
		-- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
		-- refer to `:h file-pattern` for more examples
		"BufReadPre /home/tenzin/gr/notes/*.md",
		"BufNewFile /home/tenzin/gr/notes/*.md",
	},
	opts = {
		ui = { enable = false },
		workspaces = {
			{
				name = "greenroom",
				path = "/home/tenzin/gr/notes",
			},
		},
	},
}
