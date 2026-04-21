return {
  "dmtrKovalenko/fff.nvim",
  build = function()
    -- this will download prebuild binary or try to use existing rustup toolchain to build from source
    -- (if you are using lazy you can use gb for rebuilding a plugin if needed)
    require("fff.download").download_or_build_binary()
  end,
  opts = {
    debug = {
      enabled = true,
      show_scores = true,
    },
  },
  lazy = false,
  keys = {
    {
      "<leader>ff",
      function()
        require("fff").find_files()
      end,
      desc = "FFFind files",
    },
    {
      "<leader>sg",
      function()
        require("fff").live_grep()
      end,
      desc = "LiFFFe grep",
    },
    {
      "<leader>fz",
      function()
        require("fff").live_grep({
          grep = {
            modes = { "fuzzy", "plain" },
          },
        })
      end,
      desc = "Live fffuzy grep",
    },
    {
      "<leader>fc",
      function()
        require("fff").find_files({ cwd = vim.fn.stdpath("config") })
      end,
      desc = "Live fffuzy grep",
    },
    {
      "<leader>sw",
      function()
        require("fff").live_grep({ query = vim.fn.expand("<cword>") })
      end,
      desc = "Search current word",
    },
  },
}
