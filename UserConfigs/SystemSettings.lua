local defaults = require("UserConfigs.UserDefaults")

-- LAYOUT SETTINGS

-- Dwindle Layout
hl.config({
	dwindle = {
		-- pseudotile = true
		preserve_split = true,
		-- smart_split = true
		special_scale_factor = 0.8,
	},
})

--Master Layout
hl.config({
	master = {
		new_status = "master",
		new_on_top = 1,
		mfact = 0.5,
	},
})

-- Monocle Layout

-- Scrolling Layout
hl.config({
	scrolling = {
		column_width = 0.5,
		direction = "right",
		focus_fit_method = 1,
		explicit_column_widths = "0.33, 0.5, 0.667, 1.0",
		follow_focus = true,
		fullscreen_on_one_column = true,
	},
})

hl.workspace_rule({
	workspace = "name:5",
	layout = "monocle",
})

-- General Layout -> Monocle
hl.config({
	general = {
		border_size = 1,
		gaps_in = 5,
		gaps_out = 15,
		--[[
		col = {
			active_border = defaults.colors.foreground,
			inactive_border = (function()
				local filtered = {}
				for key, value in pairs(defaults.colors) do
					if key ~= "background" and "foreground" then
						table.insert(filtered, value)
					end
				end
				return { colors = filtered }
			end)(),
		},]]
		--
		resize_on_border = true,
		extend_border_grab_area = 10,
		layout = "dwindle",
	},
})

--INPUT SETTINGS

hl.config({
	input = {
		kb_layout = "us",
		kb_variant = "",
		kb_model = "",
		kb_options = "",
		kb_rules = "",
		repeat_rate = 50,
		repeat_delay = 300,

		sensitivity = 0, -- mouse sensitivity
		-- accel_profile =     # flat or adaptive or blank or EMPTY means libinput’s default mode
		numlock_by_default = true,
		left_handed = false,
		follow_mouse = 1,
		float_switch_override_focus = false,

		touchpad = {
			disable_while_typing = true,
			natural_scroll = true,
			clickfinger_behavior = false,
			middle_button_emulation = false,
			tap_to_click = true,
			drag_lock = false,
		},

		-- below for devices with touchdevice ie. touchscreen
		touchdevice = {
			enabled = true,
		},

		-- below is for table see link above for proper variables
		tablet = {
			transform = 0,
			left_handed = 0,
		},
	},
})

hl.config({
	gestures = {
		workspace_swipe_distance = 500,
		workspace_swipe_invert = true,
		workspace_swipe_min_speed_to_force = 30,
		workspace_swipe_cancel_ratio = 0.5,
		workspace_swipe_create_new = true,
		workspace_swipe_forever = true,
		--workspace_swipe_use_r = true --uncomment if wanted a forever create a new workspace with swipe right
	},
})

-- GESTURES

-- three finger horiz swipe: change workspace
hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

-- four finger vertical swipe up: increase cursor zoom by 1.5x
hl.gesture({
	fingers = 4,
	direction = "up",
	action = function()
		hl.exec_cmd([[
    hyprctl keyword cursor:zoom_factor "$(
      hyprctl getoption cursor:zoom_factor |
      awk 'NR==1 {
        factor = $2;
        if (factor < 1) {factor = 1};
          print factor * 1.5}'
        )"
    ]])
	end,
})

-- four finger vertical swipe down: decrease cursor zoom 1.5x
hl.gesture({
	fingers = 4,
	direction = "down",
	action = function()
		hl.exec_cmd([[
            hyprctl keyword cursor:zoom_factor "$(
                hyprctl getoption cursor:zoom_factor |
                awk 'NR==1 {
                    factor = $2;
                    if (factor < 1) factor = 1;
                    print factor / 1.5
                }'
            )"
        ]])
	end,
})
-- three finger swipe up: toggle overview
hl.gesture({
	fingers = 3,
	direction = "up",
	action = function()
		hl.exec_cmd(defaults.scriptsDir .. "/OverviewToggle.sh")
	end,
})

-- MISC SETTINGS

hl.config({
	misc = {
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		-- vfr = true,
		vrr = 2,
		mouse_move_enables_dpms = true,
		enable_swallow = false,
		swallow_regex = "^(kitty)$",
		focus_on_activate = false,
		initial_workspace_tracking = 0,
		middle_click_paste = false,
		enable_anr_dialog = true, -- Application not Responding (ANR)
		anr_missed_pings = 15, -- ANR Threshold default 1 is too low
		allow_session_lock_restore = true, -- Prevent lockscreen crash when resume from suspend
		-- This only works with HL v0.53+
		on_focus_under_fullscreen = 1,
		-- 0 - Default, no change
		-- 1 - New focused window takes over fullscreen (Windows-like Alt-Tab)
		-- 2 - New focused window stays behind the fullscreen one
	},
})

-- reduce flicker on Nvidia GPUs if its a problem
-- hl.config({
-- opengl {
--  nvidia_anti_flicker = true,
-- },
-- })

hl.config({
	binds = {
		workspace_back_and_forth = true,
		allow_workspace_cycles = true,
		pass_mouse_when_bound = false,
	},
})

--Could help when scaling and not pixelating
hl.config({
	xwayland = {
		enabled = true,
		force_zero_scaling = true,
	},
})

-- RENDER SETTINGS
hl.config({
	render = {
		direct_scanout = 0,
	},
})

-- CURSOR SETTINGS
hl.config({
	cursor = {
		sync_gsettings_theme = true,
		no_hardware_cursors = 1, -- change to 1 if want to disable
		enable_hyprcursor = true,
		warp_on_change_workspace = 2,
		no_warps = true,
	},
})
