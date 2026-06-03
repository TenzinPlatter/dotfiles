local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Ensure the config directory is on the path for subcommands like ls-fonts
package.path = wezterm.config_dir .. "/?.lua;" .. package.path

require("lua.appearance").apply(config)
require("lua.behavior").apply(config)
require("lua.plugins").apply(config)
require("lua.keys").apply(config)

return config
