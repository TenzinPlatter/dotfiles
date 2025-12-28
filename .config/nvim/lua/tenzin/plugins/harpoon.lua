return {
	"https://github.com/ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
	config = function()
		local harpoon = require("harpoon")
		-- REQUIRED for harpoon2
		harpoon:setup({})

		-- basic telescope configuration
		local conf = require("telescope.config").values
		local function toggle_telescope(harpoon_files)
			local file_paths = {}
			for _, item in ipairs(harpoon_files.items) do
				table.insert(file_paths, item.value)
			end

			require("telescope.pickers")
				.new({}, {
					prompt_title = "Harpoon",
					finder = require("telescope.finders").new_table({
						results = file_paths,
					}),
					previewer = conf.file_previewer({}),
					sorter = conf.generic_sorter({}),
				})
				:find()
		end

    -- stylua: ignore start

    vim.keymap.set('n', '<leader>m', function() toggle_telescope(harpoon:list()) end, { desc = "Harpoon Menu" })
    vim.keymap.set("n", "<leader><C-m>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

    vim.keymap.set('n', '<leader>a', function() harpoon:list():add() end, { desc = "Harpoon Add File" })

    vim.keymap.set('n', '<leader>1', function() harpoon:list():select(1) end, { desc = "Harpoon Go to File 1" })
    vim.keymap.set('n', '<leader>2', function() harpoon:list():select(2) end, { desc = "Harpoon Go to File 2" })
    vim.keymap.set('n', '<leader>3', function() harpoon:list():select(3) end, { desc = "Harpoon Go to File 3" })
    vim.keymap.set('n', '<leader>4', function() harpoon:list():select(4) end, { desc = "Harpoon Go to File 4" })
    vim.keymap.set('n', '<leader>5', function() harpoon:list():select(5) end, { desc = "Harpoon Go to File 5" })
    vim.keymap.set('n', '<leader>6', function() harpoon:list():select(6) end, { desc = "Harpoon Go to File 6" })
    vim.keymap.set('n', '<leader>7', function() harpoon:list():select(7) end, { desc = "Harpoon Go to File 7" })
    vim.keymap.set('n', '<leader>8', function() harpoon:list():select(8) end, { desc = "Harpoon Go to File 8" })
    vim.keymap.set('n', '<leader>9', function() harpoon:list():select(9) end, { desc = "Harpoon Go to File 9" })

		-- stylua: ignore end
	end,
}
