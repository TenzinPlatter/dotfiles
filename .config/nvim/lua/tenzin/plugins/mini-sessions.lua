return {
  "echasnovski/mini.sessions",
  version = "*",
  config = function()
    require("mini.sessions").setup({
      autoread = false,
      autowrite = true,
    })

    -- Replicate persistence.nvim keymaps
    vim.keymap.set("n", "<leader>ql", function()
      local cwd = vim.fn.getcwd()
      local session_name = cwd:gsub("/", "%%")
      local sessions = MiniSessions.detected
      if sessions[session_name] then
        MiniSessions.read(session_name)
      else
        vim.notify("No session for current directory", vim.log.levels.WARN)
      end
    end, { desc = "Load session for current directory" })

    vim.keymap.set("n", "<leader>qS", function()
      local sessions = MiniSessions.detected
      local names = vim.tbl_keys(sessions)
      if #names == 0 then
        vim.notify("No sessions found", vim.log.levels.WARN)
        return
      end
      vim.ui.select(names, { prompt = "Select session:" }, function(choice)
        if choice then
          MiniSessions.read(choice)
        end
      end)
    end, { desc = "Select a session to load" })

    vim.keymap.set("n", "<leader>qL", function()
      local sessions = MiniSessions.detected
      local latest = nil
      local latest_time = 0
      for name, data in pairs(sessions) do
        if data.modify_time > latest_time then
          latest_time = data.modify_time
          latest = name
        end
      end
      if latest then
        MiniSessions.read(latest)
      else
        vim.notify("No sessions found", vim.log.levels.WARN)
      end
    end, { desc = "Load the last session" })

    vim.keymap.set("n", "<leader>qd", function()
      vim.g.minisessions_disable = true
      vim.notify("mini.sessions: autowrite disabled", vim.log.levels.INFO)
    end, { desc = "Stop session saving" })
  end,
}
