return {
  "https://github.com/Cannon07/claude-preview.nvim",
  config = function()
    require("claude-preview").setup()
    vim.o.autoread = true
    vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
      command = "checktime",
    })
  end,
}
