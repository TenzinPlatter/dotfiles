return {
	"m4xshen/hardtime.nvim",
	lazy = false,
	dependencies = { "MunifTanjim/nui.nvim" },
	config = function()
		require("hardtime").setup({})
		vim.keymap.set("n", "<leader>hh", function()
			vim.cmd("Hardtime toggle")
		end, { desc = "Toggle Hardtime" })
	end
}
