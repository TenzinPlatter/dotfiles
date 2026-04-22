return {
  {
    "neovim/nvim-lspconfig",
    init = function()
      -- Auto-load inlay hint preferences on LSP attach
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local helpers = require("tenzin.helpers")
          local filetype = vim.bo[args.buf].filetype
          local preference = helpers.get_inlay_hint_preference(filetype)

          if preference ~= nil then
            vim.lsp.inlay_hint.enable(preference, { bufnr = args.buf })
          end

          vim.keymap.set("n", "K", function()
            vim.lsp.buf.hover({ silent = true })
          end, { buffer = args.buf })
        end,
      })

      -- this needs to be installed manually outside of mason
      vim.lsp.config["crates"] = {
        cmd = { "crates-lsp" },
        filetypes = { "toml" },
        root_markers = { "Cargo.toml", ".git" },
        init_options = {},
      }
    end,
    keys = {
      {
        "<C-S>",
        function()
          vim.diagnostic.open_float({ border = "rounded" })
        end,
        desc = "Line Diagnostics",
      },
      -- { "gtd", vim.lsp.buf.type_definition, desc = "Goto Type Definition" },
      {
        "<leader>th",
        function()
          local helpers = require("tenzin.helpers")
          local bufnr = vim.api.nvim_get_current_buf()
          local current_state = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
          local new_state = not current_state

          vim.lsp.inlay_hint.enable(new_state, { bufnr = bufnr })

          -- Save preference for current filetype
          helpers.save_inlay_hint_preference(vim.bo.filetype, new_state)

          if new_state then
            print("Enabled inlay hints")
          else
            print("Disabled inlay hints")
          end
        end,
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "mason-org/mason.nvim",
    },
    opts = {
      ensure_installed = {},
      handlers = {
        -- Default handler for all servers
        function(server_name)
          vim.lsp.config(server_name).setup({})
        end,
      },
    },
  },
}
