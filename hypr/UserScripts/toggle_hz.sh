#!/usr/bin/zsh

#sudo priv

STATUS = $(hyprctl monitors | grep -refresh)

if [[ "$STATUS" == *"240"* ]]; then
	hyprctl keyword monitor eDP-2, 2560x1600@60, 0x0,1.25
	notify-send "Power Save" "refresh rate set to 60 Hz"
else 
	hyprctl keyword monitor eDP-2, 2560x1600@240, 0x0,1.25 
  notify-send "Performance" "refresh rate set to 240 Hz"
fi

hyprctl reload
