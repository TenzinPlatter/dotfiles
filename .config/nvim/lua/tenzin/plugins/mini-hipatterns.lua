return {
  "echasnovski/mini.hipatterns",
  version = "*",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local hipatterns = require("mini.hipatterns")
    hipatterns.setup({
      highlighters = {
        -- Highlight hex colors
        hex_color = hipatterns.gen_highlighter.hex_color(),

        -- Highlight TODO/FIXME/NOTE/HACK/WARN
        fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
        hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
        todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
        note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
      },
    })

    -- Set up highlight groups to match todo-comments style
    vim.api.nvim_set_hl(0, "MiniHipatternsFixme", { fg = "#f38ba8", bold = true })
    vim.api.nvim_set_hl(0, "MiniHipatternsHack", { fg = "#fab387", bold = true })
    vim.api.nvim_set_hl(0, "MiniHipatternsTodo", { fg = "#89b4fa", bold = true })
    vim.api.nvim_set_hl(0, "MiniHipatternsNote", { fg = "#a6e3a1", bold = true })
  end,
}
