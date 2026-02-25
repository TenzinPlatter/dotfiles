return {
  "christoomey/vim-tmux-navigator",
  event = "VeryLazy",
  init = function()
    vim.g.tmux_navigator_no_mappings = 1
  end,
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
    "TmuxNavigatorProcessList",
  },
  keys = {
    {
      "<M-h>",
      function()
        vim.cmd("TmuxNavigateLeft")
      end,
      mode = { "n", "t" },
    },
    {
      "<M-j>",
      function()
        vim.cmd("TmuxNavigateDown")
      end,
      mode = { "n", "t" },
    },
    {
      "<M-k>",
      function()
        vim.cmd("TmuxNavigateUp")
      end,
      mode = { "n", "t" },
    },
    {
      "<M-l>",
      function()
        vim.cmd("TmuxNavigateRight")
      end,
      mode = { "n", "t" },
    },
  },
}
