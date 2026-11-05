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

		wobble = {
			enabled = true,
			mesh = 32,
			stiffness = 700,
			damping = 35,
		},
		blur = {
			enabled = true,
			variant = "haze",

			haze = {
				intensity = 1.0,
				iridescence = 1.0,
			},

			-- variant = "acrylic",

			acrylic = {
				aberration = 0.25,
				bulb = 128.0,
				clarity = 1.0,
				refraction = 48.0,
			},

			heat_shimmer = {
				speed = 2.0,

			},
			size = 5,
			passes = 3,
			new_optimizations = true,
			xray = true,
			ignore_opacity = true,
			special = true,
			popups = true,
		},

		motion_blur = {
			enabled = false,
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
