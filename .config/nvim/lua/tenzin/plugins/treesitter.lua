return {
	"https://github.com/nvim-treesitter/nvim-treesitter",
	lazy = false,
	branch = "main",
	build = ":TSUpdate",
	config = function()
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "yaml", "lua", "rust", "javascript", "typescript", "python", "bash", "json", "toml", "markdown" },
			callback = function()
				vim.treesitter.start()
			end,
		})
	end,
}
