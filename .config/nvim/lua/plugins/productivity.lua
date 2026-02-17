return {
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    keys = {
      { "<leader>ql", function() require("persistence").load() end, desc = "Load session for current directory" },
      { "<leader>qS", function() require("persistence").select() end, desc = "Select a session to load" },
      { "<leader>qL", function() require("persistence").load({ last = true }) end, desc = "Load the last session" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "Stop persistence" },
    },
  },
  {
    "skwee357/nvim-prose",
  },
  {
    "opdavies/toggle-checkbox.nvim",
    keys = {
      {
        "<leader>tt",
        function()
          require("toggle-checkbox").toggle()
        end,
        desc = "Toggle checkbox",
      },
    },
  },
  {
    "kevinhwang91/nvim-bqf",
    dependencies = { "junegunn/fzf", "nvim-treesitter/nvim-treesitter" },
    opts = {
      preview = {
        winblend = 0,
      },
    },
  },
}
