return {
  "nvim-mini/mini.cursorword",
  version = false,
  config = function()
    require("mini.cursorword").setup()

    local function set_hl()
      vim.api.nvim_set_hl(0, "MiniCursorword", { bg = "#3d3d3d", underline = false })
      vim.api.nvim_set_hl(0, "MiniCursorwordCurrent", { bg = "#3d3d3d", underline = false })
    end

    set_hl()
    vim.api.nvim_create_autocmd("ColorScheme", { callback = set_hl })
  end,
}
