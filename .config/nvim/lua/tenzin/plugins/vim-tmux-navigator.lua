return {
  "christoomey/vim-tmux-navigator",
  keys = {
    {
      "<M-h>",
      function()
        vim.cmd("TmuxNavigateLeft")
      end,
      mode = { "n", "t" },
      desc = "Navigate left (vim/tmux)",
    },
    {
      "<M-j>",
      function()
        vim.cmd("TmuxNavigateDown")
      end,
      mode = { "n", "t" },
      desc = "Navigate down (vim/tmux)",
    },
    {
      "<M-k>",
      function()
        vim.cmd("TmuxNavigateUp")
      end,
      mode = { "n", "t" },
      desc = "Navigate up (vim/tmux)",
    },
    {
      "<M-l>",
      function()
        vim.cmd("TmuxNavigateRight")
      end,
      mode = { "n", "t" },
      desc = "Navigate right (vim/tmux)",
    },
  },
  init = function()
    vim.g.tmux_navigator_no_mappings = 1
  end,
}
