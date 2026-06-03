local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

function M.apply(config)
  -- The workspace switcher lives here (not plugins.lua) because we only need it
  -- to bind our own chord; wezterm.plugin.require is cached by URL, so requiring
  -- it here is cheap. We bind the picker to our chord instead of its default.
  local workspace_switcher =
    wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")

  config.keys = config.keys or {}

  local keys = {
    -- Splits (tmux panes)
    { key = "5", mods = "CTRL|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
    { key = "'", mods = "CTRL|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "z", mods = "CTRL|SHIFT", action = act.TogglePaneZoomState },

    -- Tabs (tmux windows)
    { key = "t", mods = "CTRL|SHIFT", action = act.SpawnTab("CurrentPaneDomain") },
    { key = "h", mods = "CTRL|SHIFT", action = act.MoveTabRelative(-1) },
    { key = "l", mods = "CTRL|SHIFT", action = act.MoveTabRelative(1) },
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

    -- Sessions (tmux sessions -> WezTerm workspaces): zoxide project picker
    { key = "o", mods = "CTRL|SHIFT", action = workspace_switcher.switch_workspace() },

    -- Scrollback / copy mode (vi keys)
    { key = "u", mods = "CTRL|SHIFT", action = act.ActivateCopyMode },

    -- Input fixups (from kitty keybinds.conf)
    { key = "Enter", mods = "SHIFT", action = act.SendString("\x1b\r") },
    { key = "Backspace", mods = "CTRL", action = act.SendString("\x1b\x7f") },

    -- Disable unwanted default (ctrl+shift+n new OS window)
    { key = "n", mods = "CTRL|SHIFT", action = "DisableDefaultAssignment" },
  }

  -- tmux prefix <n> / kitty ctrl+<n>: jump straight to tab N
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
