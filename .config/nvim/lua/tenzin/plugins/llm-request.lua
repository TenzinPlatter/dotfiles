return {
	"https://github.com/TenzinPlatter/nvim-llm-request",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
	},
	build = "pip3 install -r python/requirements.txt --break-system-packages",
	config = function()
		require("ai-request").setup({
			-- Provider configuration
			provider = "local",
			model = "llama3.2:3b",
			base_url = "http://localhost:11434/v1",

			-- Behavior
			timeout = 30, -- seconds
			max_tool_calls = 3,
			max_concurrent_requests = 3,

			-- Display
			display = {
				show_thinking = true,
				show_spinner = true,
			},

			-- Context extraction
			context = {
				lines_before = 100,
				lines_after = 20,
				include_treesitter = true,
				include_lsp = false,
			},
		})
	end,
}
