#### COLOUR

tm_color_active=colour39
tm_color_inactive=colour241
tm_color_feature=colour198
tm_color_music=colour215
tm_active_border_color=colour39

# separators
tm_separator_left_bold="◀"
tm_separator_left_thin="❮"
tm_separator_right_bold="▶"
tm_separator_right_thin="❯"

set -g status-left-length 32
set -g status-right-length 150
set -g status-interval 5

# default statusbar colors
# set-option -g status-bg colour0
set-option -g status-fg $tm_color_active
set-option -g status-bg default
set-option -g status-attr default

# default window title colors
set-window-option -g window-status-fg $tm_color_inactive
set-window-option -g window-status-bg default
set -g window-status-format "#I #W"

# active window title colors
set-window-option -g window-status-current-fg $tm_color_active
set-window-option -g window-status-current-bg default
set-window-option -g  window-status-current-format "#[bold]#I #W"

# pane border
set-option -g pane-border-fg $tm_color_inactive
set-option -g pane-active-border-fg $tm_active_border_color

# message text
set-option -g message-bg default
set-option -g message-fg $tm_color_active

# pane number display
set-option -g display-panes-active-colour $tm_color_active
set-option -g display-panes-colour $tm_color_inactive

# clock
set-window-option -g clock-mode-colour $tm_color_active

tm_tunes="#[fg=$tm_color_music]#(osascript ~/.dotfiles/applescripts/tunes.scpt | cut -c 1-50)"
# tm_tunes="#[fg=$tm_color_music]#(osascript -l JavaScript ~/.dotfiles/applescripts/spotify.js)"
tm_battery="#(~/.dotfiles/bin/battery_indicator.sh)"


tm_date="#[fg=$tm_color_inactive] %R %d %b"
tm_host="#[fg=$tm_color_feature,bold]#h"
tm_session_name="#[fg=$tm_color_feature,bold]#S"

tm_CPU="#[fg=$tm_color_active]#(/usr/local/Cellar/tmux-mem-cpu-load/3.4.0/bin/tmux-mem-cpu-load --interval 2)#[default]"

set -g status-left $tm_session_name' '
set -g status-right $tm_CPU' '$tm_battery' '$tm_date' '$tm_host