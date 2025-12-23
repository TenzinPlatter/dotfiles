return {
  "nvim-tree/nvim-web-devicons",
  config = function()
    require("nvim-web-devicons").setup({
      -- Use material design variant
      variant = "material",

      -- Globally override default icons with material alternatives
      override = {
        -- Programming languages
        lua = {
          icon = "󰢱",
          color = "#51a0cf",
          cterm_color = "74",
          name = "Lua",
        },
        py = {
          icon = "󰌠",
          color = "#ffbc03",
          cterm_color = "214",
          name = "Py",
        },
        rs = {
          icon = "",
          color = "#dea584",
          cterm_color = "216",
          name = "Rs",
        },
        js = {
          icon = "󰌞",
          color = "#f0db4f",
          cterm_color = "185",
          name = "Js",
        },
        ts = {
          icon = "󰛦",
          color = "#519aba",
          cterm_color = "67",
          name = "Ts",
        },
        tsx = {
          icon = "󰛦",
          color = "#1354bf",
          cterm_color = "26",
          name = "Tsx",
        },
        jsx = {
          icon = "󰜈",
          color = "#20c2e3",
          cterm_color = "45",
          name = "Jsx",
        },
        go = {
          icon = "󰟓",
          color = "#519aba",
          cterm_color = "67",
          name = "Go",
        },
        java = {
          icon = "",
          color = "#cc3e44",
          cterm_color = "167",
          name = "Java",
        },

        -- Markup & config files
        md = {
          icon = "󰍔",
          color = "#519aba",
          cterm_color = "67",
          name = "Md",
        },
        html = {
          icon = "󰌝",
          color = "#e34c26",
          cterm_color = "202",
          name = "Html",
        },
        css = {
          icon = "󰌜",
          color = "#563d7c",
          cterm_color = "60",
          name = "Css",
        },
        json = {
          icon = "󰘦",
          color = "#cbcb41",
          cterm_color = "185",
          name = "Json",
        },
        yaml = {
          icon = "",
          color = "#6d8086",
          cterm_color = "66",
          name = "Yaml",
        },
        yml = {
          icon = "",
          color = "#6d8086",
          cterm_color = "66",
          name = "Yml",
        },
        toml = {
          icon = "",
          color = "#6d8086",
          cterm_color = "66",
          name = "Toml",
        },

        -- Git
        git = {
          icon = "󰊢",
          color = "#f14e32",
          cterm_color = "202",
          name = "Git",
        },

        -- Folders
        ["folder"] = {
          icon = "󰉋",
          color = "#7ebae4",
          cterm_color = "110",
          name = "Folder",
        },

        -- Special files
        [".gitignore"] = {
          icon = "󰊢",
          color = "#f14e32",
          cterm_color = "202",
          name = "GitIgnore",
        },
        ["README.md"] = {
          icon = "󰍔",
          color = "#519aba",
          cterm_color = "67",
          name = "Readme",
        },
        ["Dockerfile"] = {
          icon = "󰡨",
          color = "#384d54",
          cterm_color = "239",
          name = "Dockerfile",
        },
      },

      -- Override icons by filename
      override_by_filename = {
        [".gitignore"] = {
          icon = "󰊢",
          color = "#f14e32",
          name = "GitIgnore",
        },
        ["package.json"] = {
          icon = "",
          color = "#e8274b",
          name = "PackageJson",
        },
        ["package-lock.json"] = {
          icon = "",
          color = "#7a0d21",
          name = "PackageLockJson",
        },
        [".prettierrc"] = {
          icon = "󰬗",
          color = "#4285f4",
          name = "Prettier",
        },
        [".eslintrc"] = {
          icon = "󰱺",
          color = "#4b32c3",
          name = "Eslint",
        },
      },

      -- Override icons by extension
      override_by_extension = {
        ["log"] = {
          icon = "󰌱",
          color = "#81e043",
          name = "Log",
        },
        ["conf"] = {
          icon = "",
          color = "#6d8086",
          name = "Conf",
        },
        ["env"] = {
          icon = "",
          color = "#faf743",
          name = "Env",
        },
      },

      -- Enable strict mode (only use configured icons)
      strict = false,

      -- Show icons by default
      default = true,
    })
  end,
}
