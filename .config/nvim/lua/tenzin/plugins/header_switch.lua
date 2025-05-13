return {
	"https://github.com/jakemason/ouroboros.nvim.git",
	config = function ()
		vim.keymap.set("n", "<leader>sh", "<CMD>Ouroboros<CR>")
	end
}
