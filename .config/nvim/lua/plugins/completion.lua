return {
  {
    "saghen/blink.cmp",
    dependencies = { "rafamadriz/friendly-snippets" },
    version = "1.*",
    opts = {
      keymap = {
        preset = "super-tab",
        ["<C-Space>"] = false,
        ["<C-L>"] = { "snippet_forward", "fallback" },
        ["<C-H>"] = { "snippet_backward", "fallback" },
        ["<C-D>"] = { "scroll_documentation_down", "fallback" },
        ["<C-U>"] = { "scroll_documentation_up", "fallback" },
        ["<C-F>"] = { "scroll_documentation_down", "fallback" },
        ["<C-B>"] = { "scroll_documentation_up", "fallback" },
        ["<C-J>"] = { "scroll_signature_down", "fallback" },
        ["<C-K>"] = { "scroll_signature_up", "fallback" },
      },

      appearance = {
        nerd_font_variant = "mono",
      },

      completion = {
        documentation = {
          auto_show = true,
          window = {
            border = "rounded",
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
          },
        },
        menu = {
          border = "rounded",
          winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
        },
        ghost_text = {
          enabled = true,
        },
      },

      signature = {
        window = {
          border = "rounded",
          winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
        },
      },

      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },

      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
  },
}
