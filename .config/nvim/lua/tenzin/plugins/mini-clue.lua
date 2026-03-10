return {
  "echasnovski/mini.clue",
  version = "*",
  event = "VeryLazy",
  config = function()
    local miniclue = require("mini.clue")
    miniclue.setup({
      triggers = {
        -- Leader triggers
        { mode = "n", keys = "<Leader>" },
        { mode = "x", keys = "<Leader>" },
        -- g key
        { mode = "n", keys = "g" },
        { mode = "x", keys = "g" },
        -- Brackets
        { mode = "n", keys = "[" },
        { mode = "n", keys = "]" },
        -- z key
        { mode = "n", keys = "z" },
        { mode = "x", keys = "z" },
        -- Marks
        { mode = "n", keys = "'" },
        { mode = "n", keys = "`" },
        -- Registers
        { mode = "n", keys = '"' },
        { mode = "x", keys = '"' },
        { mode = "i", keys = "<C-r>" },
        -- Window commands
        { mode = "n", keys = "<C-w>" },
      },
      clues = {
        miniclue.gen_clues.builtin_completion(),
        miniclue.gen_clues.g(),
        miniclue.gen_clues.marks(),
        miniclue.gen_clues.registers(),
        miniclue.gen_clues.windows(),
        miniclue.gen_clues.z(),
      },
      window = {
        delay = 250,
      },
    })
  end,
}
