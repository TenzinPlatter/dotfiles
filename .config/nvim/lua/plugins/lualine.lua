return {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    "f-person/git-blame.nvim",
    "skwee357/nvim-prose",
  },
  opts = function(_, opts)
    local git_blame = require("gitblame")
    local prose = require("nvim-prose")

    -- Override sections to add custom components
    opts.sections = vim.tbl_deep_extend("force", opts.sections or {}, {
      lualine_a = {
        "mode",
        {
          -- Show recording status
          function()
            local reg = vim.fn.reg_recording()
            if reg ~= "" then
              return "REC @" .. reg
            end
            return ""
          end,
        },
      },
      lualine_c = {
        -- Git blame in statusline (truncated if too long)
        {
          function()
            local blame = git_blame.get_current_blame_text()
            if blame and #blame > 80 then
              return blame:sub(1, 77) .. "..."
            end
            return blame or ""
          end,
          cond = git_blame.is_blame_text_available,
        },
      },
      lualine_x = {
        -- Word count for prose
        { prose.word_count, cond = prose.is_available },
        -- LSP client count
        {
          function()
            local clients = vim.lsp.get_clients({ bufnr = 0 })
            return "LSP:" .. #clients
          end,
          cond = function()
            return #vim.lsp.get_clients({ bufnr = 0 }) > 0
          end,
        },
      },
      lualine_y = {
        -- Show full file path
        { "filename", path = 1 },
      },
    })

    -- Enable global statusline
    opts.options = vim.tbl_deep_extend("force", opts.options or {}, {
      globalstatus = true,
    })

    return opts
  end,
}
