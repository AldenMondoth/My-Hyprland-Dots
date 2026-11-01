local colors = require("wallust/wallust-hyprland")
hl.config({

	decoration = {

		rounding = 12,
		rounding_power = 2.7,

		active_opacity = 0.95,
		inactive_opacity = 0.85,
		fullscreen_opacity = 1.0,

		dim_inactive = true,
		dim_strength = 0.2,
		dim_special = 0.8,

		shadow = {
			enabled = false,
			range = 3,
			render_power = 2,

			color = colors.foreground,
			color_inactive = colors.color10,
		},

		blur = {
			enabled = true,
			size = 5,
			passes = 3,
			new_optimizations = true,
			xray = true,
			ignore_opacity = true,
			special = true,
			popups = true,
		},

		motion_blur = {
			enabled = true,
			samples = 7,
		},
	},

	group = {
		col = {
			border_active = colors.color15,
		},

		groupbar = {
			col = {
				active = colors.color0,
			},
		},
	},
})
