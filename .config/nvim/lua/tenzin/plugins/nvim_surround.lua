return {
	'https://github.com/kylechui/nvim-surround',
	version = "*",
	event = "VeryLazy",
	config = function ()
		require("nvim-surround").setup({
			aliases = {
				["q"] = {'"'},
				["Q"] = {"'"}
			}
		})
	end
}
