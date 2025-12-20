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

      local luasnip = require("luasnip")
      require("luasnip.loaders.from_lua").lazy_load({ paths = { vim.fn.stdpath("config") .. "/luasnippets" } })
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end
        },

        mapping = cmp.mapping.preset.insert({
          ['<C-u>'] = cmp.mapping.scroll_docs(-4),
          ['<C-d>'] = cmp.mapping.scroll_docs(4),
          ['<Tab>'] = cmp.mapping.confirm({ select = true }),

          ['<C-L>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.mapping.confirm({ select = true })
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),

          ['<C-H>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.mapping.confirm({ select = true })
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),

        }),

        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
        })
      })

      cmp.setup.cmdline(':', {
        sources = cmp.config.sources({
          { name = 'fuzzy_path' }
        })
      })
    end
  }
}
