local defaults = require("UserConfigs.UserDefaults")

hl.on("hyprland.start", function()
	hl.exec_cmd("waybar")
	hl.exec_cmd("awww-daemon --format xrgb")
	hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	hl.exec_cmd("~/.config/hypr/scripts/Dropterminal.sh kitty &")
	hl.exec_cmd(defaults.scriptsDir .. "/Polkit.sh")
	hl.exec_cmd(" nm-applet --indicator")
	hl.exec_cmd("nm-tray")
	hl.exec_cmd("swaync")
	hl.exec_cmd("qs -c overview")
	hl.exec_cmd("hypridle")
	hl.exec_cmd(defaults.scriptsDir .. "/Hyprsunset.sh init")
	hl.exec_cmd("wl-paste --type text --watch cliphist store")
	hl.exec_cmd("rog-control-center")
	hl.exec_cmd("blueman-applet")
	hl.exec_cmd("ags")
	hl.exec_cmd(defaults.scriptsDir .. "/KeyBindsLayoutInit.sh")
end)

-- Rainbow borders (disabled by default; use quick settings menu)
--exec-once = $UserScripts/RainbowBorders.sh

-- Here are list of features available but disabled by default
-- Persistent wallpaper
-- exec-once = swww-daemon --format xrgb && swww img $wallDIR/mecha-nostalgia.png

-- Gnome polkit for NixOS
-- exec-once = $scriptsDir/Polkit-NixOS.sh

-- xdg-desktop-portal-hyprland (should be auto starting. However, you can force to start)
-- exec-once = $scriptsDir/PortalHyprland.sh
