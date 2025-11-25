return {
  "olrtg/nvim-emmet",
  config = function()
    vim.keymap.set({ "n", "v" }, "<leader>l", function()
      require("nvim-emmet").wrap_with_abbreviation()
      vim.defer_fn(function()
        require("conform").format()
      end, 100)
    end)
  end,
}
