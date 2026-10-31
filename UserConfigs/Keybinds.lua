local defaults = require("UserDefaults")

local function run_script(name)
	return dofile(defaults.scriptsDir .. "/" .. name .. ".lua")
end

hl.bind(
	"SUPER + D",
	hl.dsp.exec_cmd("pkill rofi || true && rofi -show drun -modi drun,filebrowser,run,window"),
	{ description = "app launcher" }
)

hl.bind("SUPER + B", hl.dsp.exec_cmd("xdg-open 'https://'"), { description = "open default browser" })

hl.bind("SUPER + A", hl.dsp.exec_cmd(defaults.scriptsDir .. "/OverviewToggle.sh"), { description = "desktop overview" }) -- toggles quickshell or ags overview (tries QS first, falls back to AGS)
hl.bind("SUPER + Return", hl.dsp.exec_cmd(defaults.term), { description = "Open Terminal" })

hl.bind("SUPER + Return", hl.dsp.exec_cmd(defaults.files), { description = "Open Terminal" })
hl.bind(
	"SUPER + T",
	hl.dsp.exec_cmd(defaults.scriptsDir .. "/ThemeChanger.sh"),
	{ description = "Wallust Global Theme Switcher" }
)

hl.bind("SUPER + H", hl.dsp.exec_cmd(defaults.scriptsDir .. "/KeyHints.sh"), { description = "cheat sheet" })
hl.bind(
	"SUPER + ALT + R",
	hl.dsp.exec_cmd(defaults.scriptsDir .. "/Refresh.sh"),
	{ description = "refresh bar and menus" }
)
hl.bind("SUPER + ALT + E", hl.dsp.exec_cmd(defaults.scriptsDir .. "/RofiEmoji.sh"), { description = "emoji menu" })

hl.bind("SUPER + S", hl.dsp.exec_cmd(defaults.music), { description = "open music player" })

hl.bind("SUPER + CTRL + S", hl.dsp.exec_cmd("rofi --show window"), { description = "window switcher" })

hl.bind("SUPER + ALT + O", hl.dsp.exec_cmd(defaults.scriptsDir .. "/ChangeBlur.sh"), { description = "toggle blur" })
hl.bind(
	"SUPER + SHIFT + G",
	hl.dsp.exec_cmd(defaults.scriptsDir .. "/GameMode.sh"),
	{ description = "toggle game mode" }
)
hl.bind("SUPER + ALT + L", function()
	run_script("ChangeLayout").toggle()
end, { description = "toggle layout" })
hl.bind(
	"SUPER + ALT + V",
	hl.dsp.exec_cmd(defaults.scriptsDir .. "/ClipManager.sh"),
	{ description = "clipboard manager" }
)
hl.bind(
	"SUPER + CTRL + R",
	hl.dsp.exec_cmd(defaults.scriptsDir .. "/RofiThemeSelector.sh"),
	{ description = "rofi theme selector" }
)
hl.bind(
	"SUPER + SHIFT + R",
	hl.dsp.exec_cmd("pkill rofi || true && " .. defaults.scriptsDir .. "/RofiThemeSelector-modified.sh"),
	{ description = "rofi theme selector (modified)" }
)

hl.bind("SUPER + SHIFT + F", hl.dsp.fullscreen(), { description = "fullscreen" })
hl.bind("SUPER + CTRL + F", hl.dsp.fullscreen(1), { description = "maximize windows" })
hl.bind("SUPER + SPACE", hl.dsp.window.float({ action = "toggle" }), { description = "float active window" })
hl.bind(
	"SUPER + ALT + SPACE",
	hl.dsp.exec_cmd("hyprctl dispatch workspaceopt allfloat"),
	{ description = "float all windows" }
)
hl.bind(
	"SUPER + SHIFT + Return",
	hl.dsp.exec_cmd(defaults.scriptsDir .. "/Dropterminal.sh " .. defaults.term),
	{ description = "DropDown terminal" }
)

-- Zoom using mouse
hl.bind("SUPER + ALT + mouse_down", function()
	local factor = hl.get_config("cursor.zoom_factor")
	factor = math.max(factor, 1.0)

	hl.config({
		cursor = {
			zoom_factor = factor * 2.0,
		},
	})
end, {
	description = "Zoom in",
})
hl.bind("SUPER + ALT + mouse_up", function()
	local factor = hl.get_config("cursor.zoom_factor")
	factor = math.max(factor, 1.0)

	hl.config({
		cursor = {
			zoom_factor = factor / 2.0,
		},
	})
end, {
	description = "Zoom out",
})

hl.bind("SUPER + CTRL + ALT + B", hl.dsp.exec_cmd("pkill -SIGUSR1 waybar"), { description = "toggle waybar" })
hl.bind(
	"SUPER + CTRL + B",
	hl.dsp.exec_cmd(defaults.scriptsDir .. "/WaybarStyles.sh"),
	{ description = "waybar styles menu" }
)
hl.bind(
	"SUPER + ALT + B",
	hl.dsp.exec_cmd(defaults.scriptsDir .. "/WaybarLayout.sh"),
	{ description = "waybar layout menu" }
)

hl.bind(
	"SUPER + N",
	hl.dsp.exec_cmd(defaults.scriptsDir .. "/Hyprsunset.sh toggle"),
	{ description = "toggle night light" }
)
hl.bind("SUPER + SHIFT + M", hl.dsp.exec_cmd(defaults.scriptsDir .. "/RofiBeats.sh"), { description = "online music" })
hl.bind(
	"SUPER + W",
	hl.dsp.exec_cmd(defaults.scriptsDir .. "/WallpaperSelect.sh"),
	{ description = "select wallpaper" }
)
hl.bind(
	"SUPER + SHIFT + W",
	hl.dsp.exec_cmd(defaults.scriptsDir .. "/WallpaperEffects.sh"),
	{ description = "wallpaper effects" }
)
hl.bind(
	"CTRL + ALT + W",
	hl.dsp.exec_cmd(defaults.scriptsDir .. "/WallpaperRandom.sh"),
	{ description = "random wallpaper" }
)

hl.bind(
	"SUPER + CTRL + O",
	hl.dsp.window.set_prop({ prop = "opaque", value = "toggle" }),
	{ description = "toggle active window opacity" }
)
hl.bind(
	"SUPER + SHIFT + K",
	hl.dsp.exec_cmd(defaults.scriptsDir .. "/Keybinds.sh"),
	{ description = "search keybinds" }
)
hl.bind(
	"SUPER + SHIFT + A",
	hl.dsp.exec_cmd(defaults.scriptsDir .. "/Animations.sh"),
	{ description = "animations menu" }
)
hl.bind(
	"SUPER + SHIFT + O",
	hl.dsp.exec_cmd(defaults.scriptsDir .. "/ZshChangeTheme.sh"),
	{ description = "change zsh theme" }
)
hl.bind("SUPER + ALT + C", hl.dsp.exec_cmd(defaults.scriptsDir .. "/RofiCalc.sh"), { description = "calculuator" })
hl.bind("SUPER + F4", hl.dsp.exec_cmd(defaults.scriptsDir .. "/toggle_hz.sh"), { description = "" }) -- convert to lowpower later

hl.bind(
	"SUPER + CTRL + F9",
	hl.dsp.workspace.move({ monitor = "l" }),
	{ description = "move workspace to left monitor" }
)
hl.bind(
	"SUPER + CTRL + F10",
	hl.dsp.workspace.move({ monitor = "r" }),
	{ description = "move workspace to right monitor" }
)
hl.bind(
	"SUPER + CTRL + F11",
	hl.dsp.workspace.move({ monitor = "u" }),
	{ description = "move workspace to up monitor" }
)
hl.bind(
	"SUPER + CTRL + F12",
	hl.dsp.workspace.move({ monitor = "d" }),
	{ description = "move workspace to down monitor" }
)

hl.bind("CTRL + ALT + Delete", hl.dsp.exec_cmd(" hyprctl dispatch exit 0"), { description = "exit Hyprland" })
hl.bind("SUPER + Q", hl.dsp.window.kill(), { description = "close active window" })
hl.bind(
	"SUPER + SHIFT + Q",
	hl.dsp.exec_cmd(defaults.scriptsDir .. "/KillActiveProcess.sh"),
	{ description = "terminate active process" }
)
hl.bind("CTRL + ALT + L", hl.dsp.exec_cmd(defaults.scriptsDir .. "/LockScreen.sh"), { description = "lock screen" })
hl.bind("CTRL + ALT + P", hl.dsp.exec_cmd(defaults.scriptsDir .. "/Wlogout.sh"), { description = "power menu" })
hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd("swaync-client -t -sw"), { description = "notification panel" })
hl.bind(
	"SUPER + SHIFT + E",
	hl.dsp.exec_cmd(defaults.scriptsDir .. "Kool_Quick_Settings"),
	{ description = "quick settings menu" }
)

-- Master Layout
hl.bind("SUPER + CTRL + D", hl.dsp.layout("removemaster"), { description = "remove master" })
hl.bind("SUPER + I", hl.dsp.layout("addmaster"), { description = "add master" })
hl.bind(
	"SUPER + CTRL + Return",
	hl.dsp.layout("swapwithmaster auto"),
	{ description = "swap with master, focus on previously focused window" }
)

--Dwindle Layout
hl.bind("SUPER + SHIFT + I", hl.dsp.layout("togglesplit"), { description = "toggle split (dwindle)" })
hl.bind("SUPER + P", hl.dsp.window.pseudo(), { description = "toggle pseudo (dwindle)" })

--Layout Agnostic
hl.bind("SUPER + M", hl.dsp.exec_cmd("hyprctl dispatch splitratio 0.3"), { description = "set split ratio to 0.3" })

hl.exec_cmd(defaults.scriptsDir .. "/ChangeLayout.sh init")

hl.bind("ALT + tab", hl.dsp.exec_cmd(""), function()
	hl.dispatch(hl.dsp.window.cycle_next())
	hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end, {
	description = "Cycle windows and bring active window to top",
})

-- HotKeys
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd(defaults.scriptsDir .. "/Volume.sh --inc"),
	{ description = "volume up" }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd(defaults.scriptsDir .. "/Volume.sh --dec"),
	{ description = "volume down" }
)
hl.bind(
	"ALT + XF86AudioRaiseVolume",
	hl.dsp.exec_cmd(defaults.scriptsDir .. "/Volume.sh --inc-precise"),
	{ description = "volume up precise" }
)
hl.bind(
	"ALT + XF86AudioLowerVolume",
	hl.dsp.exec_cmd(default.scriptsDir .. "/Volume.sh --dec-precise"),
	{ description = "volume down precise" }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd(defaults.scriptsDir .. "/Volume.sh --toggle-mic"),
	{ description = "toggle mic mute" }
)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(defaults.scriptsDir .. "/Volume.sh --toggle"), { description = "toggle mute" })
hl.bind("XF86Sleep", hl.dsp.exec_cmd("systemctl suspend"), { description = "sleep" })
hl.bind("XF86RfKill", hl.dsp.exec_cmd(defaults.scriptsDir .. "/AirplaneMode.sh"), { description = "airplane mode" })

-- Media Controls
hl.bind(
	"XF86AudioPlayPause",
	hl.dsp.exec_cmd(defaults.scriptsDir .. "/MediaCtrl.sh --pause"),
	{ description = "play/pause" }
)
hl.bind("XF86AudioPause", hl.dsp.exec_cmd(defaults.scriptsDir .. "/MediaCtrl.sh -- pause"), { description = "pause" })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd(defaults.scriptsDir .. "/MediaCtrl.sh --pause"), { description = "play" })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd(defaults.scriptsDir .. "/MediaCtrl.sh --nxt"), { description = "next track" })
hl.bind(
	"XF86AudioPrev",
	hl.dsp.exec_cmd(defaults.scriptsDir .. "/MediaCtrl.sh --prv"),
	{ description = "previous track" }
)
hl.bind("XF86audiostop", hl.dsp.exec_cmd(defaults.scriptsDir .. "/MediaCtrl.sh --stop"), { description = "stop" })

-- Screenshots
-- hl.bind("SUPER + Print", hl.dsp.exec_cmd(""), { description = "" })
-- hl.bind("SUPER + SHIFT + Print", hl.dsp.exec_cmd(""), { description = "" })
-- hl.bind("SUPER + CTRL + Print", hl.dsp.exec_cmd(""), { description = "" })
-- hl.bind("SUPER + CTRL + SHIFT + Print", hl.dsp.exec_cmd(""), { description = "" })
-- hl.bind("ALT + Print", hl.dsp.exec_cmd(""), { description = "" })
hl.bind(
	"SUPER + SHIFT + S",
	hl.dsp.exec_cmd(defaults.scriptsDir .. "/ScreenShot.sh --swappy"),
	{ description = "swappy screenshot" }
)

-- Resize Windows
hl.bind(
	"SUPER + SHIFT + left",
	hl.dsp.window.resize({ x = -50, y = 0, relative = true }),
	{ description = "resize left" }
)
hl.bind(
	"SUPER + SHIFT + right",
	hl.dsp.window.resize({ x = 50, y = 0, relative = true }),
	{ description = "resize right" }
)
hl.bind("SUPER + SHIFT + up", hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { description = "resize up" })
hl.bind(
	"SUPER + SHIFT + down",
	hl.dsp.window.resize({ x = 0, y = 50, relative = true }),
	{ description = "resize down" }
)

-- Move Windows
hl.bind("SUPER + CTRL + left", hl.dsp.window.move({ direction = "l" }), { description = "move window left" })
hl.bind("SUPER + CTRL + right", hl.dsp.window.move({ direction = "r" }), { description = "move window right" })
hl.bind("SUPER + CTRL + up", hl.dsp.window.move({ direction = "u" }), { description = "move window up" })
hl.bind("SUPER + CTRL + down", hl.dsp.window.move({ direction = "d" }), { description = "move window down" })

-- Swap Windows
hl.bind("SUPER + ALT + left", hl.dsp.window.swap({ direction = "l" }), { description = "swap window left" })
hl.bind("SUPER + ALT + right", hl.dsp.window.swap({ direction = "r" }), { description = "swap window right" })
hl.bind("SUPER + ALT + up", hl.dsp.window.swap({ direction = "u" }), { description = "swap window up" })
hl.bind("SUPER + ALT + down", hl.dsp.window.swap({ direction = "d" }), { description = "swap window down" })

-- Groups
hl.bind("SUPER + G", hl.dsp.group.toggle(), { description = "toggle group" })
hl.bind("SUPER + Tab", hl.dsp.group.next(), { description = "change group froward" })
hl.bind("SUPER + CTRL + tab", hl.dsp.group.next(), { description = "change active in group" })
hl.bind("SUPER + SHIFT + Tab", hl.dsp.group.prev(), { description = "change group back" })
hl.bind("SUPER + CTRL + K", hl.dsp.window.move({ into_group = "left" }), { description = "Move left into group" })
hl.bind("SUPER + CTRL + L", hl.dsp.window.move({ into_group = "right" }), { description = "Move right into group" })
hl.bind(
	"SUPER + CTRL + H",
	hl.dsp.window.move({ out_of_group = true }),
	{ description = "move active window out of group" }
)

--
hl.bind("SUPER + left", hl.dsp.focus({ direction = "l" }), { description = "focus left" })
hl.bind("SUPER + right", hl.dsp.focus({ direction = "r" }), { description = "focus right" })
hl.bind("SUPER + up", hl.dsp.focus({ direction = "u" }), { description = "focus up" })
hl.bind("SUPER + down", hl.dsp.focus({ direction = "d" }), { description = "focus down" })

hl.bind("SUPER + tab", hl.dsp.focus({ workspace = "m+1" }), { description = "Next workspace" })
hl.bind("SUPER + SHIFT + tab", hl.dsp.focus({ workspace = "m-1" }), { description = "previous workspace" })
hl.bind(
	"SUPER + SHIFT + U",
	hl.dsp.window.move({ workspace = "special" }),
	{ description = "move to special workspace" }
)

hl.bind("SUPER + U", hl.dsp.toggle_special(), { description = "Toggle special workspace" })

-- =========================================================
-- Switch workspaces: SUPER + 1–0
-- =========================================================

for workspace = 1, 10 do
	local key = tostring(workspace % 10)

	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = tostring(workspace) }), {
		description = "Switch to workspace " .. workspace,
	})
end

-- =========================================================
-- Move window and follow: SUPER + SHIFT + 1–0
-- =========================================================

for workspace = 1, 10 do
	local key = tostring(workspace % 10)

	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.exec_cmd("hyprctl dispatch movetoworkspace " .. workspace), {
		description = "Move window to workspace " .. workspace,
	})
end

-- Move to previous workspace
hl.bind(mainMod .. " + SHIFT + bracketleft", hl.dsp.exec_cmd("hyprctl dispatch movetoworkspace -1"), {
	description = "Move window to previous workspace",
})

-- Move to next workspace
hl.bind(mainMod .. " + SHIFT + bracketright", hl.dsp.exec_cmd("hyprctl dispatch movetoworkspace +1"), {
	description = "Move window to next workspace",
})

for workspace = 1, 10 do
	local key = tostring(workspace % 10)

	hl.bind("SUPER + CTRL + " .. key, hl.dsp.exec_cmd("hyprctl dispatch movetoworkspacesilent " .. workspace), {
		description = "Move window silently to workspace " .. workspace,
	})
end

-- Move silently to previous workspace
hl.bind("SUPER + CTRL + bracketleft", hl.dsp.exec_cmd("hyprctl dispatch movetoworkspacesilent -1"), {
	description = "Move silently to previous workspace",
})

-- Move silently to next workspace
hl.bind("SUPER + CTRL + bracketright", hl.dsp.exec_cmd("hyprctl dispatch movetoworkspacesilent +1"), {
	description = "Move silently to next workspace",
})

hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }), {
	description = "Next workspace",
})

hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }), {
	description = "Previous workspace",
})

hl.bind("SUPER + period", hl.dsp.focus({ workspace = "e+1" }), {
	description = "Next workspace",
})

hl.bind("SUPER + comma", hl.dsp.focus({ workspace = "e-1" }), {
	description = "Previous workspace",
})

hl.bind("SUPER + mouse:272", hl.dsp.window.move(), {
	description = "Move window",
	mouse = true,
})

hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), {
	description = "Resize window",
	mouse = true,
})
