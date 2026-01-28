return {
	"https://github.com/MeanderingProgrammer/render-markdown.nvim",
	config = function()
		vim.api.nvim_set_hl(0, "RenderMarkdownCodeBorderSubtle", { bg = "#1a1a1a" })

		require("render-markdown").setup({
			bullet = {
				right_pad = 1,
			},
			code = {
				disable_background = true,
				style = "full",
				border = "thick",
				highlight_border = "RenderMarkdownCodeBorderSubtle",
			},
		})
	end,
}
