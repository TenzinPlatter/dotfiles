# WezTerm Native Flow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a native WezTerm config that reproduces the kitty-native-flow workflow (direct `ctrl+shift+…` chords, Alt+hjkl nvim-aware nav, splits/tabs/workspaces, zoxide project picker, Catppuccin Mocha) with no tmux and no persistence.

**Architecture:** A modular Lua config at `.config/wezterm/`. `wezterm.lua` builds a config table and hands it to per-concern modules (`appearance`, `behavior`, `plugins`, `keys`, `machine`) each exposing `apply(config)`. Three plugins cover the hard parts: smart-splits.nvim (nav), smart_workspace_switcher (picker→workspace), tabline.wez (status bar). `machine.lua` is gitignored for per-host overrides.

**Tech Stack:** WezTerm 20240203 (Lua config), `wezterm.plugin` system, zoxide + fd (already installed), GNU stow for symlinking.

---

## Notes for the implementer

- **No unit-test framework applies.** "Tests" here = WezTerm parsing the config without error and reporting the expected keys/settings. The canonical check is:
  ```bash
  wezterm --config-file /home/tenzin/.dotfiles/.config/wezterm/wezterm.lua show-keys >/dev/null && echo "CONFIG OK"
  ```
  This loads the full config (including fetching any plugins) and exits non-zero on any Lua error.
- **Commits:** short one-line semantic messages, **no** `Co-Authored-By` lines (per user CLAUDE.md).
- WezTerm auto-prepends the config directory to Lua's `package.path`, so `require("lua.appearance")` resolves to `.config/wezterm/lua/appearance.lua`.
- Work happens in the repo at `/home/tenzin/.dotfiles/.config/wezterm/`. The symlink into `~/.config/wezterm` is the final task.
- Plugin fetches require network access on first load.

---

## File Structure

```
.config/wezterm/
  wezterm.lua          -- entry: config_builder, require + apply each module, return config
  lua/appearance.lua   -- font, Catppuccin Mocha, window padding/decorations, cursor
  lua/behavior.lua     -- bell, scrollback, fps
  lua/plugins.lua      -- smart-splits (nav) + tabline (status bar) wiring
  lua/keys.lua         -- direct ctrl+shift+… chords + workspace picker binding
  lua/machine.lua      -- per-host overrides (gitignored, no-op default)
```

---

## Task 1: Entry point + appearance module

**Files:**
- Create: `/home/tenzin/.dotfiles/.config/wezterm/wezterm.lua`
- Create: `/home/tenzin/.dotfiles/.config/wezterm/lua/appearance.lua`

- [ ] **Step 1: Create the appearance module**

Create `/home/tenzin/.dotfiles/.config/wezterm/lua/appearance.lua`:

```lua
local wezterm = require("wezterm")

local M = {}

function M.apply(config)
  -- Fonts (kitty: fonts.conf)
  config.font = wezterm.font("JetBrainsMono Nerd Font")
  config.font_size = 14

  -- Theme (kitty: theme.conf — Catppuccin Mocha)
  config.color_scheme = "Catppuccin Mocha"

  -- Window (kitty: appearance.conf)
  config.window_padding = { left = 12, right = 12, top = 12, bottom = 12 }
  config.window_decorations = "NONE"

  -- Cursor (no trail equivalent in WezTerm; blinking block)
  config.default_cursor_style = "BlinkingBlock"
  config.cursor_blink_rate = 500
end

return M
```

- [ ] **Step 2: Create the entry point**

Create `/home/tenzin/.dotfiles/.config/wezterm/wezterm.lua`:

```lua
local wezterm = require("wezterm")
local config = wezterm.config_builder()

require("lua.appearance").apply(config)

return config
```

- [ ] **Step 3: Verify the config loads**

Run:
```bash
wezterm --config-file /home/tenzin/.dotfiles/.config/wezterm/wezterm.lua show-keys >/dev/null && echo "CONFIG OK"
```
Expected: prints `CONFIG OK` (exit 0, no Lua error).

- [ ] **Step 4: Verify the font and theme resolved**

Run:
```bash
wezterm --config-file /home/tenzin/.dotfiles/.config/wezterm/wezterm.lua ls-fonts --list-system >/dev/null && echo "FONT CONFIG OK"
```
Expected: prints `FONT CONFIG OK` (font config parsed without error).

- [ ] **Step 5: Commit**

```bash
cd /home/tenzin/.dotfiles
git add .config/wezterm/wezterm.lua .config/wezterm/lua/appearance.lua
git commit -m "feat(wezterm): entry point and appearance module"
```

---

## Task 2: Behavior module

**Files:**
- Create: `/home/tenzin/.dotfiles/.config/wezterm/lua/behavior.lua`
- Modify: `/home/tenzin/.dotfiles/.config/wezterm/wezterm.lua`

- [ ] **Step 1: Create the behavior module**

Create `/home/tenzin/.dotfiles/.config/wezterm/lua/behavior.lua`:

```lua
local M = {}

function M.apply(config)
  -- kitty: behavior.conf / performance.conf
  config.audible_bell = "Disabled"
  config.scrollback_lines = 3000

  -- Low-latency rendering (analog of kitty input_delay 0 / repaint_delay 2)
  config.max_fps = 120
  config.animation_fps = 60
end

return M
```

- [ ] **Step 2: Wire it into the entry point**

In `/home/tenzin/.dotfiles/.config/wezterm/wezterm.lua`, add the require after the appearance line so the file reads:

```lua
local wezterm = require("wezterm")
local config = wezterm.config_builder()

require("lua.appearance").apply(config)
require("lua.behavior").apply(config)

return config
```

- [ ] **Step 3: Verify the config loads**

Run:
```bash
wezterm --config-file /home/tenzin/.dotfiles/.config/wezterm/wezterm.lua show-keys >/dev/null && echo "CONFIG OK"
```
Expected: prints `CONFIG OK`.

- [ ] **Step 4: Commit**

```bash
cd /home/tenzin/.dotfiles
git add .config/wezterm/lua/behavior.lua .config/wezterm/wezterm.lua
git commit -m "feat(wezterm): behavior module (bell, scrollback, fps)"
```

---

## Task 3: Plugins module (smart-splits nav + tabline status bar)

**Files:**
- Create: `/home/tenzin/.dotfiles/.config/wezterm/lua/plugins.lua`
- Modify: `/home/tenzin/.dotfiles/.config/wezterm/wezterm.lua`

This task fetches two plugins from GitHub on first load (network required). The
workspace-switcher plugin is required and bound in Task 4 (keys), so it is not
applied here.

- [ ] **Step 1: Create the plugins module**

Create `/home/tenzin/.dotfiles/.config/wezterm/lua/plugins.lua`:

```lua
local wezterm = require("wezterm")

local M = {}

function M.apply(config)
  -- Alt+hjkl navigation, nvim-aware. Replaces the kitty IS_NVIM user-var trick:
  -- forwards the key to nvim when the active pane runs nvim, else moves panes.
  local smart_splits =
    wezterm.plugin.require("https://github.com/mrjones2014/smart-splits.nvim")
  smart_splits.apply_to_config(config, {
    direction_keys = { "h", "j", "k", "l" },
    modifiers = { move = "ALT", resize = "ALT|SHIFT" },
  })

  -- Powerline tab/status line (replaces the rose-pine tmux status bar).
  -- Left shows the workspace name (tmux session-name analog); right shows
  -- cwd + clock. Disable the native fancy bar so tabline owns rendering.
  config.use_fancy_tab_bar = false
  config.tab_bar_at_bottom = false
  config.show_new_tab_button_in_tab_bar = false

  local tabline =
    wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
  tabline.setup({
    options = {
      theme = "Catppuccin Mocha",
      icons_enabled = true,
    },
    sections = {
      tabline_a = { "workspace" },
      tabline_b = {},
      tabline_c = {},
      tab_active = {
        "index",
        { "process", padding = { left = 0, right = 1 } },
      },
      tab_inactive = {
        "index",
        { "process", padding = { left = 0, right = 1 } },
      },
      tabline_x = {},
      tabline_y = { "cwd" },
      tabline_z = { "datetime" },
    },
  })
  tabline.apply_to_config(config)
end

return M
```

- [ ] **Step 2: Wire it into the entry point**

In `/home/tenzin/.dotfiles/.config/wezterm/wezterm.lua`, add the require after behavior so it reads:

```lua
local wezterm = require("wezterm")
local config = wezterm.config_builder()

require("lua.appearance").apply(config)
require("lua.behavior").apply(config)
require("lua.plugins").apply(config)

return config
```

- [ ] **Step 3: Verify the config loads and fetches plugins**

Run:
```bash
wezterm --config-file /home/tenzin/.dotfiles/.config/wezterm/wezterm.lua show-keys >/dev/null && echo "CONFIG OK"
```
Expected: prints `CONFIG OK`. First run may pause briefly while cloning the plugins into `~/.local/share/wezterm/`.

- [ ] **Step 4: Verify the smart-splits nav keys were added**

Run:
```bash
wezterm --config-file /home/tenzin/.dotfiles/.config/wezterm/wezterm.lua show-keys | grep -i "ALT.*h" | head
```
Expected: shows an `ALT h` (and friends) assignment registered by smart-splits.

- [ ] **Step 5: Commit**

```bash
cd /home/tenzin/.dotfiles
git add .config/wezterm/lua/plugins.lua .config/wezterm/wezterm.lua
git commit -m "feat(wezterm): smart-splits nav and tabline status bar"
```

---

## Task 4: Keys module (direct chords + workspace picker)

**Files:**
- Create: `/home/tenzin/.dotfiles/.config/wezterm/lua/keys.lua`
- Modify: `/home/tenzin/.dotfiles/.config/wezterm/wezterm.lua`

`config.keys` already contains the smart-splits nav keys from Task 3, so this
module appends to it rather than replacing it. Must be applied AFTER plugins.

- [ ] **Step 1: Create the keys module**

Create `/home/tenzin/.dotfiles/.config/wezterm/lua/keys.lua`:

```lua
local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

function M.apply(config)
  -- Same plugin handle as plugins.lua; wezterm.plugin.require is cached, so this
  -- returns the already-loaded module. We bind the picker to our own chord
  -- instead of the plugin's default.
  local workspace_switcher =
    wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")

  config.keys = config.keys or {}

  local keys = {
    -- ── Splits (tmux panes) ──────────────────────────────────────────
    -- tmux `s` / kitty hsplit: new pane below
    { key = "5", mods = "CTRL|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
    -- tmux `v` / kitty vsplit: new pane right
    { key = "'", mods = "CTRL|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    -- tmux `z`: zoom toggle
    { key = "z", mods = "CTRL|SHIFT", action = act.TogglePaneZoomState },

    -- ── Tabs (tmux windows) ──────────────────────────────────────────
    -- tmux `c`: new tab in current dir
    { key = "t", mods = "CTRL|SHIFT", action = act.SpawnTab("CurrentPaneDomain") },
    -- tmux C-S-h / C-S-l: reorder current tab (shadows default scrollback,
    -- which moves to ctrl+shift+u below — matches the kitty config)
    { key = "h", mods = "CTRL|SHIFT", action = act.MoveTabRelative(-1) },
    { key = "l", mods = "CTRL|SHIFT", action = act.MoveTabRelative(1) },
    -- tmux `prefix r`: rename tab
    {
      key = "r",
      mods = "CTRL|SHIFT",
      action = act.PromptInputLine({
        description = "Rename tab",
        action = wezterm.action_callback(function(window, _, line)
          if line and #line > 0 then
            window:active_tab():set_title(line)
          end
        end),
      }),
    },

    -- ── Sessions (tmux sessions → WezTerm workspaces) ────────────────
    -- tmux `prefix O` / kitty ctrl+shift+o: zoxide project picker → workspace
    { key = "o", mods = "CTRL|SHIFT", action = workspace_switcher.switch_workspace() },

    -- ── Scrollback / copy mode (tmux copy-mode, vi keys) ─────────────
    { key = "u", mods = "CTRL|SHIFT", action = act.ActivateCopyMode },

    -- ── Input fixups (from kitty keybinds.conf) ──────────────────────
    -- shift+enter: send escape + return
    { key = "Enter", mods = "SHIFT", action = act.SendString("\x1b\r") },
    -- ctrl+backspace: backward-kill-word in shell
    { key = "Backspace", mods = "CTRL", action = act.SendString("\x1b\x7f") },

    -- ── Disable unwanted default ─────────────────────────────────────
    -- ctrl+shift+n spawns a new OS window by default; keep work inside tabs
    { key = "n", mods = "CTRL|SHIFT", action = "DisableDefaultAssignment" },
  }

  -- tmux `prefix <n>` / kitty ctrl+<n>: jump straight to tab N
  for i = 1, 9 do
    table.insert(keys, {
      key = tostring(i),
      mods = "CTRL",
      action = act.ActivateTab(i - 1),
    })
  end

  for _, k in ipairs(keys) do
    table.insert(config.keys, k)
  end
end

return M
```

- [ ] **Step 2: Wire it into the entry point (after plugins)**

In `/home/tenzin/.dotfiles/.config/wezterm/wezterm.lua`, add the require after plugins so it reads:

```lua
local wezterm = require("wezterm")
local config = wezterm.config_builder()

require("lua.appearance").apply(config)
require("lua.behavior").apply(config)
require("lua.plugins").apply(config)
require("lua.keys").apply(config)

return config
```

- [ ] **Step 3: Verify the config loads**

Run:
```bash
wezterm --config-file /home/tenzin/.dotfiles/.config/wezterm/wezterm.lua show-keys >/dev/null && echo "CONFIG OK"
```
Expected: prints `CONFIG OK`.

- [ ] **Step 4: Verify the custom chords are registered**

Run:
```bash
wezterm --config-file /home/tenzin/.dotfiles/.config/wezterm/wezterm.lua show-keys | grep -iE "CTRL\|SHIFT (5|z|t|o|u)" | head
```
Expected: shows the split (`5`), zoom (`z`), new-tab (`t`), picker (`o`), and copy-mode (`u`) assignments.

- [ ] **Step 5: Commit**

```bash
cd /home/tenzin/.dotfiles
git add .config/wezterm/lua/keys.lua .config/wezterm/wezterm.lua
git commit -m "feat(wezterm): direct ctrl+shift keybinds and workspace picker"
```

---

## Task 5: Machine overrides module + gitignore

**Files:**
- Create: `/home/tenzin/.dotfiles/.config/wezterm/lua/machine.lua`
- Modify: `/home/tenzin/.dotfiles/.config/wezterm/wezterm.lua`
- Modify: `/home/tenzin/.dotfiles/.gitignore`

- [ ] **Step 1: Create the machine module (no-op default)**

Create `/home/tenzin/.dotfiles/.config/wezterm/lua/machine.lua`:

```lua
-- Per-host overrides. Gitignored — edit freely on each machine.
-- Applied last so it overrides any earlier module.
local M = {}

function M.apply(config)
  -- e.g. config.font_size = 16
end

return M
```

- [ ] **Step 2: Wire it into the entry point (last)**

In `/home/tenzin/.dotfiles/.config/wezterm/wezterm.lua`, add the require as the last apply so it reads:

```lua
local wezterm = require("wezterm")
local config = wezterm.config_builder()

require("lua.appearance").apply(config)
require("lua.behavior").apply(config)
require("lua.plugins").apply(config)
require("lua.keys").apply(config)
require("lua.machine").apply(config)

return config
```

- [ ] **Step 3: Gitignore the machine file**

Add this line to `/home/tenzin/.dotfiles/.gitignore` (alongside the existing `/.config/kitty/machine.conf` entry):

```
/.config/wezterm/lua/machine.lua
```

- [ ] **Step 4: Verify config loads and machine.lua is ignored**

Run:
```bash
wezterm --config-file /home/tenzin/.dotfiles/.config/wezterm/wezterm.lua show-keys >/dev/null && echo "CONFIG OK"
cd /home/tenzin/.dotfiles && git check-ignore .config/wezterm/lua/machine.lua && echo "IGNORED OK"
```
Expected: `CONFIG OK` then `IGNORED OK`.

- [ ] **Step 5: Commit (machine.lua is NOT staged — it is ignored)**

```bash
cd /home/tenzin/.dotfiles
git add .config/wezterm/wezterm.lua .gitignore
git commit -m "feat(wezterm): per-host machine overrides module"
```

---

## Task 6: Symlink into ~/.config and live smoke test

**Files:**
- None in repo (creates a symlink in `$HOME`).

- [ ] **Step 1: Create the folded directory symlink (mirrors kitty)**

Run:
```bash
ln -sfn ../.dotfiles/.config/wezterm /home/tenzin/.config/wezterm
ls -ld /home/tenzin/.config/wezterm
```
Expected: `/home/tenzin/.config/wezterm -> ../.dotfiles/.config/wezterm`.

- [ ] **Step 2: Verify WezTerm loads the config from its default path**

Run:
```bash
wezterm show-keys >/dev/null && echo "DEFAULT-PATH CONFIG OK"
```
Expected: `DEFAULT-PATH CONFIG OK` (config loaded from `~/.config/wezterm/wezterm.lua`, no `--config-file`).

- [ ] **Step 3: Manual smoke test (interactive — run by the user)**

Open WezTerm and confirm:
- Catppuccin Mocha colors, JetBrainsMono font, 12px padding, no title bar.
- `ctrl+shift+5` splits below; `ctrl+shift+'` splits right; `ctrl+shift+z` zooms.
- `Alt+h/j/k/l` moves between splits; inside `nvim` (with smart-splits.nvim) the same keys move nvim windows.
- `ctrl+shift+t` new tab in cwd; `ctrl+1..9` jump tabs; `ctrl+shift+h/l` reorder; `ctrl+shift+r` renames.
- `ctrl+shift+o` opens the zoxide picker; choosing a dir switches to a workspace shown in the tabline left section.
- `ctrl+shift+u` enters copy mode (vi keys); mouse-selected text reaches the system clipboard.

- [ ] **Step 4: Commit (nothing to commit — symlink lives in $HOME)**

No repo changes in this task. If `git status` is clean, this task is done. The
nvim-side `smart-splits.nvim` plugin install is assumed already present; if Alt+hjkl
does not forward into nvim, install/configure `mrjones2014/smart-splits.nvim` in the
Neovim config (out of scope for this plan).

---

## Self-Review

**Spec coverage:**
- File layout (5 modules + entry) → Tasks 1–5. ✓
- smart_workspace_switcher picker → Task 4 (`switch_workspace()` on `ctrl+shift+o`). ✓
- smart-splits nav → Task 3. ✓
- tabline status bar w/ workspace name → Task 3. ✓
- All keybinds in the spec table → Task 4 (splits, zoom, tabs, goto N, move tab, rename, picker, copy mode, input fixups, disable new-window). Close-pane (`ctrl+shift+w`) and next/prev tab (`ctrl+shift+[ ]`) are WezTerm defaults, intentionally unbound. ✓
- Appearance (font, theme, padding, decorations, cursor) → Task 1. ✓
- Behavior (bell, scrollback, fps) → Task 2. ✓
- machine.lua gitignored → Task 5. ✓
- Non-goals (persistence, popups, directional pane move) → correctly absent. ✓

**Placeholder scan:** No TBD/TODO; every code step shows full file content. ✓

**Type/name consistency:** Every module exposes `M.apply(config)`; `wezterm.lua` calls `.apply` on each. The workspace-switcher URL is identical in plugins.lua intent and keys.lua. The `ctrl+shift+u` copy-mode binding and the `ctrl+shift+h` tab-move shadow are consistent with the spec's note. ✓
