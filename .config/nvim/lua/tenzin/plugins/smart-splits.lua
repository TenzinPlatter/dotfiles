return {
  "mrjones2014/smart-splits.nvim",
  -- Must load at startup: the kitty integration sets the IS_NVIM user-var then,
  -- so do NOT lazy-load this plugin.
  lazy = false,
  opts = {},
  config = function(_, opts)
    local ss = require("smart-splits")
    ss.setup(opts)
    -- Seamless navigation across nvim windows, kitty splits, and tmux panes.
    -- smart-splits auto-detects the multiplexer (kitty locally, tmux when remote).
    vim.keymap.set({ "n", "t" }, "<M-h>", ss.move_cursor_left, { desc = "Navigate left (nvim/kitty/tmux)" })
    vim.keymap.set({ "n", "t" }, "<M-j>", ss.move_cursor_down, { desc = "Navigate down (nvim/kitty/tmux)" })
    vim.keymap.set({ "n", "t" }, "<M-k>", ss.move_cursor_up, { desc = "Navigate up (nvim/kitty/tmux)" })
    vim.keymap.set({ "n", "t" }, "<M-l>", ss.move_cursor_right, { desc = "Navigate right (nvim/kitty/tmux)" })
  end,
}
