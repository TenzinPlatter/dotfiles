--[[
return {
  "epwalsh/obsidian.nvim",
  version = "*",
	ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
		workspaces = {
			{
				name = "INFO1111",
				path = "~/obsidian/INFO1111"
			},
			{
				name = "DATA1001",
				path = "~/obsidian/data1001"
			},
			{
				name = "Miscellaneous",
				path = "~/obsidian/misc"
			}
		},
	}
}
]]

return {}
