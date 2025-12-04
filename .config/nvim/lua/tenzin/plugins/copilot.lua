return {
	"zbirenbaum/copilot.lua",
	requires = {
		"copilotlsp-nvim/copilot-lsp",
	},
	cmd = "Copilot",
	event = "InsertEnter",
	opts = {
		suggestion = {
			auto_trigger = false,
			keymap = {
				accept = "<C-Space>",
			},
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
