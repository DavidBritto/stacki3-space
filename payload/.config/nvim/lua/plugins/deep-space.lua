local palette = {
  bg = "#000000",
  surface = "#050711",
  elevated = "#0b1020",
  accent = "#4961da",
  accent_hover = "#5b72ff",
  purple = "#7c5cff",
  purple_bright = "#9d7cff",
  cyan = "#67c9e4",
  cyan_bright = "#8be9fd",
  yellow = "#f0c674",
  text = "#b8cdfe",
  text_bright = "#d7e0ff",
  dim = "#444b6f",
  white = "#ffffff",
  error = "#ff6b9d",
}

local function deep_space_lualine()
  return {
    normal = {
      a = { bg = palette.accent, fg = palette.white, gui = "bold" },
      b = { bg = palette.elevated, fg = palette.text },
      c = { bg = palette.bg, fg = palette.text },
    },
    insert = {
      a = { bg = palette.cyan, fg = palette.bg, gui = "bold" },
      b = { bg = palette.elevated, fg = palette.text },
      c = { bg = palette.bg, fg = palette.text },
    },
    visual = {
      a = { bg = palette.purple, fg = palette.white, gui = "bold" },
      b = { bg = palette.elevated, fg = palette.text },
      c = { bg = palette.bg, fg = palette.text },
    },
    replace = {
      a = { bg = palette.error, fg = palette.bg, gui = "bold" },
      b = { bg = palette.elevated, fg = palette.text },
      c = { bg = palette.bg, fg = palette.text },
    },
    command = {
      a = { bg = palette.yellow, fg = palette.bg, gui = "bold" },
      b = { bg = palette.elevated, fg = palette.text },
      c = { bg = palette.bg, fg = palette.text },
    },
    inactive = {
      a = { bg = palette.surface, fg = palette.dim },
      b = { bg = palette.surface, fg = palette.dim },
      c = { bg = palette.bg, fg = palette.dim },
    },
  }
end

return {
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "night",
      light_style = "night",
      transparent = false,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = false },
        functions = {},
        variables = {},
        sidebars = "dark",
        floats = "dark",
      },
      on_colors = function(colors)
        colors.bg = palette.bg
        colors.bg_dark = palette.bg
        colors.bg_float = palette.surface
        colors.bg_highlight = palette.elevated
        colors.bg_popup = palette.surface
        colors.bg_search = palette.accent
        colors.bg_sidebar = palette.bg
        colors.bg_statusline = palette.bg
        colors.bg_visual = palette.accent
        colors.border = palette.purple
        colors.blue = palette.accent
        colors.blue0 = palette.accent
        colors.blue1 = palette.accent_hover
        colors.blue2 = palette.accent_hover
        colors.blue5 = palette.accent_hover
        colors.blue6 = palette.cyan
        colors.blue7 = palette.cyan_bright
        colors.cyan = palette.cyan
        colors.fg = palette.text
        colors.fg_dark = palette.text
        colors.fg_float = palette.text_bright
        colors.fg_gutter = palette.dim
        colors.fg_sidebar = palette.text
        colors.git = {
          add = palette.cyan,
          change = palette.accent_hover,
          delete = palette.error,
        }
        colors.green = palette.cyan
        colors.magenta = palette.purple
        colors.magenta2 = palette.purple_bright
        colors.orange = palette.yellow
        colors.purple = palette.purple
        colors.red = palette.error
        colors.terminal = {
          black = palette.bg,
          black_bright = palette.dim,
          blue = palette.accent,
          blue_bright = palette.accent_hover,
          cyan = palette.cyan,
          cyan_bright = palette.cyan_bright,
          green = palette.cyan,
          green_bright = palette.cyan_bright,
          magenta = palette.purple,
          magenta_bright = palette.purple_bright,
          red = palette.purple,
          red_bright = palette.purple_bright,
          white = palette.text,
          white_bright = palette.white,
          yellow = palette.yellow,
          yellow_bright = palette.yellow,
        }
        colors.yellow = palette.yellow
      end,
      on_highlights = function(hl, colors)
        hl.DeepSpaceAccent = { fg = palette.cyan }
        hl.Normal = { bg = palette.bg, fg = palette.text }
        hl.NormalFloat = { bg = palette.surface, fg = palette.text_bright }
        hl.FloatBorder = { bg = palette.surface, fg = palette.purple }
        hl.Cursor = { bg = palette.cyan, fg = palette.bg }
        hl.CursorLine = { bg = palette.surface }
        hl.CursorLineNr = { fg = palette.cyan, bold = true }
        hl.LineNr = { fg = palette.dim }
        hl.Visual = { bg = palette.accent }
        hl.Search = { bg = palette.accent, fg = palette.white }
        hl.IncSearch = { bg = palette.purple, fg = palette.white }
        hl.Pmenu = { bg = palette.surface, fg = palette.text }
        hl.PmenuSel = { bg = palette.accent, fg = palette.white }
        hl.WinSeparator = { fg = palette.elevated }
        hl.StatusLine = { bg = palette.bg, fg = palette.text }
        hl.StatusLineNC = { bg = palette.bg, fg = palette.dim }
        hl.TabLineSel = { bg = palette.accent, fg = palette.white, bold = true }
        hl.TabLine = { bg = palette.surface, fg = palette.dim }
        hl.DiagnosticError = { fg = palette.error }
        hl.DiagnosticWarn = { fg = palette.yellow }
        hl.DiagnosticInfo = { fg = palette.cyan }
        hl.DiagnosticHint = { fg = palette.purple_bright }
        hl.TelescopeBorder = { fg = palette.purple, bg = palette.surface }
        hl.TelescopeNormal = { fg = palette.text, bg = palette.surface }
        hl.TelescopePromptBorder = { fg = palette.cyan, bg = palette.surface }
        hl.TelescopeSelection = { bg = palette.accent, fg = palette.white }
        hl.WhichKeyBorder = { fg = palette.purple, bg = palette.surface }
        hl.WhichKeyNormal = { fg = palette.text, bg = palette.surface }
        hl.LazyNormal = { fg = palette.text, bg = palette.surface }
        hl.LazyButton = { fg = palette.text, bg = palette.elevated }
        hl.LazyButtonActive = { fg = palette.white, bg = palette.accent }
        hl.NeoTreeNormal = { fg = palette.text, bg = palette.bg }
        hl.NeoTreeNormalNC = { fg = palette.text, bg = palette.bg }
        hl.NeoTreeDirectoryName = { fg = palette.cyan }
        hl.NeoTreeGitModified = { fg = palette.yellow }
        hl.NeoTreeGitAdded = { fg = palette.cyan }
        hl.NeoTreeGitDeleted = { fg = palette.error }
        hl.BufferLineFill = { bg = palette.bg }
        hl.BufferLineBackground = { bg = palette.bg, fg = palette.dim }
        hl.BufferLineBufferSelected = { bg = palette.surface, fg = palette.white, bold = true }
        hl.BufferLineIndicatorSelected = { fg = palette.cyan, bg = palette.surface }
        hl.SnacksDashboardHeader = { fg = palette.cyan }
        hl.SnacksDashboardIcon = { fg = palette.purple }
        hl.SnacksDashboardKey = { fg = palette.yellow }
        hl.SnacksDashboardDesc = { fg = palette.text }
        hl.SnacksDashboardFooter = { fg = palette.dim }
        hl.MarkdownHeadingDelimiter = { fg = palette.purple }
        hl.RenderMarkdownH1Bg = { bg = palette.surface, fg = palette.cyan, bold = true }
        hl.RenderMarkdownH2Bg = { bg = palette.surface, fg = palette.purple_bright, bold = true }

        hl.DiffAdd = { bg = colors.diff.add }
        hl.DiffChange = { bg = colors.diff.change }
        hl.DiffDelete = { bg = colors.diff.delete }
        hl.DiffText = { bg = colors.diff.text }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight-night",
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.theme = deep_space_lualine()
      opts.options.globalstatus = true
    end,
  },
}
