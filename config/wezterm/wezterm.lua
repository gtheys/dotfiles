local os                = require 'os'
local wezterm           = require 'wezterm'
local act               = wezterm.action

local SOLID_LEFT_ARROW  = wezterm.nerdfonts.pl_right_hard_divider
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

  -- key configuration
  leader = {
    key = 'a',
    mods = 'CTRL',
    timeout_milliseconds = 2000,
  },
  keys = {

    {
      key = 'n',
      mods = 'LEADER',
      action = act.TogglePaneZoomState,
    },
    {
      key = ',',
      mods = 'LEADER',
      action = act.PromptInputLine {
        description = 'Enter new name for tab',
        action = wezterm.action_callback(
          function(window, pane, line)
            if line then
              window:active_tab():set_title(line)
            end
          end
        ),
      },
    },
    {
      key = 'c',
      mods = 'LEADER',
      action = act.SpawnTab 'CurrentPaneDomain',
    },
    {
      key = 'n',
      mods = 'LEADER',
      action = act.ActivateTabRelative(1),
    },
    {
      key = 'p',
      mods = 'LEADER',
      action = act.ActivateTabRelative(-1),
    },
    {
      key = 'w',
      mods = 'LEADER',
      action = act.ShowTabNavigator,
    },
    {
      key = '&',
      mods = 'LEADER',
      action = act.CloseCurrentTab { confirm = true },
    },
    -- Vertical split
    {
      -- |
      key = '$',
      mods = 'LEADER',
      action = act.SplitPane {
        direction = 'Right',
        size = { Percent = 50 },
      },
    },
    -- Horizontal split
    {
      -- -
      key = '-',
      mods = 'LEADER',
      action = act.SplitPane {
        direction = 'Down',
        size = { Percent = 50 },
      },
    },
    {
      -- |
      key = '¨',
      mods = 'LEADER|SHIFT',
      action = act.PaneSelect { mode = 'SwapWithActiveKeepFocus' }
    },
    {
      key = ';',
      mods = 'LEADER',
      action = act.ActivatePaneDirection('Prev'),
    },
    {
      key = 'o',
      mods = 'LEADER',
      action = act.ActivatePaneDirection('Next'),
    },

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

  pane_focus_follows_mouse = true,
  scrollback_lines = 5000,
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
