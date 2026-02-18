local M = {}

function M.show_hover_in_function_params()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local line = cursor_pos[1] - 1
  local col = cursor_pos[2]

  local line_text = vim.api.nvim_buf_get_lines(0, line, line + 1, false)[1]
  if not line_text then
    return
  end

  local function_start = nil
  local paren_count = 0
  local in_params = false

  for i = col, 1, -1 do
    local char = line_text:sub(i, i)
    if char == ")" then
      paren_count = paren_count + 1
    elseif char == "(" then
      if paren_count == 0 then
        function_start = i - 1
        in_params = true
        break
      else
        paren_count = paren_count - 1
      end
    end
  end

  if in_params and function_start then
    local function_name_end = function_start
    while function_name_end > 0 do
      local char = line_text:sub(function_name_end, function_name_end)
      if char:match("[%w_]") then
        function_name_end = function_name_end - 1
      else
        break
      end
    end

    if function_name_end < function_start then
      vim.api.nvim_win_set_cursor(0, { line + 1, function_name_end })
      vim.lsp.buf.hover()
      vim.api.nvim_win_set_cursor(0, cursor_pos)
    end
  end
end

-- Only show cursorline in the active window
vim.api.nvim_create_augroup("CursorLineOnlyInActiveWindow", { clear = true })
vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter", "BufWinEnter" }, {
  group = "CursorLineOnlyInActiveWindow",
  callback = function()
    vim.opt_local.cursorline = true
  end,
})
vim.api.nvim_create_autocmd("WinLeave", {
  group = "CursorLineOnlyInActiveWindow",
  callback = function()
    vim.opt_local.cursorline = false
  end,
})

function M.insert_self()
  local filetype = vim.bo.filetype
  local self_ref = ""

  if filetype == "cpp" or filetype == "c" then
    self_ref = "this->"
  elseif filetype == "python" then
    self_ref = "self."
  elseif filetype == "javascript" or filetype == "typescript" or filetype == "javascriptreact" or filetype == "typescriptreact" then
    self_ref = "this."
  elseif filetype == "java" or filetype == "kotlin" then
    self_ref = "this."
  elseif filetype == "csharp" then
    self_ref = "this."
  elseif filetype == "rust" then
    self_ref = "self."
  elseif filetype == "go" then
    self_ref = "self."
  elseif filetype == "ruby" then
    self_ref = "self."
  elseif filetype == "php" then
    self_ref = "$this->"
  elseif filetype == "swift" then
    self_ref = "self."
  elseif filetype == "lua" then
    self_ref = "self."
  else
    self_ref = "self."
  end

  vim.api.nvim_put({self_ref}, "c", false, true)
end

function M.insert_async_before_function()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local row = cursor_pos[1] - 1
  local col = cursor_pos[2]

  -- Get the 4 characters before the cursor
  local line_text = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1]
  -- Note: col is 0-indexed from nvim API, but Lua string.sub is 1-indexed
  -- To get 4 chars ending at cursor position, we need: sub(col-2, col+1)
  local before_cursor = line_text:sub(math.max(1, col - 2), col + 1)

  -- Check if the 4 characters before cursor are 'awai'
  if before_cursor == "awai" then
    local parser = vim.treesitter.get_parser(bufnr)
    if parser then
      local tree = parser:parse()[1]
      if tree then
        local root = tree:root()
        local current_node = root:named_descendant_for_range(row, col, row, col)

        if current_node then
          -- Function node types for different languages
          local function_node_types = {
            "function_declaration",
            "function_definition",
            "function",
            "arrow_function",
            "method_declaration",
            "method_definition",
            "function_item",
            "lambda",
          }

          -- Traverse up the tree to find a function node
          local function_node = current_node
          while function_node do
            local node_type = function_node:type()
            local is_function = false
            for _, ft in ipairs(function_node_types) do
              if node_type == ft then
                is_function = true
                break
              end
            end
            if is_function then
              break
            end
            function_node = function_node:parent()
          end

          if function_node then
            -- Get the start position of the function node
            local start_row, start_col = function_node:start()

            -- For most languages, we need to find the 'function' keyword or the start of the declaration
            -- We'll insert 'async ' at the start of the function node
            local func_line_text = vim.api.nvim_buf_get_lines(bufnr, start_row, start_row + 1, false)[1]

            -- Find the position to insert 'async'
            -- Check if 'async' already exists
            if not (func_line_text:match("^%s*async%s") or func_line_text:match("^%s*export%s+async%s") or func_line_text:match("%s+async%s+fn%s")) then
              -- Determine insertion position
              local insert_col = start_col
              local prefix = func_line_text:sub(1, start_col)

              -- Get filetype to handle language-specific modifiers
              local filetype = vim.bo[bufnr].filetype

              if filetype == "rust" then
                -- For Rust, insert after visibility and safety modifiers
                -- Order: pub(...)? unsafe? const? extern? async fn
                -- Match patterns for Rust modifiers before 'fn'
                local rust_modifier_match = func_line_text:match("^(%s*pub%s*%([^)]+%)%s+unsafe%s+)")
                  or func_line_text:match("^(%s*pub%s*%([^)]+%)%s+const%s+)")
                  or func_line_text:match("^(%s*pub%s*%([^)]+%)%s+)")
                  or func_line_text:match("^(%s*pub%s+unsafe%s+)")
                  or func_line_text:match("^(%s*pub%s+const%s+)")
                  or func_line_text:match("^(%s*pub%s+)")
                  or func_line_text:match("^(%s*unsafe%s+)")
                  or func_line_text:match("^(%s*const%s+)")

                if rust_modifier_match then
                  insert_col = #rust_modifier_match
                end
              else
                -- Handle 'export' keyword for JS/TS
                local export_match = prefix:match("^(%s*export%s+)")
                if export_match then
                  insert_col = #export_match
                end
              end

              -- Insert 'async '
              vim.api.nvim_buf_set_text(bufnr, start_row, insert_col, start_row, insert_col, {"async "})
            end
          end
        end
      end
    end
  end

  -- Always insert 't' at cursor position
  vim.api.nvim_put({"t"}, "c", false, true)
end

-- Split a different window and show current buffer in the new split
function M.split_window_with_current_buffer(direction, vertical)
  local current_win = vim.api.nvim_get_current_win()
  local current_buf = vim.api.nvim_get_current_buf()

  -- Try to move to the target window
  vim.cmd('wincmd ' .. direction)
  local target_win = vim.api.nvim_get_current_win()

  -- Check if we actually moved to a different window
  if target_win == current_win then
    print("No window in that direction")
    return
  end

  -- Split the target window
  if vertical then
    vim.cmd('vsplit')
  else
    vim.cmd('split')
  end

  -- Set the new split to show the original buffer
  vim.api.nvim_win_set_buf(0, current_buf)

  -- Return to original window
  vim.api.nvim_set_current_win(current_win)
end

-- Go to definition in a split of a different window
function M.goto_definition_in_split(direction, vertical)
  local current_win = vim.api.nvim_get_current_win()
  local current_buf = vim.api.nvim_get_current_buf()

  -- Try to move to the target window
  vim.cmd('wincmd ' .. direction)
  local target_win = vim.api.nvim_get_current_win()

  -- Check if we actually moved to a different window
  if target_win == current_win then
    print("No window in that direction")
    return
  end

  -- Split the target window
  if vertical then
    vim.cmd('vsplit')
  else
    vim.cmd('split')
  end

  -- Set the new split to show the original buffer
  vim.api.nvim_win_set_buf(0, current_buf)

  -- Go to definition in the new split
  vim.lsp.buf.definition()
end

-- Inlay hint preferences persistence
function M.load_inlay_hint_preferences()
  local data_path = vim.fn.stdpath('data') .. '/inlay-hints.json'
  local file = io.open(data_path, 'r')

  if not file then
    return {}
  end

  local content = file:read('*all')
  file:close()

  local ok, decoded = pcall(vim.fn.json_decode, content)
  if ok and type(decoded) == 'table' then
    return decoded
  end

  return {}
end

function M.save_inlay_hint_preference(filetype, enabled)
  local data_path = vim.fn.stdpath('data') .. '/inlay-hints.json'
  local preferences = M.load_inlay_hint_preferences()

  preferences[filetype] = enabled

  -- Ensure directory exists
  local data_dir = vim.fn.stdpath('data')
  vim.fn.mkdir(data_dir, 'p')

  local ok, encoded = pcall(vim.fn.json_encode, preferences)
  if not ok then
    vim.notify('Failed to encode inlay hint preferences', vim.log.levels.ERROR)
    return
  end

  local file = io.open(data_path, 'w')
  if not file then
    vim.notify('Failed to save inlay hint preferences', vim.log.levels.ERROR)
    return
  end

  file:write(encoded)
  file:close()
end

function M.get_inlay_hint_preference(filetype)
  local preferences = M.load_inlay_hint_preferences()
  return preferences[filetype]
end

function M.harpoon_tabline()
  local harpoon = require("harpoon")
  local list = harpoon:list()
  local current = vim.api.nvim_buf_get_name(0)
  local parts = {}

  for i = 1, list:length() do
    local item = list:get(i)
    if item then
      local name = vim.fn.fnamemodify(item.value, ":t")
      local is_active = current == vim.fn.fnamemodify(item.value, ":p")
      if is_active then
        table.insert(parts, "%#TabLineSel# " .. i .. " " .. name .. " %#TabLine#")
      else
        table.insert(parts, "%#TabLine# " .. i .. " " .. name .. " ")
      end
    end
  end

  if #parts == 0 then
    return "%#TabLine# harpoon: <leader>a to add %#TabLineFill#"
  end
  return table.concat(parts, "│") .. "%#TabLineFill#"
end

function M.in_codediff()
  local codediff_lifecycle = require("codediff.ui.lifecycle")
  local current_tab = vim.api.nvim_get_current_tabpage()
  return codediff_lifecycle.get_session(current_tab)
end

return M
