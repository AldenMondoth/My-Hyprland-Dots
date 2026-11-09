local FILE = "pleamar.json"

local function hex_to_rgb(hex)
	hex = hex:gsub("#", "")

	return tonumber(hex:sub(1, 2), 16) / 255, tonumber(hex:sub(3, 4), 16) / 255, tonumber(hex:sub(5, 6), 16) / 255
end

local function update_palette()
	local p = sys.ask("files.read", FILE, "json")

	if not p then
		log("ERROR: Could not parse palette JSON")
		return
	end

	fact.bg_r, fact.bg_g, fact.bg_b = hex_to_rgb(p.background)
	fact.fg_r, fact.fg_g, fact.fg_b = hex_to_rgb(p.foreground)
	fact.accent_r, fact.accent_g, fact.accent_b = hex_to_rgb(p.accent)
	fact.secondary_r, fact.secondary_g, fact.secondary_b = hex_to_rgb(p.secondary)
end

update_palette()

sys.watch("files:" .. FILE, update_palette)

local last_id = nil

sys.watch("notifications", function(list)
	local newest = list[1]

	if newest then
		if newest.id ~= last_id then
			last_id = newest.id
			text["notice_app"] = newest.app or "Notification"
			text["notice_title"] = newest.title or ""
			text["notice_body"] = newest.body or ""

			emit("notification_arrived")
		end
	else
		last_id = nil
	end
end)
