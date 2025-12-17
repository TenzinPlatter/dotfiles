return {
  "esmuellert/vscode-diff.nvim",
  branch = "next",
  dependencies = { "MunifTanjim/nui.nvim" },
  keys = {
    {
      "<leader>cd",
      function ()
        vim.cmd("CodeDiff")
      end,
      desc = "Toggle VSCode git diff"
    }
  }
}
