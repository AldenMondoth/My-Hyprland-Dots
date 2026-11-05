#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */
# Wallust: derive colors from the current wallpaper and update templates
# Supports awww, Kitty, Rofi, and Waybar.
# Usage: WallustSwww.sh [absolute_path_to_wallpaper]

set -euo pipefail

# Inputs and paths
passed_path="${1:-}"

rofi_link="$HOME/.config/rofi/.current_wallpaper"
wallpaper_current="$HOME/.config/hypr/wallpaper_effects/.wallpaper_current"
kitty_wallust="$HOME/.config/kitty/kitty-themes/01-Wallust.conf"

# Get the focused monitor name
get_focused_monitor() {
  if command -v jq >/dev/null 2>&1; then
    hyprctl monitors -j | jq -r '.[] | select(.focused) | .name'
  else
    hyprctl monitors | awk '/^Monitor/{name=$2} /focused: yes/{print name}'
  fi
}

# Read the current wallpaper path from awww
read_wallpaper_from_query() {
  local monitor="$1"

  awww query | awk -v mon="$monitor" '
    index($0, mon ":") && /currently displaying:/ {
      sub(/^.*currently displaying: [Ii]mage: /, "")
      print
      exit
    }
  '
}

# Determine wallpaper path
wallpaper_path=""

if [[ -n "$passed_path" && -f "$passed_path" ]]; then
  wallpaper_path="$passed_path"
else
  current_monitor="$(get_focused_monitor)"

  if [[ -n "$current_monitor" ]]; then
    wallpaper_path="$(read_wallpaper_from_query "$current_monitor" || true)"
  fi
fi

# Stop if no valid wallpaper can be found
if [[ -z "$wallpaper_path" || ! -f "$wallpaper_path" ]]; then
  echo "Wallust: Could not determine the current wallpaper." >&2
  exit 1
fi

# Update wallpaper references
mkdir -p "$(dirname "$rofi_link")"
ln -sf "$wallpaper_path" "$rofi_link"

mkdir -p "$(dirname "$wallpaper_current")"
cp -f "$wallpaper_path" "$wallpaper_current"

# Ensure Kitty configuration directory exists
mkdir -p "$(dirname "$kitty_wallust")"

# Run Wallust to regenerate configured templates
if ! wallust run -s "$wallpaper_path"; then
  echo "Wallust: Failed to generate colors for $wallpaper_path" >&2
  notify-send -i "$HOME/.config/swaync/images/error.png" \
    "Wallust error" \
    "Failed to generate wallpaper colors"
  exit 1
fi

# Verify that the expected templates were generated
wallust_targets=(
  "$HOME/.config/waybar/wallust/colors-waybar.css"
  "$HOME/.config/rofi/wallust/colors-rofi.rasi"
)

for file in "${wallust_targets[@]}"; do
  if [[ ! -s "$file" ]]; then
    echo "Wallust: Expected template missing or empty: $file" >&2
  fi
done

# Normalize legacy Kitty palette syntax if necessary
if [[ -f "$kitty_wallust" ]]; then
  sed -i -E \
    's/^([[:space:]]*palette[[:space:]]*=[[:space:]]*[0-9]{1,2}):/\1=/' \
    "$kitty_wallust"
fi

# Reload Kitty configuration
if command -v kitty >/dev/null 2>&1; then
  if pgrep -x kitty >/dev/null 2>&1; then
    while IFS= read -r pid; do
      kill -SIGUSR2 "$pid" 2>/dev/null || true
    done < <(pgrep -x kitty)
  fi
fi

# Reload Waybar
if command -v waybar-msg >/dev/null 2>&1; then
  waybar-msg cmd reload >/dev/null 2>&1 || true
elif pgrep -x waybar >/dev/null 2>&1; then
  pkill -SIGUSR2 -x waybar 2>/dev/null || true
fi

echo "Wallust: Updated colors for $wallpaper_path"
