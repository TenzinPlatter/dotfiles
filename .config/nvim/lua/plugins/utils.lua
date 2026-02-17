return {
  {
    "MTDL9/vim-log-highlighting",
  },
  {
    "folke/flash.nvim",
    opts = {
      modes = {
        char = {
          jump_labels = function()
            return vim.v.count == 0 and vim.fn.mode(true):find("o")
          end,
        },
      },
    },
    keys = {
      { "s", mode = { "n", "x", "o" }, false },
      { "gs", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    },
  },
}
