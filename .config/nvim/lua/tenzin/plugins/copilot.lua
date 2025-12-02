return {
	"zbirenbaum/copilot.lua",
	requires = {
		"copilotlsp-nvim/copilot-lsp",
	},
	cmd = "Copilot",
	event = "InsertEnter",
	opts = {
		suggestion = {
			auto_trigger = true,
			keymap = {
				accept = "<C-Space>",
			},
		},
	},
}

-- {
-- 	"https://github.com/zbirenbaum/copilot-cmp",
-- 	config = function()
-- 		require("copilot_cmp").setup({
-- 			formatting = {
-- 				format = require("copilot_cmp.format").format,
-- 			},
-- 			experimental = {
-- 				ghost_text = true,
-- 			},
-- 		})
-- 	end,
-- },
