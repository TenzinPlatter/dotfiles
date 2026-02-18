-- Helper functions for code-diff
local function walk_in_codediff(picker, item)
  local Snacks = require("snacks")
  picker:close()
  if item.commit then
    local current_commit = item.commit

    vim.fn.setreg("+", current_commit)
    vim.notify("Copied: " .. current_commit)

    -- Get parent / previous commit
    local parent_commit = vim.trim(vim.fn.system("git rev-parse --short " .. current_commit .. "^"))
    parent_commit = parent_commit:match("[a-f0-9]+")

    if vim.v.shell_error ~= 0 then
      vim.notify("Cannot find parent (Root commit?)", vim.log.levels.WARN)
      parent_commit = ""
    end

    local cmd = string.format("CodeDiff %s %s", parent_commit, current_commit)
    vim.notify("Diffing: " .. parent_commit .. " -> " .. current_commit)
    vim.cmd(cmd)
  end
end

local function git_pickaxe(opts, query)
  local Snacks = require("snacks")
  opts = opts or {}
  local is_global = opts.global or false
  local current_file = vim.api.nvim_buf_get_name(0)

  if not is_global and (current_file == "" or current_file == nil) then
    vim.notify("Buffer is not a file, switching to global search", vim.log.levels.WARN)
    is_global = true
  end

  local title_scope = is_global and "Global" or vim.fn.fnamemodify(current_file, ":t")

  local function execute_search(search_query)
    if not search_query or search_query == "" then
      return
    end

    vim.fn.setreg("/", search_query)
    local old_hl = vim.opt.hlsearch
    vim.opt.hlsearch = true

    local args = {
      "log",
      "-G" .. search_query,
      "-i",
      "--pretty=format:%C(yellow)%h%Creset %s %C(green)(%cr)%Creset %C(blue)<%an>%Creset",
      "--abbrev-commit",
      "--date=short",
    }

    if not is_global then
      table.insert(args, "--")
      table.insert(args, current_file)
    end

    Snacks.picker({
      title = 'Git Log: "' .. search_query .. '" (' .. title_scope .. ")",
      finder = "proc",
      cmd = "git",
      args = args,
      transform = function(item)
        local clean_text = item.text:gsub("\27%[[0-9;]*m", "")
        local hash = clean_text:match("^%S+")
        if hash then
          item.commit = hash
          if not is_global then
            item.file = current_file
          end
        end
        return item
      end,
      preview = "git_show",
      confirm = walk_in_codediff,
      format = "text",
      on_close = function()
        vim.opt.hlsearch = old_hl
        vim.cmd("noh")
      end,
    })
  end

  if query then
    execute_search(query)
  else
    vim.ui.input({ prompt = "Git Search (-G) in " .. title_scope .. ": " }, execute_search)
  end
end

return {
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    opts = {},
    keys = {
      {
        "<leader>gb",
        function() require("gitsigns").blame_line({ full = true }) end,
        desc = "Git blame line (popup)",
      },
    },
  },
  {
    "f-person/git-blame.nvim",
    event = "VeryLazy",
    init = function()
      -- Disable virtual text display (we'll show in lualine instead)
      vim.g.gitblame_display_virtual_text = 0
    end,
    opts = {
      enabled = true,
      message_template = " <summary> • <date> • <author> • <<sha>>",
      date_format = "%m-%d-%Y %H:%M:%S",
      virtual_text_column = 1,
    },
  },
  {
    "esmuellert/codediff.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      explorer = {
        view_mode = "tree",
      },
    },
    keys = {
      { "<leader>cd", ":CodeDiff", desc = "Open prompt for VSCode-diff view" },
      { "<leader>cdm", function() vim.cmd("CodeDiff main") end, desc = "Code diff against main" },
      { "<leader>cdf", ":CodeDiff file", desc = "Code diff for file" },
      { "<leader>cdd", function() vim.cmd("CodeDiff") end, desc = "Open code diff" },
      {
        "<leader>gp",
        function()
          vim.cmd('normal! "vy')
          local selection = vim.fn.getreg("v")
          git_pickaxe({ global = false }, selection)
        end,
        desc = "Git Search (Buffer)",
        mode = { "v" },
      },
      {
        "<leader>gP",
        function()
          vim.cmd('normal! "vy')
          local selection = vim.fn.getreg("v")
          git_pickaxe({ global = true }, selection)
        end,
        desc = "Git Search (Global)",
        mode = { "v" },
      },
      {
        "<leader>gp",
        function()
          git_pickaxe({ global = false })
        end,
        desc = "Git Search (Buffer)",
      },
      {
        "<leader>gP",
        function()
          git_pickaxe({ global = true })
        end,
        desc = "Git Search (Global)",
      },
      {
        "<leader>gl",
        function()
          local Snacks = require("snacks")
          Snacks.picker.git_log_file({
            confirm = walk_in_codediff,
          })
        end,
        desc = "Git log file",
      },
      {
        "<leader>gL",
        function()
          local Snacks = require("snacks")
          Snacks.picker.git_log({
            confirm = walk_in_codediff,
          })
        end,
        desc = "Git log",
      },
    },
  },
}
