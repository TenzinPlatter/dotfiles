return {
	"folke/sidekick.nvim",
	opts = {
		nes = {
			enabled = false,
		},
		cli = {
			mux = {
				backend = "tmux",
				enabled = true,
			},
		},
	},
  -- stylua: ignore
  init = function ()
    require("sidekick.nes").disable()
  end,
	keys = {
		{
			"<tab>",
			function()
				-- if there is a next edit, jump to it, otherwise apply it if any
				if not require("sidekick").nes_jump_or_apply() then
					return "<Tab>" -- fallback to normal tab
				end
			end,
			expr = true,
			desc = "Goto/Apply Next Edit Suggestion",
		},
		{
			"<leader>cl",
			function()
				require("sidekick.nes").clear()
			end,
			desc = "Clear All Edit Suggestions",
			mode = { "n" },
		},
		{
			"<leader>aa",
			function()
				require("sidekick.cli").toggle()
			end,
			mode = { "n", "v" },
			desc = "Sidekick Toggle CLI",
		},
		{
			"<leader>as",
			function()
				require("sidekick.cli").select()
			end,
			-- Or to select only installed tools:
			-- require("sidekick.cli").select({ filter = { installed = true } })
			desc = "Sidekick Select CLI",
		},
		{
			"<leader>as",
			function()
				require("sidekick.cli").send({ selection = true })
			end,
			mode = { "v" },
			desc = "Sidekick Send Visual Selection",
		},
		{
			"<leader>ap",
			function()
				require("sidekick.cli").prompt()
			end,
			mode = { "n", "v" },
			desc = "Sidekick Select Prompt",
		},
		{
			"<c-.>",
			function()
				require("sidekick.cli").focus()
			end,
			mode = { "n", "x", "i", "t" },
			desc = "Sidekick Switch Focus",
		},
		-- Example of a keybinding to open Claude directly
		{
			"<leader>ac",
			function()
				require("sidekick.cli").toggle({ name = "crush", focus = true })
			end,
			desc = "Sidekick Crush Toggle",
			mode = { "n", "v" },
		},
	},
}
