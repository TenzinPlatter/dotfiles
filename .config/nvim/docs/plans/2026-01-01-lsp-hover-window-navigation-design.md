# LSP Features in Hover Windows

**Date:** 2026-01-01
**Status:** Approved

## Problem

When viewing LSP hover documentation in Neovim, the hover window displays markdown containing type information, function signatures, and other symbols. Currently, there's no way to interact with these symbols - you can't jump to their definitions, view their hover info, or perform other LSP operations on them.

For example, when hovering over a Rust variable with an inferred type like `Result<Vec<MyCustomType>, Error>`, you can see the type in the hover window but can't navigate to `MyCustomType`'s definition without closing the hover and manually searching for it.

## Solution

Enable LSP features (goto definition, references, etc.) from within hover windows by:
1. Wrapping the hover function to track source context
2. Setting up buffer-local keymaps in hover windows
3. Using workspace symbol search to resolve symbols from the hover text
4. Presenting results using existing Snacks picker integration

## User Workflow

**Opening hover (press `K`):**
- Neovim shows hover documentation in a floating markdown window
- Metadata about the source buffer is attached to the float
- Buffer-local LSP keymaps are configured

**Inside the hover window:**
- Position cursor on any symbol (type name, function name, etc.)
- Press normal LSP keybindings:
  - `gdd` - Jump to definition
  - `K` - Show nested hover
  - `grr` - Find references
  - `gi` - Goto implementation
- Symbol is resolved via workspace symbol search
- Results handled appropriately (jump, picker, or "not found")

## Architecture

### Component 1: Wrapped Hover Function

**Module:** `lua/tenzin/lsp_hover_enhanced.lua`

Wraps `vim.lsp.buf.hover()` to:
- Call the original hover function
- Use autocmd on `FileType markdown` to detect the float window
- Store metadata as buffer variables:
  - `b:hover_source_buf` - Original buffer number
  - `b:hover_source_win` - Original window ID
  - `b:is_lsp_hover_window` - Flag for identification
- Set up buffer-local keymaps via `setup_hover_window_keymaps()`

**Detection Strategy:**
- Autocmd triggers on `FileType markdown`
- Check if window is floating: `vim.api.nvim_win_get_config(winid).relative ~= ''`
- Use timing flag to identify recently created floats
- This reliably identifies hover windows without false positives

### Component 2: Symbol Resolver

**Core Function Pattern:**
```lua
function resolve_and_<action>()
  -- Guard: only run in hover windows
  if not vim.b.is_lsp_hover_window then return end

  -- Extract symbol under cursor
  local symbol = vim.fn.expand('<cword>')
  if symbol == '' then
    vim.notify("No symbol under cursor")
    return
  end

  -- Get LSP clients from source buffer
  local source_buf = vim.b.hover_source_buf
  local clients = vim.lsp.get_clients({bufnr = source_buf})

  -- Query workspace_symbol on each client
  local results = query_workspace_symbol(clients, symbol)

  -- Handle results
  if #results == 0 then
    vim.notify("Symbol '" .. symbol .. "' not found")
  elseif #results == 1 then
    perform_<action>(results[1])
  else
    show_picker_for_<action>(results)
  end
end
```

**Symbol Extraction:**
- Use `vim.fn.expand('<cword>')` to get identifier under cursor
- Extracts alphanumeric + underscore sequences
- Works in markdown without special parsing

**Workspace Symbol Query:**
- Use `vim.lsp.buf.workspace_symbol(symbol)`
- Searches across entire project
- No position/context required (unlike textDocument/definition)
- Returns all matching symbols from all files

### Component 3: Result Handlers

**0 Results:**
- `vim.notify("Symbol '" .. symbol .. "' not found")`
- User stays in hover window

**1 Result:**
- Jump directly using `vim.lsp.util.jump_to_location()`
- Closes hover window automatically
- Opens file at definition location

**Multiple Results:**
- Use `Snacks.picker` with LSP locations
- User selects which match to jump to
- Integrates with existing picker workflow

### Component 4: Buffer-Local Keymaps

Set up in hover windows only:
```lua
function setup_hover_window_keymaps(bufnr)
  local opts = { buffer = bufnr, silent = true }

  vim.keymap.set('n', 'gdd', resolve_and_goto_definition, opts)
  vim.keymap.set('n', 'K', resolve_and_show_hover, opts)
  vim.keymap.set('n', 'grr', resolve_and_find_references, opts)
  vim.keymap.set('n', 'gi', resolve_and_goto_implementation, opts)
end
```

Buffer-local keymaps override global ones only in the hover window.

## Integration

### Modified Files

**`lua/tenzin/plugins/lsp.lua` - Line 7:**
```lua
-- Before:
{ "K", vim.lsp.buf.hover, desc = "Show hover documentation" }

-- After:
{ "K", function() require('tenzin.lsp_hover_enhanced').hover() end, desc = "Show hover documentation" }
```

### New Files

**`lua/tenzin/lsp_hover_enhanced.lua`:**
- `hover()` - Wrapped hover function
- `resolve_and_goto_definition()` - Workspace symbol → jump to definition
- `resolve_and_show_hover()` - Workspace symbol → nested hover
- `resolve_and_find_references()` - Workspace symbol → find references
- `resolve_and_goto_implementation()` - Workspace symbol → implementations
- `setup_hover_window_keymaps()` - Configure buffer-local maps
- Helper functions for querying and result handling

## Edge Cases

### Handled

1. **No LSP client on source buffer**
   - Check `vim.lsp.get_clients()` result
   - Notify if empty

2. **Hover window closed**
   - Buffer-local keymaps auto-cleanup
   - No memory leaks

3. **Symbol not found**
   - Clear notification
   - Stay in hover window

4. **Multiple LSP clients**
   - Query all clients
   - Merge and deduplicate results

5. **Non-hover markdown buffers**
   - Won't have `b:is_lsp_hover_window` flag
   - Keymaps won't activate

6. **Cursor on whitespace/punctuation**
   - `<cword>` returns empty string
   - Notify "No symbol under cursor"

### Known Limitations

1. **Standard library symbols**
   - `Vec`, `Option`, etc. won't be found in workspace
   - Will show "not found" notification
   - Acceptable - user knows these are external

2. **Complex type expressions**
   - `<cword>` extracts single identifier only
   - From `Result<MyType, Error>`, extracts just the word under cursor
   - User positions cursor on specific type they want

3. **Requires workspace symbol support**
   - LSP server must implement workspace/symbol
   - Most modern servers (rust-analyzer, typescript-language-server, etc.) support this
   - Falls back gracefully with "not found" if unsupported

## Testing Strategy

### Manual Testing Flow

1. Open a Rust file with type inference
2. Hover over a variable (press `K`)
3. Position cursor on type name in hover window
4. Press `gdd` - should find and jump to definition
5. Press `K` on another symbol - should show nested hover
6. Test with stdlib types - should show "not found"
7. Test with symbols having multiple definitions - should open picker

### Edge Case Verification

- Test with no LSP attached (plain markdown file)
- Test with cursor on whitespace
- Test with multiple LSP clients active
- Test closing hover window before action completes

## Future Enhancements

*Not included in initial implementation:*

- Support for additional LSP actions (type definition, call hierarchy)
- Fallback to `<cWORD>` if `<cword>` fails to find matches
- Cache workspace_symbol results for common stdlib types
- Visual mode support to manually select symbol text
- Configuration options for which keymaps to enable

## Implementation Checklist

- [ ] Create `lua/tenzin/lsp_hover_enhanced.lua` module
- [ ] Implement wrapped hover function with autocmd detection
- [ ] Implement workspace_symbol query helper
- [ ] Implement result handlers (0, 1, multiple results)
- [ ] Implement resolve_and_goto_definition
- [ ] Implement resolve_and_show_hover
- [ ] Implement resolve_and_find_references
- [ ] Implement resolve_and_goto_implementation
- [ ] Implement setup_hover_window_keymaps
- [ ] Update `lua/tenzin/plugins/lsp.lua` keymap
- [ ] Test with Rust project
- [ ] Test edge cases
- [ ] Verify no impact on non-hover buffers
