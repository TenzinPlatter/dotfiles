return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      notify = {
        enabled = false,
      },
      routes = {
        { filter = { event = "msg_show", find = "written" }, opts = { skip = true } },
      },
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = true,
      },
      popupmenu = {
        enabled = true,
        backend = "nui",
      },
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
  },
  {
    "j-hui/fidget.nvim",
    version = "*",
    opts = {
      notification = {
        window = {
          winblend = 0,
        },
      },
    },
  },
  {
    "shortcuts/no-neck-pain.nvim",
    opts = {
      width = 200,
    },
    keys = {
      { "<leader>z", ":NoNeckPain<CR>", desc = "Center window" },
    },
  },
}
