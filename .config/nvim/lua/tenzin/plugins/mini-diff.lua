return {
  {
    "echasnovski/mini.diff",
    version = "*",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("mini.diff").setup({
        view = {
          style = "sign",
          signs = {
            add = "▎",
            change = "▎",
            delete = "",
          },
        },
      })

      -- Navigation keymaps to match gitsigns behavior
      vim.keymap.set("n", "]c", function()
        if vim.wo.diff then
          vim.cmd.normal({ "]c", bang = true })
        else
          MiniDiff.goto_hunk("next")
        end
      end, { desc = "Next hunk" })

      vim.keymap.set("n", "[c", function()
        if vim.wo.diff then
          vim.cmd.normal({ "[c", bang = true })
        else
          MiniDiff.goto_hunk("prev")
        end
      end, { desc = "Prev hunk" })
    end,
  },
  {
    "echasnovski/mini.git",
    version = "*",
    event = "VeryLazy",
    opts = {},
  },
}
