return {
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		dependencies = { "nvim-treesitter/nvim-treesitter", branch = "main" },
		init = function()
			vim.g.no_plugin_maps = true
		end,
		config = function()
			require("nvim-treesitter-textobjects").setup({
				select = {
					-- Automatically jump forward to textobj, similar to targets.vim
					lookahead = true,
					-- You can choose the select mode (default is charwise 'v')

					selection_modes = {
						["@parameter.outer"] = "v", -- charwise
						["@function.outer"] = "V", -- linewise
						["@class.outer"] = "<c-v>", -- blockwise
					},
					include_surrounding_whitespace = false,
				},
				move = {
					-- whether to set jumps in the jumplist
					set_jumps = true,
				},
			})

			-- Selects
			local select = require("nvim-treesitter-textobjects.select")
			vim.keymap.set({ "x", "o" }, "am", function()
				select.select_textobject("@function.outer", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "im", function()
				select.select_textobject("@function.inner", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "ac", function()
				select.select_textobject("@class.outer", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "ic", function()
				select.select_textobject("@class.inner", "textobjects")
			end)
			-- You can also use captures from other query groups like `locals.scm`
			vim.keymap.set({ "x", "o" }, "as", function()
				select.select_textobject("@local.scope", "locals")
			end)

			-- Swaps
			local swap = require("nvim-treesitter-textobjects.swap")
			vim.keymap.set("n", "<leader>a", function()
				swap.swap_next("@parameter.inner")
			end)
			vim.keymap.set("n", "<leader>A", function()
				swap.swap_previous("@parameter.outer")
			end)

			local move = require("nvim-treesitter-textobjects.move")
			vim.keymap.set({ "n", "x", "o" }, "]m", function()
				move.goto_next_start("@function.outer", "textobjects")
			end)
			vim.keymap.set({ "n", "x", "o" }, "]]", function()
				move.goto_next_start("@class.outer", "textobjects")
			end)
			-- You can also pass a list to group multiple queries.
			vim.keymap.set({ "n", "x", "o" }, "]o", function()
				move.goto_next_start({ "@loop.inner", "@loop.outer" }, "textobjects")
			end)
			-- You can also use captures from other query groups like `locals.scm` or `folds.scm`
			vim.keymap.set({ "n", "x", "o" }, "]s", function()
				move.goto_next_start("@local.scope", "locals")
			end)
			vim.keymap.set({ "n", "x", "o" }, "]z", function()
				move.goto_next_start("@fold", "folds")
			end)

			vim.keymap.set({ "n", "x", "o" }, "]M", function()
				move.goto_next_end("@function.outer", "textobjects")
			end)
			vim.keymap.set({ "n", "x", "o" }, "][", function()
				move.goto_next_end("@class.outer", "textobjects")
			end)

			vim.keymap.set({ "n", "x", "o" }, "[m", function()
				move.goto_previous_start("@function.outer", "textobjects")
			end)
			vim.keymap.set({ "n", "x", "o" }, "[[", function()
				move.goto_previous_start("@class.outer", "textobjects")
			end)

			vim.keymap.set({ "n", "x", "o" }, "[M", function()
				move.goto_previous_end("@function.outer", "textobjects")
			end)
			vim.keymap.set({ "n", "x", "o" }, "[]", function()
				move.goto_previous_end("@class.outer", "textobjects")
			end)

			-- Go to either the start or the end, whichever is closer.
			-- Use if you want more granular movements
			vim.keymap.set({ "n", "x", "o" }, "]d", function()
				move.goto_next("@conditional.outer", "textobjects")
			end)
			vim.keymap.set({ "n", "x", "o" }, "[d", function()
				move.goto_previous("@conditional.outer", "textobjects")
			end)
		end,
	},
	{
		"https://github.com/nvim-treesitter/nvim-treesitter",
		lazy = false,
		branch = "main",
		build = ":TSUpdate",
		config = function()
			local ts = require("nvim-treesitter")
			local parsers = {
				"bash",
				"comment",
				"css",
				"diff",
				"dockerfile",
				"git_config",
				"gitcommit",
				"gitignore",
				"html",
				"http",
				"java",
				"javascript",
				"jsdoc",
				"json",
				"json5",
				"jsonc",
				"lua",
				"make",
				"markdown",
				"markdown_inline",
				"python",
				"regex",
				"rst",
				"rust",
				"scss",
				"ssh_config",
				"sql",
				"terraform",
				"typst",
				"toml",
				"tsx",
				"typescript",
				"vim",
				"vimdoc",
				"yaml",
			}

			for _, parser in ipairs(parsers) do
				ts.install(parser)
			end

			vim.treesitter.language.register("groovy", "Jenkinsfile")
			vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
			vim.wo[0][0].foldmethod = "expr"
			vim.api.nvim_command("set nofoldenable")

			vim.api.nvim_create_autocmd("FileType", {
				pattern = parsers,
				callback = function()
					vim.treesitter.start()
				end,
			})
		end,
	},
}
