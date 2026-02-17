return {
  {
    "neovim/nvim-lspconfig",
    opts = { autoformat = false },
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
        { desc = "toggle signature", mode = {"i"} },
      },
    },
  },
}
