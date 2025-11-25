return {
	"https://github.com/sindrets/diffview.nvim",
	config = function()
		require("diffview").setup({
			enhanced_diff_hl = true,
			view = {
				merge_tool = {
					-- layout = "diff3_mixed",
					layout = "diff4_mixed",
				},
			},
		})
		vim.api.nvim_set_hl(0, 'DiffAdd', { bg = '#34462F' })
		vim.api.nvim_set_hl(0, 'DiffDelete', { bg = '#462F2F' })
		vim.api.nvim_set_hl(0, 'DiffChange', { bg = '#2F4146' })
		vim.api.nvim_set_hl(0, 'DiffText', { bg = '#462F2F' })
		-- to stop it from linking to DiffText
		vim.cmd('highlight clear DiffTextAdd')
		-- vim.api.nvim_set_hl(0, 'DiffTextAdd', { bg = '#462F2F' })
		vim.api.nvim_set_hl(0, 'DiffTextAdd', { bg = 'green' })
		vim.api.nvim_set_hl(0, 'DiffviewDiffAddAsDelete', { bg = '#462F2F'})
		vim.api.nvim_set_hl(0, 'DiffviewDiffDelete', { bg = '#462F2F'})
	end,
}

-- • A: OURS (current branch)
-- • B: LOCAL (the file as it currently exists on disk)
-- • C: THEIRS (incoming branch)
-- • D: BASE (common ancestor)
-- {diff3_mixed}
--     Available for: merge_tool

--     ┌──────┬───────┐
--     │  A   │   C   │
--     │      │       │
--     ├──────┴───────┤
--     │      B       │
--     │              │
--     └──────────────┘

-- {diff4_mixed}
--     Available for: merge_tool

--     ┌────┬────┬────┐
--     │ A  │ D  │ C  │
--     │    │    │    │
--     ├────┴────┴────┤
--     │      B       │
--     │              │
--     └──────────────┘
