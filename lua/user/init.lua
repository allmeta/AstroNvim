local config = {

  -- Configure AstroNvim updates
  updater = {
    remote = "origin", -- remote to use
    channel = "nightly", -- "stable" or "nightly"
    version = "latest", -- "latest", tag name, or regex search like "v1.*" to only do updates before v2 (STABLE ONLY)
    branch = "main", -- branch name (NIGHTLY ONLY)
    commit = nil, -- commit hash (NIGHTLY ONLY)
    pin_plugins = nil, -- nil, true, false (nil will pin plugins on stable only)
    skip_prompts = false, -- skip prompts about breaking changes
    show_changelog = true, -- show the changelog after performing an update
    auto_reload = false, -- automatically reload and sync packer after a successful update
    auto_quit = false, -- automatically quit the current session after a successful update
    -- remotes = { -- easily add new remotes to track
    --   ["remote_name"] = "https://remote_url.come/repo.git", -- full remote url
    --   ["remote2"] = "github_user/repo", -- GitHub user/repo shortcut,
    --   ["remote3"] = "github_user", -- GitHub user assume AstroNvim fork
    -- },
  },

  -- Set colorscheme to use
  colorscheme = "tokyonight",

  -- Override highlight groups in any theme
  highlights = {
  },

  -- set vim options here (vim.<first_key>.<second_key> =  value)
  options = {
    opt = {
    },
    g = {
      tokyonight_style = "night",
    },
  },

  -- Set dashboard header
  header = {
  "     ______  _______        ______   _________________      _____   ",
  "    |      \\/       \\   ___|\\     \\ /                 \\ ___|\\    \\  ",
  "   /          /\\     \\ |     \\     \\\\______     ______//    /\\    \\ ",
  "  /     /\\   / /\\     ||     ,_____/|  \\( /    /  )/  |    |  |    |",
  " /     /\\ \\_/ / /    /||     \\--'\\_|/   ' |   |   '   |    |__|    |",
  "|     |  \\|_|/ /    / ||     /___/|       |   |       |    .--.    |",
  "|     |       |    |  ||     \\____|\\     /   //       |    |  |    |",
  "|\\____\\       |____|  /|____ '     /|   /___//        |____|  |____|",
  "| |    |      |    | / |    /_____/ |  |\\`  |         |    |  |    |",
  " \\|____|      |____|/  |____|     | /  |____|         |____|  |____|",
  "    \\(          )/       \\( |_____|/     \\(             \\(      )/  ",
  "     '          '         '    )/         '              '      '   ",
  "                               '                                    ",
  },

  -- Diagnostics configuration (for vim.diagnostics.config({...}))
  diagnostics = {
    virtual_text = false,
    underline = true,
  },
  lsp = {
    formatting = {
      format_on_save = false
    }

  },

  mappings = {
    n = {
      ["<leader>bn"] = { "<cmd>BufferLineCycleNext<cr>", desc = "Buffer next" },
      ["<leader>bp"] = { "<cmd>BufferLineCyclePrev<cr>", desc = "Buffer prev" },
    },
    t = {
    },
  },

  -- Configure plugins
  plugins = {
    init = {
      {'folke/tokyonight.nvim'},
      ["L3MON4D3/LuaSnip"] = {disable = true},

    },
    treesitter = { -- overrides `require("treesitter").setup(...)`
      ensure_installed = { "lua", "haskell", "java", "kotlin", "javascript" },
    },
    -- use mason-lspconfig to configure LSP installations
    ["mason-lspconfig"] = { -- overrides `require("mason-lspconfig").setup(...)`
      ensure_installed = {},
    },
    -- use mason-tool-installer to configure DAP/Formatters/Linter installation
    ["mason-tool-installer"] = { -- overrides `require("mason-tool-installer").setup(...)`
      ensure_installed = {},
    },
    packer = { -- overrides `require("packer").setup(...)`
      compile_path = vim.fn.stdpath "data" .. "/packer_compiled.lua",
    },
  },

  -- Modify which-key registration (Use this with mappings table in the above.)
  ["which-key"] = {
    -- Add bindings which show up as group name
    register_mappings = {
      -- first key is the mode, n == normal mode
      n = {
        -- second key is the prefix, <leader> prefixes
        ["<leader>"] = {
          -- third key is the key to bring up next level and its displayed
          -- group name in which-key top level menu
          ["b"] = { name = "Buffer" },
        },
      },
    },
  },
  telescope = {
    defaults = {
      prompt_prefix = "  ",
      initial_mode = "normal",
      borderchars = {
        prompt = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
        results = { "─", "▐", "─", "│", "╭", "▐", "▐", "╰" },
        preview = { " ", "│", " ", "▌", "▌", "╮", "╯", "▌" },
      },
      selection_caret = "  ",
      layout_config = {
        width = 0.90,
        height = 0.85,
        preview_cutoff = 120,
        horizontal = {
          preview_width = function(_, cols, _)
            return math.floor(cols * 0.6)
          end,
        },
        vertical = {
          width = 0.9,
          height = 0.95,
          preview_height = 0.5,
        },
        flex = {
          horizontal = {
            preview_width = 0.9,
          },
        },
      },
      layout_strategy = "horizontal",
    },
  },

  -- This function is run last and is a good place to configuring
  -- augroups/autocommands and custom filetypes also this just pure lua so
  -- anything that doesn't fit in the normal config locations above can go here
  polish = function()
    -- Set key binding
    -- Set autocommands
    vim.cmd [[autocmd VimEnter,ColorScheme * lua require("user.theme").telescope_theme()]]
    vim.api.nvim_create_augroup("packer_conf", { clear = true })
    vim.api.nvim_create_autocmd("BufWritePost", {
      desc = "Sync packer after modifying plugins.lua",
      group = "packer_conf",
      pattern = "plugins.lua",
      command = "source <afile> | PackerSync",
    })
    vim.api.nvim_set_hl(0,"VertSplit",{fg = require"tokyonight.colors".setup().fg_gutter})
  end,
}

return config
