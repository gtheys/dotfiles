local wezterm = require("wezterm")


local SOLID_LEFT_ARROW = wezterm.nerdfonts.pl_right_hard_divider
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.pl_left_hard_divider

function tab_title(tab_info)
  local title = tab_info.tab_title
  if title and #title > 0 then
    return title
  end
  return tab_info.active_pane.title
end

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local edge_background = '#1a1b26' -- Dark background
  local background = '#24283b'      -- Slightly lighter background for inactive tabs
  local foreground = '#c0caf5'      -- Light foreground for text

  if tab.is_active then
    background = '#7aa2f7' -- Bright blue for active tab
    foreground = '#1a1b26' -- Dark text for contrast on active tab
  elseif hover then
    background = '#3d59a1' -- Medium blue for hover state
    foreground = '#c0caf5' -- Light text for hover state
  end

  local edge_foreground = background
  local title = tab_title(tab)
  title = wezterm.truncate_right(title, max_width - 2)

  return {
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_LEFT_ARROW },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = ' ' .. title .. ' ' },
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_RIGHT_ARROW },
  }
end)

local config = {

  -- Comment this out on linux
  -- Probably can do this with launcher but need to figure it out
  default_prog = { 'pwsh.exe', '-NoLogo' },

  color_scheme = "tokyonight_storm",
  window_background_opacity = 0.85,
  enable_tab_bar = true, -- Enable the tab bar
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
      "#00000C",
      "#000026",
      "#00000C",
    },
    interpolation = "CatmullRom",
    blend = "Rgb",
    noise = 0,
  },
  -- Add this new section for the window frame
  window_frame = {
    active_titlebar_bg = "#00000C",
    inactive_titlebar_bg = "#00000C",
  }
}

return config
