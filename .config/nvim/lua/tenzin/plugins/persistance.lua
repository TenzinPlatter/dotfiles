return {
  "folke/persistence.nvim",
  event = "BufReadPre", -- this will only start session saving when an actual file was opened
  opts = {
    -- add any custom options here
  },
  keys = {
    -- load the session for the current directory
    {
      "<leader>ql",
      function()
        require("persistence").load()
      end,
      desc = "Load session for current directory",
    },
    -- select a session to load
    {
      "<leader>qS",
      function()
        require("persistence").select()
      end,
      desc = "Select a session to load",
    },
    -- load the last session
    {
      "<leader>qL",
      function()
        require("persistence").load({ last = true })
      end,
      desc = "Load the last session",
    },
    -- stop Persistence => session won't be saved on exit
    {
      "<leader>qd",
      function()
        require("persistence").stop()
      end,
      desc = "Stop persistence",
    },
  },
}
