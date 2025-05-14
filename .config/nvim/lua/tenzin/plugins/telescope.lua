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
		vim.keymap.set('n', '<leader>f', builtin.find_files)
		vim.keymap.set('n', '<leader>/', builtin.live_grep)
		vim.keymap.set('n', '<leader>?', builtin.grep_string)

		vim.keymap.set('n', '<leader>h', function()
			vim.api.nvim_echo({ { "Enter single digit: ", "None" } }, false, {})
			local char = vim.fn.nr2char(vim.fn.getchar())
			vim.api.nvim_echo({ { "", "" } }, false, {})

			local n = tonumber(char)
			if not n then
				vim.notify("Invalid number: " .. s, vim.log.levels.ERROR)
				return
			end

			builtin.man_pages({ sections = { char } })
		end)
	end
}
