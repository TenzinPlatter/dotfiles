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
