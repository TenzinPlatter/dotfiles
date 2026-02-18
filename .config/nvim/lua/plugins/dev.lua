return {
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        -- Always load Neovim runtime types (fixes vim.* in ftplugin/ etc.)
        vim.env.VIMRUNTIME,
      },
    },
  },
  { "folke/neodev.nvim", enabled = false },
}
