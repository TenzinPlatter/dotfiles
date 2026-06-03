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
