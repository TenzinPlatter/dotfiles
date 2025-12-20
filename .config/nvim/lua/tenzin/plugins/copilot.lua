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
				accept = "<C-e>",
			},
		},
		nes = {
			enabled	= true,
			keymap = {
				accept_and_goto = "<M-L>",
				accept = false,
				dismiss = "<Esc>",
			}
		},
	},
	keys = {
		{
			"<leader>tc",
			"<cmd>Copilot toggle<cr>",
			desc = "Toggle Copilot",
		},
	},
}
