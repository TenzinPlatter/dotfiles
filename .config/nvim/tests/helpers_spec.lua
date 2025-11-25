local helpers = require("tenzin.helpers")

describe("insert_async_before_function", function()
  it("inserts async after pub modifier in Rust", function()
    -- Create a buffer with Rust code
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(bufnr, "filetype", "rust")

    -- Check if treesitter parser is available
    local has_parser = pcall(vim.treesitter.get_parser, bufnr, "rust")
    if not has_parser then
      print("WARNING: Rust treesitter parser not available, skipping test")
      pending("Rust treesitter parser not installed")
      return
    end

    -- Set content: "pub fn foo() {}"
    -- Cursor will be positioned as if typing "await" inside the function
    local lines = {
      "pub fn foo() {",
      "    awai",
      "}"
    }
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

    -- Create a window for the buffer
    local win = vim.api.nvim_open_win(bufnr, true, {
      relative = "editor",
      width = 50,
      height = 10,
      row = 1,
      col = 1,
    })

    -- Position cursor at end of "awai"
    -- Line 2 is "    awai" - positions 0-3 are spaces, 4-7 are 'awai'
    -- We want cursor after 'i', which is position 8 (0-indexed)
    -- But we need to trigger from the 't' in "await", so position at 'i' (position 7)
    -- Actually, the function checks the 4 chars BEFORE cursor, so we need cursor at position 8
    -- to get chars at positions 4-7 ("awai")
    -- Setting to position 7 gives us positions 3-6 (" awa")
    -- Wait, sub(col-3, col) with col=7 gives sub(4, 7) which in 1-indexed Lua is chars 4-7
    -- For "    awai" (1-indexed): 1-4 are spaces, 5=a, 6=w, 7=a, 8=i
    -- sub(4, 7) = chars 4-7 = space+a+w+a = " awa"
    -- sub(5, 8) = chars 5-8 = a+w+a+i = "awai" ✓
    -- So we need col=8, and sub(8-3, 8) = sub(5, 8)
    -- But Lua sub is 1-indexed, and nvim col is 0-indexed
    -- Let me just test with the line having "awai" at the end, no leading spaces
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
      "pub fn foo() {",
      "    let x = awai",  -- Changed: "awai" now at end
      "}"
    })
    -- Now cursor should be after 'i' in "awai", which is at position 16 (0-indexed)
    -- "    let x = awai" has 16 characters, cursor at position 16 is after 'i'
    local line2 = vim.api.nvim_buf_get_lines(bufnr, 1, 2, false)[1]
    vim.api.nvim_win_set_cursor(win, { 2, #line2 })  -- Position at end of line

    -- Call the function
    helpers.insert_async_before_function()

    -- Get the modified lines
    local result_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

    -- Expected: "pub async fn foo() {" (async after pub, not before)
    -- The function also inserts 't' at cursor, so line 2 becomes "    let x = await"
    assert.equals("pub async fn foo() {", result_lines[1])
    assert.equals("    let x = await", result_lines[2])

    -- Cleanup
    vim.api.nvim_win_close(win, true)
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)

  it("inserts async after pub(crate) modifier in Rust", function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(bufnr, "filetype", "rust")

    local has_parser = pcall(vim.treesitter.get_parser, bufnr, "rust")
    if not has_parser then
      pending("Rust treesitter parser not installed")
      return
    end

    local lines = {
      "pub(crate) fn foo() {",
      "    let x = awai",
      "}"
    }
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

    local win = vim.api.nvim_open_win(bufnr, true, {
      relative = "editor",
      width = 50,
      height = 10,
      row = 1,
      col = 1,
    })

    local line2 = vim.api.nvim_buf_get_lines(bufnr, 1, 2, false)[1]
    vim.api.nvim_win_set_cursor(win, { 2, #line2 })
    helpers.insert_async_before_function()

    local result_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    assert.equals("pub(crate) async fn foo() {", result_lines[1])

    vim.api.nvim_win_close(win, true)
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)

  it("inserts async after unsafe modifier in Rust", function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(bufnr, "filetype", "rust")

    local has_parser = pcall(vim.treesitter.get_parser, bufnr, "rust")
    if not has_parser then
      pending("Rust treesitter parser not installed")
      return
    end

    local lines = {
      "pub unsafe fn foo() {",
      "    let x = awai",
      "}"
    }
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

    local win = vim.api.nvim_open_win(bufnr, true, {
      relative = "editor",
      width = 50,
      height = 10,
      row = 1,
      col = 1,
    })

    local line2 = vim.api.nvim_buf_get_lines(bufnr, 1, 2, false)[1]
    vim.api.nvim_win_set_cursor(win, { 2, #line2 })
    helpers.insert_async_before_function()

    local result_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    assert.equals("pub unsafe async fn foo() {", result_lines[1])

    vim.api.nvim_win_close(win, true)
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)

  it("does not insert async if already present in Rust", function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(bufnr, "filetype", "rust")

    local lines = {
      "pub async fn foo() {",
      "    let x = awai",
      "}"
    }
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

    local win = vim.api.nvim_open_win(bufnr, true, {
      relative = "editor",
      width = 50,
      height = 10,
      row = 1,
      col = 1,
    })

    local line2 = vim.api.nvim_buf_get_lines(bufnr, 1, 2, false)[1]
    vim.api.nvim_win_set_cursor(win, { 2, #line2 })
    helpers.insert_async_before_function()

    local result_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    -- Should remain unchanged (except for the 't' insertion)
    assert.equals("pub async fn foo() {", result_lines[1])

    vim.api.nvim_win_close(win, true)
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)
end)
