# WezTerm Native Flow — Design

Port the existing kitty-native-flow workflow (itself a native port of the tmux
config) to WezTerm. WezTerm replaces tmux entirely on the local machine: its own
panes, tabs, and **workspaces** stand in for tmux panes/windows/sessions. No tmux
locally, no save/restore.

## Goals

- Reproduce the kitty-native-flow keybindings as **direct `ctrl+shift+…` chords**
  (no leader/prefix), matching current muscle memory.
- Seamless **Alt+hjkl** navigation between WezTerm splits and Neovim windows.
- A **zoxide-backed project picker** that opens a project as a WezTerm workspace
  (the `sesh` / `kitty-sesh` replacement).
- **Workspaces** as the tmux-session equivalent (named, switchable tab groups).
- Catppuccin Mocha theme + current appearance (font, padding, decorations, cursor).
- A powerline tab/status line showing the active workspace name.

## Non-goals

- Session save/restore / persistence (tmux-resurrect / continuum). Explicitly skipped.
- Floating popups / overlays (kitty `--type=overlay`, tmux `display-popup`). The
  lazygit / scratch popups are dropped — unused.
- tmux-inside-WezTerm or remote-tmux passthrough.

## File layout

Lives at `~/.config/wezterm/` (stow-managed, mirroring the kitty split-by-concern):

```
wezterm.lua          -- entry: build config, require modules, return config
lua/appearance.lua   -- font, Catppuccin Mocha, window, cursor
lua/behavior.lua     -- performance, clipboard, scrollback, bell
lua/keys.lua         -- direct ctrl+shift+… chords
lua/plugins.lua      -- smart-splits, workspace switcher, tabline wiring
lua/machine.lua      -- per-host overrides (gitignored, like kitty machine.conf)
```

`wezterm.lua` constructs the config table and passes it to each module's
`apply(config)` function. `machine.lua` is applied last so it can override, and is
added to `.gitignore` (mirroring `machine.conf`).

## Plugins

Auto-fetched by WezTerm via `wezterm.plugin.require(<git url>)`:

- **`MLFlexer/smart_workspace_switcher.wezterm`** — zoxide-backed fuzzy picker;
  opening a result switches to (or creates) a workspace rooted at that dir.
  Replaces `sesh` / `kitty-sesh`. Requires `zoxide` (already used) and `fd`.
- **`mrjones2014/smart-splits.nvim`** — WezTerm companion to the nvim plugin.
  Detects when the active pane runs nvim and forwards Alt+hjkl; otherwise moves
  between WezTerm splits. Replaces the kitty `IS_NVIM` user-var mechanism.
- **`michaelbrusegard/tabline.wez`** — Catppuccin powerline tab/status line.
  Left section: workspace name (tmux session-name analog). Right: cwd + clock.

## Keybindings (direct chords, mirroring kitty)

| Action | Key | WezTerm action |
|---|---|---|
| split below | `ctrl+shift+5` | `SplitVertical { domain = "CurrentPaneDomain" }` |
| split right | `ctrl+shift+'` | `SplitHorizontal { domain = "CurrentPaneDomain" }` |
| zoom pane | `ctrl+shift+z` | `TogglePaneZoomState` |
| close pane | `ctrl+shift+w` | `CloseCurrentPane` (WezTerm default) |
| nav panes / nvim | `alt+h/j/k/l` | smart-splits plugin maps |
| new tab (cwd) | `ctrl+shift+t` | `SpawnTab "CurrentPaneDomain"` |
| move tab left | `ctrl+shift+h` | `MoveTabRelative(-1)` |
| move tab right | `ctrl+shift+l` | `MoveTabRelative(1)` |
| goto tab N | `ctrl+1` … `ctrl+9` | `ActivateTab(0)` … `ActivateTab(8)` |
| next / prev tab | `ctrl+shift+]` / `ctrl+shift+[` | WezTerm defaults |
| rename tab | `ctrl+shift+r` | `PromptInputLine` → `tab:set_title(line)` |
| project picker | `ctrl+shift+o` | `workspace_switcher.switch_workspace()` |
| scrollback / copy | `ctrl+shift+u` | `ActivateCopyMode` |
| shift+enter fix | `shift+enter` | `SendString("\x1b\r")` |
| ctrl+backspace fix | `ctrl+backspace` | `SendString("\x1b\x7f")` |
| disable new window | `ctrl+shift+n` | `DisableDefaultAssignment` |

Notes:
- Split cwd is inherited via shell-integration / OSC 7 (zsh already emits it).
- `ctrl+shift+h` (move tab) deliberately shadows the default scrollback binding;
  scrollback moves to `ctrl+shift+u`, exactly as in the kitty config.
- Copy mode uses WezTerm's built-in vi key table (matches tmux `mode-keys vi`).
- No directional pane-move binding (kitty `ctrl+shift+alt+hjkl`). WezTerm has no
  native directional move and the rotate approximation was rejected — omitted.

## Appearance

- `font = wezterm.font("JetBrainsMono Nerd Font")`, `font_size = 14`.
- `color_scheme = "Catppuccin Mocha"` (WezTerm built-in).
- `window_padding = { left=12, right=12, top=12, bottom=12 }`.
- `window_decorations = "NONE"` (matches kitty `hide_window_decorations yes`).
- Cursor: blinking block (`default_cursor_style = "BlinkingBlock"`). No cursor
  trail — WezTerm has no equivalent to kitty 0.42 `cursor_trail`.
- Tab/status bar rendered by `tabline.wez`; native fancy tab bar disabled.

## Behavior

- `audible_bell = "Disabled"`.
- `scrollback_lines = 3000`.
- High `max_fps` (e.g. 120) for low input latency (analog of kitty's
  `input_delay 0` / `repaint_delay 2`).
- OSC 52 clipboard works natively (no extra config); covers the tmux
  `set-clipboard on` passthrough.

## Known limitations (carried from WezTerm, accepted)

1. No floating popups → lazygit/scratch overlays dropped (unused).
2. No directional pane move → that binding omitted entirely.
3. No cursor trail animation → blinking block cursor instead.
