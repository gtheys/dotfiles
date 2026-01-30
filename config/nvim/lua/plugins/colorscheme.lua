return {
  -- AIDEV-NOTE: Set tokyonight-storm as the default LazyVim colorscheme
  -- lazy=false and priority ensure it loads before other plugins
  -- on_highlights clears Normal bg for terminal transparency
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "storm",
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
      on_highlights = function(hl, c)
        hl.Normal = { fg = c.fg, bg = "NONE" }
        hl.NormalFloat = { fg = c.fg, bg = "NONE" }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight-storm",
    },
  },
}
