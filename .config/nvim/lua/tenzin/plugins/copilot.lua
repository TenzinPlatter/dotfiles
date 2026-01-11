return {
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		opts = {
			suggestion = {
				auto_trigger = true,
				keymap = {
					accept = "<C-Space>",
					accept_word = "<C-Right>",
					accept_line = "<C-L>",
				},
			},
			panel = {
				enabled = false,
			},
			nes = {
				enabled = false,
				keymap = {
					accept_and_goto = false,
					accept = false,
					dismiss = "<Esc>",
				},
			},
		},
		-- config = function()
		-- 	require("copilot").setup({
		-- 	})

		-- 	-- Set keymaps manually
		-- 	vim.keymap.set('i', '<C-Space>', function()
		-- 		require('copilot.suggestion').accept()
		-- 	end, { desc = 'Accept Copilot suggestion' })

		-- 	vim.keymap.set({'i', 'n'}, '<M-L>', function()
		-- 		require('copilot-lsp.nes').apply_pending_nes()
		-- 		require('copilot-lsp.nes').walk_cursor_end_edit()
		-- 	end, { desc = 'Accept and goto NES suggestion' })
		-- end,
	},
}
