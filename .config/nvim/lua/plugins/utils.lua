return {
  {
    "MTDL9/vim-log-highlighting",
  },
  {
    "folke/flash.nvim",
    keys = {
      { "s", mode = { "n", "x", "o" }, false },
      { "gs", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    },
  },
}
