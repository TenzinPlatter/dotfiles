return {
  "TenzinPlatter/code-runner.nvim",
  keys = {
    {
      "<leader>cr",
      function()
        vim.cmd("CodeRunner")
      end,
    },
  },
  opts = {
    shell = "zsh",
    window = {
      width = 80,
    }
  },
}
