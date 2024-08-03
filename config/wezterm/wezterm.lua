local wezterm = require("wezterm")

local config = {

  -- Comment this out on linux
  -- Probably can do this with launcher but need to figure it out
  default_prog = { 'pwsh.exe', '-NoLogo' },

  color_scheme = "tokyonight_storm",
  window_background_opacity = 0.85,
  enable_tab_bar = false,
  window_decorations = "RESIZE",
  window_close_confirmation = "NeverPrompt",
  window_padding = {
    left = 2,
    right = 2,
    top = 2,
    bottom = 2,
  },

  -- font config
  font = wezterm.font("Monaspace Neon", { weight = "Regular" }),
  font_rules = {
    {
      italic = true,
      font = wezterm.font("Monaspace Radon", { weight = "Medium" }),
    },
  },
  harfbuzz_features = { "calt", "dlig", "clig=1", "ss01", "ss02", "ss03", "ss04", "ss05", "ss06", "ss07", "ss08" },
  font_size = 16,
  line_height = 1.1,
  adjust_window_size_when_changing_font_size = false,

  -- keys config
  send_composed_key_when_left_alt_is_pressed = true,
  send_composed_key_when_right_alt_is_pressed = false,

  window_background_gradient = {
    orientation = "Horizontal",
    colors = {
      -- "#0f0c29",
      -- "#1e1e2d",
      -- "#302b63",
      "#00000C",
      -- "#00003F",
      "#000026",
      "#00000C",
      -- "#24243e",
      -- "#1e1e2d",
      -- "#0f0c29",
    },
    interpolation = "CatmullRom",
    blend = "Rgb",
    noise = 0,
  },
}

return config
