return {
  dir = "/home/tenzin/code/code-runner.nvim/",
  keys = {
    {
      "<leader>cr",
      function ()
        vim.cmd("CodeRunner")
      end
    }
  },
  -- opts = {
  --   window = {
  --     split = "right"
  --   }
  -- },
}
