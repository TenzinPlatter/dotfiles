return {
  -- git-blame data source for statusline
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

  -- All mini.nvim modules
  {
    "echasnovski/mini.nvim",
    version = false,
    dependencies = { "f-person/git-blame.nvim", "skwee357/nvim-prose" },
    config = function()
      -- Basics (sets common options, j/k display-line motion, yank highlight, etc.)
      require("mini.basics").setup({
        options = { win_borders = "single" },
        mappings = { basic = true, option_toggle_prefix = [[\]] },
        autocommands = { basic = true },
      })
      -- mini.basics sets wrap=false; override to keep wrapping on
      vim.opt.wrap = true

      -- Cursorword
      require("mini.cursorword").setup()
      local function set_cursorword_hl()
        vim.api.nvim_set_hl(0, "MiniCursorword", { bg = "#3d3d3d", underline = false })
        vim.api.nvim_set_hl(0, "MiniCursorwordCurrent", { bg = "#3d3d3d", underline = false })
      end
      set_cursorword_hl()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = set_cursorword_hl })

      -- Surround (replaces nvim-surround): sa/sd/sr/sf/sh
      require("mini.surround").setup()

      -- Pairs (replaces nvim-autopairs)
      require("mini.pairs").setup()

      -- Comment (replaces vim-commentary + ts-comments.nvim): gcc/gc
      require("mini.comment").setup()

      -- Notify (replaces nvim-notify)
      local notify = require("mini.notify")
      notify.setup()
      vim.notify = notify.make_notify()


      -- Sessions (replaces persistence.nvim)
      require("mini.sessions").setup({
        autoread = false,
        autowrite = true,
      })

      vim.keymap.set("n", "<leader>ql", function()
        MiniSessions.read()
      end, { desc = "Load session for current directory" })

      vim.keymap.set("n", "<leader>qS", function()
        local names = vim.tbl_keys(MiniSessions.detected)
        if #names == 0 then
          vim.notify("No sessions found", vim.log.levels.WARN)
          return
        end
        vim.ui.select(names, { prompt = "Select session:" }, function(choice)
          if choice then MiniSessions.read(choice) end
        end)
      end, { desc = "Select a session to load" })

      vim.keymap.set("n", "<leader>qL", function()
        local latest, latest_time = nil, 0
        for name, data in pairs(MiniSessions.detected) do
          if data.modify_time > latest_time then
            latest_time = data.modify_time
            latest = name
          end
        end
        if latest then MiniSessions.read(latest)
        else vim.notify("No sessions found", vim.log.levels.WARN) end
      end, { desc = "Load the last session" })

      vim.keymap.set("n", "<leader>qd", function()
        vim.g.minisessions_disable = true
        vim.notify("mini.sessions: autowrite disabled", vim.log.levels.INFO)
      end, { desc = "Stop session saving" })

      -- Diff (replaces gitsigns.nvim)
      require("mini.diff").setup({
        view = {
          style = "sign",
          signs = { add = "▎", change = "▎", delete = "" },
        },
      })

      vim.keymap.set("n", "]c", function()
        if vim.wo.diff then vim.cmd.normal({ "]c", bang = true })
        else MiniDiff.goto_hunk("next") end
      end, { desc = "Next hunk" })

      vim.keymap.set("n", "[c", function()
        if vim.wo.diff then vim.cmd.normal({ "[c", bang = true })
        else MiniDiff.goto_hunk("prev") end
      end, { desc = "Prev hunk" })

      -- Git (branch tracking, history)
      require("mini.git").setup()

      -- Hipatterns (replaces nvim-colorizer + todo-comments)
      local hipatterns = require("mini.hipatterns")
      hipatterns.setup({
        highlighters = {
          hex_color = hipatterns.gen_highlighter.hex_color(),
          fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
          hack  = { pattern = "%f[%w]()HACK()%f[%W]",  group = "MiniHipatternsHack" },
          todo  = { pattern = "%f[%w]()TODO()%f[%W]",  group = "MiniHipatternsTodo" },
          note  = { pattern = "%f[%w]()NOTE()%f[%W]",  group = "MiniHipatternsNote" },
        },
      })
      vim.api.nvim_set_hl(0, "MiniHipatternsFixme", { fg = "#f38ba8", bold = true })
      vim.api.nvim_set_hl(0, "MiniHipatternsHack",  { fg = "#fab387", bold = true })
      vim.api.nvim_set_hl(0, "MiniHipatternsTodo",  { fg = "#89b4fa", bold = true })
      vim.api.nvim_set_hl(0, "MiniHipatternsNote",  { fg = "#a6e3a1", bold = true })

      -- Statusline (replaces lualine)
      local prose = require("nvim-prose")
      local git_blame = require("gitblame")
      vim.g.gitblame_display_virtual_text = 0

      local statusline = require("mini.statusline")
      statusline.setup({
        content = {
          active = function()
            local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })

            local rec = ""
            local reg = vim.fn.reg_recording()
            if reg ~= "" then rec = "REC @" .. reg end

            local blame = ""
            if git_blame.is_blame_text_available() then
              blame = git_blame.get_current_blame_text()
            end

            local words = ""
            if prose.is_available() then words = prose.word_count() end

            local lsp = ""
            local clients = vim.lsp.get_clients({ bufnr = 0 })
            if #clients > 0 then lsp = "LSP:" .. #clients end

            local filename = ""
            local bufname = vim.api.nvim_buf_get_name(0)
            if bufname ~= "" then
              local root = vim.fs.root(0, { ".git", ".hg", ".svn" }) or vim.fn.getcwd()
              local rel = vim.fn.fnamemodify(bufname, ":~:.")
              local from_root = bufname:sub(#root + 2)
              if from_root ~= "" then rel = from_root end
              if vim.bo.modified then rel = rel .. " [+]" end
              if vim.bo.readonly then rel = rel .. " [-]" end
              filename = rel
            end

            return statusline.combine_groups({
              { hl = mode_hl,                  strings = { mode, rec } },
              { hl = "MiniStatuslineDevinfo",  strings = {} },
              "%<",
              { hl = "MiniStatuslineFilename", strings = { blame } },
              "%=",
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
