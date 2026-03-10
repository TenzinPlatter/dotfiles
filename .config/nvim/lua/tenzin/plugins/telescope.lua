-- Kept as a dependency for octo.nvim which requires telescope for its UI
return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  lazy = true,
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
}
