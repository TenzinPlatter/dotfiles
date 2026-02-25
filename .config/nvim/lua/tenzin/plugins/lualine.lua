return {
  {
    "f-person/git-blame.nvim",
    event = "VeryLazy",
    opts = {
      enabled = true,
      message_template = " <summary> • <date> • <author> • <<sha>>",
      date_format = "%d-%m-%Y %H:%M:%S",
      virtual_text_column = 1,
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "f-person/git-blame.nvim",
    },
    config = function()
      local prose = require("nvim-prose")
      local git_blame = require("gitblame")
      -- This disables showing of the blame text next to the cursor
      vim.g.gitblame_display_virtual_text = 0
      require("lualine").setup({
        sections = {
          lualine_a = {
            "mode",
            {
              function()
                local reg = vim.fn.reg_recording()
                if reg ~= "" then
                  return "REC @" .. reg
                end
                return ""
              end,
            },
          },
          lualine_c = { { git_blame.get_current_blame_text, cond = git_blame.is_blame_text_available } },
          lualine_x = {
            { prose.word_count, cond = prose.is_available },
            {
              function()
                local clients = vim.lsp.get_active_clients({ bufnr = 0 })
                return "LSP:" .. #clients
              end,
              cond = function()
                return #vim.lsp.get_active_clients({ bufnr = 0 }) > 0
              end,
            },
          },
          lualine_y = { { "filename", path = 1 } },
        },
        options = {
          globalstatus = true,
        },
      })
    end,
  },
}
