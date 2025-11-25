return {
	"jiaoshijie/undotree",
	opts = {
		-- your options
	},
	keys = { -- load the plugin only when using it's keybinding:
		{
			"<leader>uu",
			function()
				require("undotree").toggle()
			end,
		},
	},
}
