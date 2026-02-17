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
      -- Disable LazyVim defaults in favour of Neovim 0.10+ gr-prefix bindings
      { "gr", false },
      { "gI", false },
      { "<leader>cr", false },
      { "<leader>ca", false },
      { "<leader>cA", false },
      -- Neovim 0.10+ default LSP bindings
      { "grr", vim.lsp.buf.references, desc = "References" },
      { "gri", vim.lsp.buf.implementation, desc = "Go to Implementation" },
      { "grn", vim.lsp.buf.rename, desc = "Rename" },
      { "gra", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "v" } },
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
        mode = "i",
        { desc = "toggle signature" },
      },
    },
  },
}
