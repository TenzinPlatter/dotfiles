return {
  {
    "rebelot/kanagawa.nvim",
    opts = {
      transparent = true,
      theme = {
        all = {
          ui = {
            bg_gutter = "none",
            float = {
              bg = "none",
            },
          },
        },
      },
    },
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    config = function()
      require("rose-pine").setup({
        variant = "moon",
        styles = {
          transparency = true,
          bold = true,
          italic = true,
        },
      })
    end,
  },
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    opts = {
      transparent_mode = true,
    },
  },
  {
    "EdenEast/nightfox.nvim",
    config = function()
      require("nightfox").setup({
        options = {
          transparent = true,
        },
      })
    end,
  },
  {
    "vague2k/huez.nvim",
    import = "huez-manager.import",
    branch = "stable",
    event = "UIEnter",
    opts = {},
    keys = {
      {
        "<leader>tp",
        function()
          vim.cmd("Huez")
        end,
        desc = "Theme picker",
      },
    },
  },
}
