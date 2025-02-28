return {
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {},
		ft = "python",
		config = function()
				require("ibl").setup({
					scope = { enabled = false }
				})
		end
}
