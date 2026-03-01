return {
  "dtormoen/neural-open.nvim",
  dependencies = {
    "folke/snacks.nvim",
  },
  -- NeuralOpen implements lazy loading internally. It needs to be loaded for recency tracking to work.
  lazy = false,
  keys = {
    { "<leader>ff", "<Plug>(NeuralOpen)", desc = "Neural Open Files" },
  },
  -- opts are optional. NeuralOpen will automatically use the defaults below.
  opts = {},
}
