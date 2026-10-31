local home = os.getenv("HOME")

local defaults = {

	editor = os.getenv("EDITOR") or "nano",

	term = "kitty",
	files = "thunar",
	music = "spotify",

	Search_Engine = "https://www.google.com/search?q={}",
	scriptsDir = home .. "/.config/hypr/UserScripts",
	UserConfigs = home .. "/.config/hypr/UserConfigs",
}

return defaults
