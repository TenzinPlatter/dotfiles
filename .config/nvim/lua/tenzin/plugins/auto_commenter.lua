return {
	"https://github.com/tpope/vim-commentary.git",
	config = function ()
		vim.keymap.set("x", "<leader>c","<Plug>Commentary")
		vim.keymap.set("n", "<leader>cc","V<Plug>Commentary")
	end
}
