return {
	{
		'https://github.com/hrsh7th/nvim-cmp',
		version = "v2.3.0",
		dependencies = {
			'https://github.com/hrsh7th/cmp-nvim-lsp',
			'https://github.com/L3MON4D3/LuaSnip',
			'https://github.com/saadparwaiz1/cmp_luasnip',
			'https://github.com/rafamadriz/friendly-snippets',
		},
		config = function()
			local cmp = require("cmp")
			local cmp_autopairs = require('nvim-autopairs.completion.cmp')

			cmp.event:on(
			'confirm_done',
			cmp_autopairs.on_confirm_done()
			)

			require("luasnip.loaders.from_vscode").lazy_load()
			cmp.setup({
				snippet = {
					expand = function(args)
						require('luasnip').lsp_expand(args.body)
					end
				},

				mapping = cmp.mapping.preset.insert({
					['<C-b>'] = cmp.mapping.scroll_docs(-4),
					['<C-f>'] = cmp.mapping.scroll_docs(4),
					['<C-o>'] = cmp.mapping.complete(),
					['<C-e>'] = cmp.mapping.abort(),
					['<tab>'] = cmp.mapping.confirm({ select = true }),
				}),

				sources = cmp.config.sources({
					{ name = 'nvim_lsp' },
					{ name = 'luasnip' },
				}, {
					{ name = 'buffer' },
				})
			})
		end
}
}
