return {
  {
    "stevearc/conform.nvim",
    opts = {
      -- Completely disable format on save
      format_on_save = false,
      format_after_save = false,
      formatters_by_ft = {
        python = { "ruff_format" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        lua = { "stylua" },
        yaml = { "yamlfmt" },
        rust = { "rustfmt" },
        ts = { "prettier" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        bash = { "beautysh" },
        zsh = { "beautysh" },
        sh = { "beautysh" },
        html = { "prettier" },
      },
      formatters = {
        ruff_format = {
          args = { "format", "--stdin-filename", "$FILENAME", "-" },
        },
      },
    },
    keys = {
      {
        "<leader>=",
        function()
          require("conform").format({ lsp_fallback = true })
        end,
        mode = { "n", "v" },
        desc = "Format buffer or selection",
      },
    },
  },
}
