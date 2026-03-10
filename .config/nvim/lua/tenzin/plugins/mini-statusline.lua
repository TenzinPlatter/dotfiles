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
    "echasnovski/mini.statusline",
    version = "*",
    dependencies = {
      "f-person/git-blame.nvim",
      "skwee357/nvim-prose",
    },
    config = function()
      local prose = require("nvim-prose")
      local git_blame = require("gitblame")
      vim.g.gitblame_display_virtual_text = 0

      local statusline = require("mini.statusline")

      statusline.setup({
        content = {
          active = function()
            local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })

            -- Recording macro indicator
            local rec = ""
            local reg = vim.fn.reg_recording()
            if reg ~= "" then
              rec = "REC @" .. reg
            end

            -- Git blame in center
            local blame = ""
            if git_blame.is_blame_text_available() then
              blame = git_blame.get_current_blame_text()
            end

            -- Word count (prose files)
            local words = ""
            if prose.is_available() then
              words = prose.word_count()
            end

            -- LSP count
            local lsp = ""
            local clients = vim.lsp.get_active_clients({ bufnr = 0 })
            if #clients > 0 then
              lsp = "LSP:" .. #clients
            end

            local filename = statusline.section_filename({ trunc_width = 140 })

            return statusline.combine_groups({
              { hl = mode_hl, strings = { mode, rec } },
              { hl = "MiniStatuslineDevinfo", strings = {} },
              "%<", -- truncation point
              { hl = "MiniStatuslineFilename", strings = { blame } },
              "%=", -- right align
              { hl = "MiniStatuslineFileinfo", strings = { words, lsp } },
              { hl = "MiniStatuslineFilename", strings = { filename } },
            })
          end,
        },
        use_icons = true,
        set_vim_settings = true,
      })
    end,
  },
}
