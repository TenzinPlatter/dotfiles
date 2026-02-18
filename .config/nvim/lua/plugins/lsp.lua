return {
  {
    "neovim/nvim-lspconfig",
    opts = { autoformat = false, inlay_hints = { enabled = false } },
    keys = {
      {
        "<C-S>",
        function()
          vim.diagnostic.open_float({ border = "rounded" })
        end,
        desc = "Line Diagnostics",
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {},
    },
  },
  {
    {
      "saghen/blink.cmp",
      opts = function(_, opts)
        opts.sources = vim.tbl_deep_extend("force", opts.sources or {}, {
          providers = {
            lazydev = {
              name = "LazyDev",
              module = "lazydev.integrations.blink",
              score_offset = 100,
            },
          },
        })

        -- prepend to the default sources list
        opts.sources.default = vim.list_extend({ "lazydev" }, opts.sources.default or {})

        return opts
      end,
    },
  },
  {
    "ray-x/lsp_signature.nvim",
    event = "InsertEnter",
    opts = {
      handler_opts = {
        border = "rounded",
      },
    },
    keys = {
      {
        "<C-s>",
        function()
          require("lsp_signature").toggle_float_win()
        end,
        mode = "i",
        { desc = "toggle signature" },
      },
    },
  },
}
