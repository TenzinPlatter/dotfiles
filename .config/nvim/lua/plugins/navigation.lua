return {
  {
    "christoomey/vim-tmux-navigator",
    event = "VeryLazy",
    init = function()
      vim.g.tmux_navigator_no_mappings = 1
    end,
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
      "TmuxNavigatorProcessList",
    },
    keys = {
      {
        "<M-h>",
        function()
          vim.cmd("TmuxNavigateLeft")
        end,
        mode = { "n", "t" },
        desc = "Navigate left",
      },
      {
        "<M-j>",
        function()
          vim.cmd("TmuxNavigateDown")
        end,
        mode = { "n", "t" },
        desc = "Navigate down",
      },
      {
        "<M-k>",
        function()
          vim.cmd("TmuxNavigateUp")
        end,
        mode = { "n", "t" },
        desc = "Navigate up",
      },
      {
        "<M-l>",
        function()
          vim.cmd("TmuxNavigateRight")
        end,
        mode = { "n", "t" },
        desc = "Navigate right",
      },
    },
  },
  {
    "mikavilpas/yazi.nvim",
    version = "*",
    event = "VeryLazy",
    dependencies = {
      { "nvim-lua/plenary.nvim", lazy = true },
    },
    keys = {
      {
        "<leader>-",
        mode = { "n", "v" },
        "<cmd>Yazi<cr>",
        desc = "Open yazi at the current file",
      },
      {
        "<leader>cw",
        "<cmd>Yazi cwd<cr>",
        desc = "Open the file manager in nvim's working directory",
      },
      {
        "<c-up>",
        "<cmd>Yazi toggle<cr>",
        desc = "Resume the last yazi session",
      },
    },
    opts = {
      open_for_directories = false,
      keymaps = {
        show_help = "<f1>",
      },
    },
    init = function()
      vim.g.loaded_netrwPlugin = 1
    end,
  },
  {
    "chrisgrieser/nvim-rip-substitute",
    cmd = "RipSubstitute",
    keys = {
      {
        "<leader>ss",
        function()
          require("rip-substitute").sub()
        end,
        mode = { "n", "x" },
        desc = "Rip substitute",
      },
    },
  },
  { "akinsho/bufferline.nvim", enabled = false },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "FileOpen",
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()

      -- Custom tabline showing harpooned files
      function _G.harpoon_tabline()
        local list = harpoon:list()
        local current = vim.api.nvim_buf_get_name(0)
        local parts = {}

        for i = 1, list:length() do
          local item = list:get(i)
          if item then
            local name = vim.fn.fnamemodify(item.value, ":t")
            local is_active = current == vim.fn.fnamemodify(item.value, ":p")
            if is_active then
              table.insert(parts, "%#TabLineSel# " .. i .. " " .. name .. " %#TabLine#")
            else
              table.insert(parts, "%#TabLine# " .. i .. " " .. name .. " ")
            end
          end
        end

        if #parts == 0 then
          return "%#TabLine# harpoon: <leader>a to add %#TabLineFill#"
        end
        return table.concat(parts, "│") .. "%#TabLineFill#"
      end

      vim.o.showtabline = 2
      vim.o.tabline = "%!v:lua.harpoon_tabline()"

      for i = 1, 5 do
        vim.keymap.set("n", "<leader>" .. i, function()
          harpoon:list():select(i)
        end, { desc = "Harpoon file " .. i })
      end

      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          vim.keymap.set("n", "L", function()
            harpoon:list():next()
          end, { desc = "Harpoon next" })
        end,
      })
    end,
    keys = {
      {
        "<leader>a",
        function()
          require("harpoon"):list():add()
        end,
        { desc = "Harpoon add file" },
      },
      {
        "<leader>h",
        function()
          require("harpoon").ui:toggle_quick_menu(require("harpoon"):list())
        end,
        { desc = "Harpoon menu" },
      },
      {
        "H",
        function()
          require("harpoon"):list():prev()
        end,
        { desc = "Harpoon prev" },
      },
      {
        "L",
        function()
          require("harpoon"):list():next()
        end,
        { desc = "Harpoon next" },
      }
    },
  },
}
