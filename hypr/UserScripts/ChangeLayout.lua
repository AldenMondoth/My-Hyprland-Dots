--[[
 /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  te#
 for changing Hyprland Layouts (Master or Dwindle) on the fly
]]
--

local home = os.getenv("HOME")
local notif = home .. "/.config/swaync/images/ja.png"

layout = hl.get_config("general.layout")

-- Reverse layout value to reuse toggle logic. So layouts don't get swapped initially.
local layout_order = {
  "master",
  "dwindle",
  "scrolling",
  "monocle",
}
local function configure_layout(layout)
  hl.unbind("SUPER + J")
  hl.unbind("SUPER + K")
  hl.unbind("SUPER + O")

  if layout == "master" then
    -- hl.exec_cmd("hyprctl keyword general:layout dwindle")
    hl.bind("SUPER + J", hl.dsp.window.cycle_next())
    hl.bind("SUPER + K", hl.dsp.window.cycle_next({ next = false }))

    hl.bind("SUPER + O", hl.dsp.layout("togglesplit"))
  elseif layout == "dwindle" or layout == "scrolling" then
    hl.bind("SUPER + J", hl.dsp.layout("cyclenext"))
    hl.bind("SUPER + K", hl.dsp.layout("cycleprev"))
  elseif layout == "monocle" then
    -- hl.exec_cmd("hyprctl keyword general:layout scrolling")
    hl.bind("SUPER + J", hl.dsp.window.cycle_next({ tiled = true }))
    hl.bind("SUPER + K", hl.dsp.window.cycle_next({ next = false, tiled = true }))
  end
end

local function set_layout(layout, show_notif)
  hl.config({
    general = {
      layout = layout,
    },
  })
  configure_layout(layout)

  if show_notif then
    local message = layout:sub(1, 1):upper() .. layout:sub(2) .. " Layout"

    hl.exec_cmd('notify-send -e low -i "' .. notif .. '" "' .. message .. '""')
  end
end

local function toggle_layout()
  local current_layout = hl.get_config("general.layout")
  local current_index = 1

  for i, layout in ipairs(layout_order) do
    if layout == current_layout then
      current_index = i
      break
    end
  end

  local next_index = (current_index % #layout_order) + 1
  local next_layout = layout_order[next_index]

  set_layout(next_layout, true)
end

local current_layout = hl.get_config("general.layout")

if current_layout then
  configure_layout(current_layout)
end

return {
  toggle = toggle_layout,
}
