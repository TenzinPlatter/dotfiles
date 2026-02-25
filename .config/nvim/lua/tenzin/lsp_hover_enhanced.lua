local M = {}

-- Flag to track when we've just called hover
local hover_called = false
-- Store source context when hover is called
local hover_source_buf = nil
local hover_source_win = nil

-- Helper function to get LSP clients excluding Copilot
local function get_filtered_clients(bufnr)
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  local filtered = {}
  for _, client in ipairs(clients) do
    if not client.name:lower():find("copilot") then
      table.insert(filtered, client)
    end
  end
  return filtered
end

-- Helper function to query workspace symbols from all LSP clients
local function query_workspace_symbol(clients, symbol)
  local results = {}
  local completed = 0
  local total = #clients

  if total == 0 then
    return results
  end

  for _, client in ipairs(clients) do
    if client.supports_method("workspace/symbol") then
      client.request("workspace/symbol", { query = symbol }, function(err, result)
        if result then
          for _, item in ipairs(result) do
            table.insert(results, item)
          end
        end
        completed = completed + 1
      end)
    else
      completed = completed + 1
    end
  end

  -- Wait for all requests to complete (simple synchronous approach for now)
  vim.wait(1000, function()
    return completed == total
  end)

  return results
end

-- Helper function to convert workspace symbol to location
local function symbol_to_location(symbol)
  return {
    uri = symbol.location.uri,
    range = symbol.location.range,
  }
end

-- Setup buffer-local keymaps for hover window
function M.setup_hover_window_keymaps(bufnr)
  local opts = { buffer = bufnr, silent = true }

  vim.keymap.set("n", "gdd", M.resolve_and_goto_definition, opts)
  vim.keymap.set("n", "K", M.resolve_and_show_hover, opts)
  vim.keymap.set("n", "grr", M.resolve_and_find_references, opts)
  vim.keymap.set("n", "gi", M.resolve_and_goto_implementation, opts)
end

-- Resolve symbol and jump to definition
function M.resolve_and_goto_definition()
  -- Guard: only run in hover windows
  if not vim.b.is_lsp_hover_window then
    return
  end

  -- Extract symbol under cursor
  local symbol = vim.fn.expand("<cword>")
  if symbol == "" then
    return
  end

  -- Get LSP clients from source buffer
  local source_buf = vim.b.hover_source_buf
  if not source_buf then
    return
  end

  local clients = get_filtered_clients(source_buf)

  if #clients == 0 then
    return
  end

  -- Query workspace_symbol
  local results = query_workspace_symbol(clients, symbol)

  -- Handle results
  if #results == 0 then
    return
  elseif #results == 1 then
    local location = symbol_to_location(results[1])
    -- Close hover window and switch back to source window
    local source_win = vim.b.hover_source_win
    vim.api.nvim_win_close(0, true)
    vim.api.nvim_set_current_win(source_win)
    vim.lsp.util.jump_to_location(location, "utf-8")
  else
    -- Use Snacks picker for multiple results
    local items = {}
    for _, item in ipairs(results) do
      table.insert(items, item)
    end
    local source_win = vim.b.hover_source_win
    require("snacks").picker.pick({
      items = items,
      format = function(item)
        return item.name .. " - " .. vim.uri_to_fname(item.location.uri)
      end,
      confirm = function(item)
        local location = symbol_to_location(item)
        -- Close hover window and switch back to source window
        vim.api.nvim_win_close(0, true)
        vim.api.nvim_set_current_win(source_win)
        vim.lsp.util.jump_to_location(location, "utf-8")
      end,
    })
  end
end

-- Resolve symbol and show hover
function M.resolve_and_show_hover()
  -- Guard: only run in hover windows
  if not vim.b.is_lsp_hover_window then
    return
  end

  -- Extract symbol under cursor
  local symbol = vim.fn.expand("<cword>")
  if symbol == "" then
    vim.notify("No symbol under cursor", vim.log.levels.WARN)
    return
  end

  -- Get LSP clients from source buffer
  local source_buf = vim.b.hover_source_buf
  local clients = get_filtered_clients(source_buf)

  if #clients == 0 then
    vim.notify("No LSP client attached to source buffer", vim.log.levels.WARN)
    return
  end

  -- Query workspace_symbol
  local results = query_workspace_symbol(clients, symbol)

  -- Handle results
  if #results == 0 then
    vim.notify("Symbol '" .. symbol .. "' not found", vim.log.levels.INFO)
  elseif #results == 1 then
    local location = symbol_to_location(results[1])
    -- Close current hover window and switch back to source window
    local source_win = vim.b.hover_source_win
    vim.api.nvim_win_close(0, true)
    vim.api.nvim_set_current_win(source_win)
    -- Jump to location and show hover
    vim.lsp.util.jump_to_location(location, "utf-8")
    M.hover()
  else
    -- Use Snacks picker for multiple results
    local items = {}
    for _, item in ipairs(results) do
      table.insert(items, item)
    end
    local source_win = vim.b.hover_source_win
    require("snacks").picker.pick({
      items = items,
      format = function(item)
        return item.name .. " - " .. vim.uri_to_fname(item.location.uri)
      end,
      confirm = function(item)
        local location = symbol_to_location(item)
        -- Close current hover window and switch back to source window
        vim.api.nvim_win_close(0, true)
        vim.api.nvim_set_current_win(source_win)
        -- Jump to location and show hover
        vim.lsp.util.jump_to_location(location, "utf-8")
        M.hover()
      end,
    })
  end
end

-- Resolve symbol and find references
function M.resolve_and_find_references()
  -- Guard: only run in hover windows
  if not vim.b.is_lsp_hover_window then
    return
  end

  -- Extract symbol under cursor
  local symbol = vim.fn.expand("<cword>")
  if symbol == "" then
    vim.notify("No symbol under cursor", vim.log.levels.WARN)
    return
  end

  -- Get LSP clients from source buffer
  local source_buf = vim.b.hover_source_buf
  local clients = get_filtered_clients(source_buf)

  if #clients == 0 then
    vim.notify("No LSP client attached to source buffer", vim.log.levels.WARN)
    return
  end

  -- Query workspace_symbol
  local results = query_workspace_symbol(clients, symbol)

  -- Handle results
  if #results == 0 then
    vim.notify("Symbol '" .. symbol .. "' not found", vim.log.levels.INFO)
  elseif #results == 1 then
    local location = symbol_to_location(results[1])
    -- Close hover window and switch back to source window
    local source_win = vim.b.hover_source_win
    vim.api.nvim_win_close(0, true)
    vim.api.nvim_set_current_win(source_win)
    -- Jump to location to get references
    vim.lsp.util.jump_to_location(location, "utf-8")
    require("snacks").picker.lsp_references()
  else
    -- Use Snacks picker for multiple results
    local items = {}
    for _, item in ipairs(results) do
      table.insert(items, item)
    end
    local source_win = vim.b.hover_source_win
    require("snacks").picker.pick({
      items = items,
      format = function(item)
        return item.name .. " - " .. vim.uri_to_fname(item.location.uri)
      end,
      confirm = function(item)
        local location = symbol_to_location(item)
        -- Close hover window and switch back to source window
        vim.api.nvim_win_close(0, true)
        vim.api.nvim_set_current_win(source_win)
        vim.lsp.util.jump_to_location(location, "utf-8")
        require("snacks").picker.lsp_references()
      end,
    })
  end
end

-- Resolve symbol and goto implementation
function M.resolve_and_goto_implementation()
  -- Guard: only run in hover windows
  if not vim.b.is_lsp_hover_window then
    return
  end

  -- Extract symbol under cursor
  local symbol = vim.fn.expand("<cword>")
  if symbol == "" then
    vim.notify("No symbol under cursor", vim.log.levels.WARN)
    return
  end

  -- Get LSP clients from source buffer
  local source_buf = vim.b.hover_source_buf
  local clients = get_filtered_clients(source_buf)

  if #clients == 0 then
    vim.notify("No LSP client attached to source buffer", vim.log.levels.WARN)
    return
  end

  -- Query workspace_symbol
  local results = query_workspace_symbol(clients, symbol)

  -- Handle results
  if #results == 0 then
    vim.notify("Symbol '" .. symbol .. "' not found", vim.log.levels.INFO)
  elseif #results == 1 then
    local location = symbol_to_location(results[1])
    -- Close hover window and switch back to source window
    local source_win = vim.b.hover_source_win
    vim.api.nvim_win_close(0, true)
    vim.api.nvim_set_current_win(source_win)
    -- Jump to location to get implementations
    vim.lsp.util.jump_to_location(location, "utf-8")
    require("snacks").picker.lsp_implementations()
  else
    -- Use Snacks picker for multiple results
    local items = {}
    for _, item in ipairs(results) do
      table.insert(items, item)
    end
    local source_win = vim.b.hover_source_win
    require("snacks").picker.pick({
      items = items,
      format = function(item)
        return item.name .. " - " .. vim.uri_to_fname(item.location.uri)
      end,
      confirm = function(item)
        local location = symbol_to_location(item)
        -- Close hover window and switch back to source window
        vim.api.nvim_win_close(0, true)
        vim.api.nvim_set_current_win(source_win)
        vim.lsp.util.jump_to_location(location, "utf-8")
        require("snacks").picker.lsp_implementations()
      end,
    })
  end
end

-- Wrapped hover function
function M.hover()
  -- Capture source context BEFORE calling hover
  hover_source_buf = vim.api.nvim_get_current_buf()
  hover_source_win = vim.api.nvim_get_current_win()

  -- Set flag to indicate we just called hover
  hover_called = true

  -- Schedule to reset flag after a short delay
  vim.defer_fn(function()
    hover_called = false
    hover_source_buf = nil
    hover_source_win = nil
  end, 200)

  -- Call original hover
  vim.lsp.buf.hover()
end

-- Autocmd to detect and setup hover windows
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(args)
    local bufnr = args.buf
    local winid = vim.fn.bufwinid(bufnr)

    -- Check if this is a floating window
    if winid == -1 then
      return
    end

    local win_config = vim.api.nvim_win_get_config(winid)
    if win_config.relative == "" then
      -- Not a floating window
      return
    end

    -- Check if hover was just called
    if not hover_called then
      return
    end

    -- This is likely our hover window
    -- Store metadata using captured source context
    vim.b[bufnr].is_lsp_hover_window = true
    vim.b[bufnr].hover_source_buf = hover_source_buf
    vim.b[bufnr].hover_source_win = hover_source_win

    -- Setup keymaps
    M.setup_hover_window_keymaps(bufnr)
  end,
})

return M
