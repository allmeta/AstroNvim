local status_ok, heirline = pcall(require, "heirline")
if not status_ok or not astronvim.status then return end
local C = require "default_theme.colors"

local function setup_colors()
  local statusline = astronvim.get_hlgroup("StatusLine", { fg = C.fg, bg = C.grey_4 })
  local winbar = astronvim.get_hlgroup("WinBar", { fg = C.grey_2, bg = C.bg })
  local winbarnc = astronvim.get_hlgroup("WinBarNC", { fg = C.grey, bg = C.bg })
  local conditional = astronvim.get_hlgroup("Conditional", { fg = C.purple_1, bg = C.grey_4 })
  local string = astronvim.get_hlgroup("String", { fg = C.green, bg = C.grey_4 })
  local typedef = astronvim.get_hlgroup("TypeDef", { fg = C.yellow, bg = C.grey_4 })
  local heirlinenormal = astronvim.get_hlgroup("HerlineNormal", { fg = C.blue, bg = C.grey_4 })
  local heirlineinsert = astronvim.get_hlgroup("HeirlineInsert", { fg = C.green, bg = C.grey_4 })
  local heirlinevisual = astronvim.get_hlgroup("HeirlineVisual", { fg = C.purple, bg = C.grey_4 })
  local heirlinereplace = astronvim.get_hlgroup("HeirlineReplace", { fg = C.red_1, bg = C.grey_4 })
  local heirlinecommand = astronvim.get_hlgroup("HeirlineCommand", { fg = C.yellow_1, bg = C.grey_4 })
  local heirlineinactive = astronvim.get_hlgroup("HeirlineInactive", { fg = C.grey_7, bg = C.grey_4 })
  local gitsignsadd = astronvim.get_hlgroup("GitSignsAdd", { fg = C.green, bg = C.grey_4 })
  local gitsignschange = astronvim.get_hlgroup("GitSignsChange", { fg = C.orange_1, bg = C.grey_4 })
  local gitsignsdelete = astronvim.get_hlgroup("GitSignsDelete", { fg = C.red_1, bg = C.grey_4 })
  local diagnosticerror = astronvim.get_hlgroup("DiagnosticError", { fg = C.red_1, bg = C.grey_4 })
  local diagnosticwarn = astronvim.get_hlgroup("DiagnosticWarn", { fg = C.orange_1, bg = C.grey_4 })
  local diagnosticinfo = astronvim.get_hlgroup("DiagnosticInfo", { fg = C.white_2, bg = C.grey_4 })
  local diagnostichint = astronvim.get_hlgroup("DiagnosticHint", { fg = C.yellow_1, bg = C.grey_4 })
  local colors = astronvim.user_plugin_opts("heirline.colors", {
    fg = statusline.fg,
    bg = statusline.bg,
    section_fg = statusline.fg,
    section_bg = statusline.bg,
    branch_fg = conditional.fg,
    ts_fg = string.fg,
    scrollbar = typedef.fg,
    git_add = gitsignsadd.fg,
    git_change = gitsignschange.fg,
    git_del = gitsignsdelete.fg,
    diag_error = diagnosticerror.fg,
    diag_warn = diagnosticwarn.fg,
    diag_info = diagnosticinfo.fg,
    diag_hint = diagnostichint.fg,
    normal = astronvim.status.hl.lualine_mode("normal", heirlinenormal.fg),
    insert = astronvim.status.hl.lualine_mode("insert", heirlineinsert.fg),
    visual = astronvim.status.hl.lualine_mode("visual", heirlinevisual.fg),
    replace = astronvim.status.hl.lualine_mode("replace", heirlinereplace.fg),
    command = astronvim.status.hl.lualine_mode("command", heirlinecommand.fg),
    inactive = heirlineinactive.fg,
    winbar_fg = winbar.fg,
    winbar_bg = winbar.bg,
    winbarnc_fg = winbarnc.fg,
    winbarnc_bg = winbarnc.bg,
  })

  for _, section in ipairs { "branch", "file", "git", "diagnostic", "lsp", "ts", "nav" } do
    if not colors[section .. "_bg"] then colors[section .. "_bg"] = colors["section_bg"] end
    if not colors[section .. "_fg"] then colors[section .. "_fg"] = colors["section_fg"] end
  end
  return colors
end

-- define Heirline sections
function astronvim.status.component.left_mode()
  return astronvim.status.utils.surround(
    "left",
    astronvim.status.hl.mode_bg,
    { provider = astronvim.status.provider.str { str = " " } }
  )
end

function astronvim.status.component.right_mode()
  return astronvim.status.utils.surround(
    "right",
    astronvim.status.hl.mode_bg,
    { provider = astronvim.status.provider.str { str = " " } }
  )
end

function astronvim.status.component.git_branch()
  return {
    condition = astronvim.status.condition.is_git_repo,
    hl = { fg = "branch_fg" },
    astronvim.status.utils.surround("left", "branch_bg", {
      provider = astronvim.status.provider.git_branch { icon = { kind = "GitBranch", padding = { right = 1 } } },
      hl = { bold = true },
      on_click = {
        name = "heirline_branch",
        callback = function()
          if astronvim.is_available "telescope.nvim" then
            vim.defer_fn(function() require("telescope.builtin").git_branches() end, 100)
          end
        end,
      },
    }),
  }
end

function astronvim.status.component.git_diff()
  return {
    condition = astronvim.status.condition.git_changed,
    hl = { fg = "git_fg" },
    astronvim.status.component.builder {
      {
        provider = "git_diff",
        opts = { type = "added", icon = { kind = "GitAdd", padding = { left = 1, right = 1 } } },
        hl = { fg = "git_add" },
      },
      {
        provider = "git_diff",
        opts = { type = "changed", icon = { kind = "GitChange", padding = { left = 1, right = 1 } } },
        hl = { fg = "git_change" },
      },
      {
        provider = "git_diff",
        opts = { type = "removed", icon = { kind = "GitDelete", padding = { left = 1, right = 1 } } },
        hl = { fg = "git_del" },
      },
      on_click = {
        name = "heirline_git",
        callback = function()
          if astronvim.is_available "telescope.nvim" then
            vim.defer_fn(function() require("telescope.builtin").git_status() end, 100)
          end
        end,
      },
      surround = { separator = "left", color = "git_bg" },
    },
  }
end

function astronvim.status.component.diagnostics()
  return {
    condition = astronvim.status.condition.has_diagnostics,
    hl = { fg = "diagnostic_fg" },
    astronvim.status.component.builder {
      {
        provider = "diagnostics",
        opts = { severity = "ERROR", icon = { kind = "DiagnosticError", padding = { left = 1, right = 1 } } },
        hl = { fg = "diag_error" },
      },
      {
        provider = "diagnostics",
        opts = { severity = "WARN", icon = { kind = "DiagnosticWarn", padding = { left = 1, right = 1 } } },
        hl = { fg = "diag_warn" },
      },
      {
        provider = "diagnostics",
        opts = { severity = "INFO", icon = { kind = "DiagnosticInfo", padding = { left = 1, right = 1 } } },
        hl = { fg = "diag_info" },
      },
      {
        provider = "diagnostics",
        opts = { severity = "HINT", icon = { kind = "DiagnosticHint", padding = { left = 1, right = 1 } } },
        hl = { fg = "diag_hint" },
      },
      on_click = {
        name = "heirline_diagnostic",
        callback = function()
          if astronvim.is_available "telescope.nvim" then
            vim.defer_fn(function() require("telescope.builtin").diagnostics() end, 100)
          end
        end,
      },
      surround = { separator = "left", color = "diagnostic_bg" },
    },
  }
end

function astronvim.status.component.lsp()
  return {
    condition = astronvim.status.condition.lsp_attached,
    hl = { fg = "lsp_fg" },
    astronvim.status.utils.surround("right", "lsp_bg", {
      astronvim.status.utils.make_flexible(
        1,
        { provider = astronvim.status.provider.lsp_progress { padding = { right = 1 } } },
        { provider = "" }
      ),
      astronvim.status.utils.make_flexible(2, {
        provider = astronvim.status.provider.lsp_client_names {
          icon = { kind = "ActiveLSP", padding = { right = 2 } },
        },
      }, {
        provider = astronvim.status.provider.str { str = "LSP", icon = { kind = "ActiveLSP", padding = { right = 2 } } },
      }),
      on_click = {
        name = "heirline_lsp",
        callback = function()
          vim.defer_fn(function() vim.cmd "LspInfo" end, 100)
        end,
      },
    }),
  }
end

function astronvim.status.component.treesitter()
  return {
    condition = astronvim.status.condition.treesitter_available,
    hl = { fg = "ts_fg" },
    astronvim.status.utils.surround("right", "ts_bg", {
      provider = astronvim.status.provider.str { str = "TS", icon = { kind = "ActiveTS" } },
    }),
  }
end

heirline.load_colors(setup_colors())
local heirline_opts = astronvim.user_plugin_opts("plugins.heirline", {
  {
    hl = { fg = "fg", bg = "bg" },
    astronvim.status.component.left_mode(),
    astronvim.status.component.git_branch(),
    {
      condition = astronvim.status.condition.has_filetype,
      hl = { fg = "file_fg" },
      astronvim.status.component.file_info(astronvim.is_available "bufferline.nvim" and {
        file_icon = { padding = { left = 1 } },
        filetype = {},
        filename = false,
        file_modified = false,
        surround = { separator = "left", color = "file_bg" },
      } or { file_icon = { padding = { left = 1 } }, surround = { separator = "left", color = "file_bg" } }),
    },
    astronvim.status.component.git_diff(),
    astronvim.status.component.diagnostics(),
    astronvim.status.component.fill(),
    astronvim.status.component.lsp(),
    astronvim.status.component.treesitter(),
    {
      hl = { fg = "nav_fg" },
      astronvim.status.component.nav { surround = { separator = "right", color = "nav_bg" } },
    },
    astronvim.status.component.right_mode(),
  },
  {
    init = astronvim.status.init.pick_child_on_condition,
    {
      condition = function() return astronvim.status.condition.buffer_matches { buftype = { "terminal" } } end,
      init = function() vim.opt_local.winbar = nil end,
    },
    {
      condition = astronvim.status.condition.is_active,
      astronvim.status.component.breadcrumbs { padding = { left = 1 } },
    },
    {
      astronvim.status.component.file_info {
        file_icon = { highlight = false, padding = { left = 1 } },
        padding = { left = 1 },
      },
    },
  },
})
heirline.setup(heirline_opts[1], heirline_opts[2])

vim.api.nvim_create_augroup("Heirline", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
  group = "Heirline",
  desc = "Refresh heirline colors",
  callback = function()
    heirline.reset_highlights()
    heirline.load_colors(setup_colors())
  end,
})
vim.api.nvim_create_autocmd("User", {
  pattern = "HeirlineInitWinbar",
  group = "Heirline",
  desc = "Disable winbar for some windows",
  callback = function(args)
    local buftype = vim.tbl_contains({ "prompt", "nofile", "help", "quickfix" }, vim.bo[args.buf].buftype)
    local filetype =
      vim.tbl_contains({ "NvimTree", "neo-tree", "dashboard", "Outline", "aerial" }, vim.bo[args.buf].filetype)
    if buftype or filetype then vim.opt_local.winbar = nil end
  end,
})
