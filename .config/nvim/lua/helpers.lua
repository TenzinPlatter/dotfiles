local M = {}

function M.in_codediff()
  local codediff_lifecycle = require("codediff.ui.lifecycle")
  local current_tab = vim.api.nvim_get_current_tabpage()
  return codediff_lifecycle.get_session(current_tab)
end

return M
