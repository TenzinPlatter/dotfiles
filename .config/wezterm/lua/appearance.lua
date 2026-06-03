local wezterm = require("wezterm")

local M = {}

function M.apply(config)
  -- Fonts (kitty: fonts.conf)
  config.font = wezterm.font("JetbrainsMono Nerd Font")
  config.font_size = 14

  config.color_scheme = "Catppuccin Mocha"

  config.window_padding = { left = 18, right = 18, top = 18, bottom = 18 }
  config.window_decorations = "NONE"
end

return M
