local wezterm = require("wezterm")

local M = {}

function M.apply(config)
  -- Fonts (kitty: fonts.conf)
  config.font = wezterm.font("JetbrainsMono Nerd Font")
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
