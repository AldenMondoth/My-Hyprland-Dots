local home = os.getenv("HOME")
local themed_colors = require("wallust-colors.wallust-hyprland")
local defaults = {

	editor = os.getenv("EDITOR") or "nano",
	colors = themed_colors,

	term = "kitty",
	files = "thunar",
	music = "spotify",

	Search_Engine = "https://www.google.com/search?q={}",
	scriptsDir = home .. "/.config/hypr/UserScripts",
	UserConfigs = home .. "/.config/hypr/UserConfigs",
}

return defaults
