#!/bin/bash

# Toggle between two refresh rates for a specified monitor in Hyprland
# and switch power profiles and brightness accordingly
# Usage: ./toggle_refresh_rate.sh

# Configuration
MONITOR="eDP-2"             # Your monitor identifier
RESOLUTION="3840x2400"      # Your monitor resolution
SCALING="1.5"               # Your scaling factor
RATE1="120.00000"           # First refresh rate (high performance)
RATE2="60.00000"            # Second refresh rate (power saving)
PROFILE1="balanced"         # Power profile for high refresh rate
PROFILE2="power-saver"      # Power profile for low refresh rate
BRIGHTNESS1="80%"           # Brightness for high refresh rate
BRIGHTNESS2="50%"           # Brightness for low refresh rate
BACKLIGHT="intel_backlight" # Your backlight device

# Get current refresh rate with more reliable parsing
CURRENT_RATE=$(hyprctl monitors -j | jq -r ".[] | select(.name == \"$MONITOR\") | .refreshRate")

# Log current status (optional, helpful for debugging)
echo "Monitor: $MONITOR, Current refresh rate: $CURRENT_RATE"

# Compare floating point values properly
if (($(echo "$CURRENT_RATE == $RATE1" | bc -l))); then
  # Switch to power saving mode
  NEW_RATE=$RATE2
  NEW_PROFILE=$PROFILE2
  NEW_BRIGHTNESS=$BRIGHTNESS2
  echo "Switching to $NEW_RATE Hz, $NEW_PROFILE power profile, and $NEW_BRIGHTNESS brightness"
else
  # Switch to performance mode
  NEW_RATE=$RATE1
  NEW_PROFILE=$PROFILE1
  NEW_BRIGHTNESS=$BRIGHTNESS1
  echo "Switching to $NEW_RATE Hz, $NEW_PROFILE power profile, and $NEW_BRIGHTNESS brightness"
fi

# Apply the new monitor configuration
if (($(echo "$NEW_RATE == $RATE1" | bc -l))); then
  # Use preferred for performance mode
  hyprctl keyword monitor "$MONITOR,preferred,auto,$SCALING"
else
  # Use explicit resolution and refresh rate for power saving mode
  hyprctl keyword monitor "$MONITOR,$RESOLUTION@$NEW_RATE,auto,$SCALING"
fi

# Apply the new power profile
if command -v powerprofilesctl >/dev/null 2>&1; then
  powerprofilesctl set $NEW_PROFILE
  PROFILE_STATUS="Power profile: $NEW_PROFILE"
else
  PROFILE_STATUS="powerprofilesctl not found - power profile unchanged"
  echo "Warning: powerprofilesctl not found. Install power-profiles-daemon package."
fi

# Set brightness
if command -v brightnessctl >/dev/null 2>&1; then
  brightnessctl -d $BACKLIGHT s $NEW_BRIGHTNESS
  BRIGHTNESS_STATUS="Brightness: $NEW_BRIGHTNESS"
else
  BRIGHTNESS_STATUS="brightnessctl not found - brightness unchanged"
  echo "Warning: brightnessctl not found. Install brightnessctl package."
fi

# Notify user of the changes (requires notify-send from libnotify)
if command -v notify-send >/dev/null 2>&1; then
  notify-send "Power & Display Settings" "Refresh: $NEW_RATE Hz\n$PROFILE_STATUS\n$BRIGHTNESS_STATUS" --icon=battery
fi
