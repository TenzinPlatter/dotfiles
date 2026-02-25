local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

local function capitalize(args)
  local state = args[1][1]
  if state and #state > 0 then
    return "set" .. state:sub(1, 1):upper() .. state:sub(2)
  end
  return "setState"
end

return {
  s("ust", {
    t("const ["),
    i(1, "state"),
    t(", "),
    f(capitalize, { 1 }),
    t("] = useState<"),
    i(2, "T"),
    t(">("),
    i(3, "initialValue"),
    t(");"),
  }),
  s({
    trig = "us",
    priority = 1000,
  }, {
    t("const ["),
    i(1, "state"),
    t(", "),
    f(capitalize, { 1 }),
    t("] = useState<"),
    i(2, "T"),
    t(">("),
    i(3, "initialValue"),
    t(");"),
  }),
}
