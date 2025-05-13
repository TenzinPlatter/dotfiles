return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
		config = function()
			local prose = require("nvim-prose")

			require('lualine').setup({
				sections = {
					lualine_x = {
						{ prose.word_count, cond = prose.is_available }
					}
				}
			})
		end
}
