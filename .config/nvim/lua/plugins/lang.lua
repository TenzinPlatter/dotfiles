return {
  {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
  },
  {
    "mrcjkb/rustaceanvim",
    lazy = false,
    config = function()
      vim.g.rustaceanvim = {
        tools = {},
        server = {
          default_settings = {
            ["rust-analyzer"] = {
              rust = {
                analyzerTargetDir = true,
              },
            },
          },
        },
      }
    end,
  },
  {
    "olrtg/nvim-emmet",
    config = function()
      vim.keymap.set({ "n", "v" }, "<leader>l", function()
        require("nvim-emmet").wrap_with_abbreviation()
        vim.defer_fn(function()
          require("conform").format()
        end, 100)
      end, { desc = "Emmet expand abbreviation" })
    end,
  },
}
