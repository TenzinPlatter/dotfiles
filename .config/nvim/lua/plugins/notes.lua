return {
  {
    "epwalsh/obsidian.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
    },
    version = "*",
    lazy = true,
    event = {
      "BufReadPre /home/tenzin/gr/notes/*.md",
      "BufNewFile /home/tenzin/gr/notes/*.md",
    },
    opts = {
      ui = { enable = false },
      workspaces = {
        {
          name = "greenroom",
          path = "/home/tenzin/gr/notes",
        },
      },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    config = function()
      vim.api.nvim_set_hl(0, "RenderMarkdownCodeBorderSubtle", { bg = "#1a1a1a" })

      require("render-markdown").setup({
        bullet = {
          right_pad = 1,
        },
        code = {
          disable_background = true,
          style = "full",
          border = "thick",
          highlight_border = "RenderMarkdownCodeBorderSubtle",
        },
      })
    end,
  },
}
