return {
  {
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
      { "<M-h>", function() vim.cmd("TmuxNavigateLeft") end, mode = {"n", "t"}, desc = "Navigate left" },
      { "<M-j>", function() vim.cmd("TmuxNavigateDown") end, mode = {"n", "t"}, desc = "Navigate down" },
      { "<M-k>", function() vim.cmd("TmuxNavigateUp") end, mode = {"n", "t"}, desc = "Navigate up" },
      { "<M-l>", function() vim.cmd("TmuxNavigateRight") end, mode = {"n", "t"}, desc = "Navigate right" },
    },
  },
  {
    "mikavilpas/yazi.nvim",
    version = "*",
    event = "VeryLazy",
    dependencies = {
      { "nvim-lua/plenary.nvim", lazy = true },
    },
    keys = {
      {
        "<leader>-",
        mode = { "n", "v" },
        "<cmd>Yazi<cr>",
        desc = "Open yazi at the current file",
      },
      {
        "<leader>cw",
        "<cmd>Yazi cwd<cr>",
        desc = "Open the file manager in nvim's working directory",
      },
      {
        "<c-up>",
        "<cmd>Yazi toggle<cr>",
        desc = "Resume the last yazi session",
      },
    },
    opts = {
      open_for_directories = false,
      keymaps = {
        show_help = "<f1>",
      },
    },
    init = function()
      vim.g.loaded_netrwPlugin = 1
    end,
  },
  {
    "chrisgrieser/nvim-rip-substitute",
    cmd = "RipSubstitute",
    keys = {
      {
        "<leader>ss",
        function() require("rip-substitute").sub() end,
        mode = { "n", "x" },
        desc = "Rip substitute",
      },
    },
  },
}
