return {
	'nvim-telescope/telescope.nvim',
	branch = '0.1.x',
	dependencies = {
		'nvim-lua/plenary.nvim',
		'https://github.com/BurntSushi/ripgrep',
		'https://github.com/nvim-telescope/telescope-fzf-native.nvim',
		'https://github.com/sharkdp/fd',
	},

	config = function()
		local builtin = require('telescope.builtin')
		vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
		vim.keymap.set('n', '<leader>gf', builtin.git_files, {})
		vim.keymap.set('n', '<leader>fw', builtin.live_grep, {})
	end
	}
