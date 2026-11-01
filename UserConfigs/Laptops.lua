local defaults = require("UserConfigs.UserDefaults")

hl.bind("XF86KbdBrightnessDown", hl.dsp.exec_cmd(defaults.scriptsDir .. "/BrightnessKbd.sh --dec"))
hl.bind("XF86KbdBrightnessUp", hl.dsp.exec_cmd(defaults.scriptsDir .. "/BrightnessKbd.sh --inc"))
hl.bind("XF86Launch1", hl.dsp.exec_cmd("rog-control-center"))
hl.bind("XF86Launch3", hl.dsp.exec_cmd("asusctl led-mode -n"))
hl.bind("XF86Launch4", hl.dsp.exec_cmd("asusctl profile -n"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(defaults.scriptsDir .. "/Brightness.sh --dec"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(defaults.scriptsDir .. "/Brightness.sh --inc"))

hl.bind("SUPER + F6", hl.dsp.exec_cmd(defaults.scriptsDir .. "/ScreenShot.sh --now"))

hl.bind("SUPER + SHIFT + F6", hl.dsp.exec_cmd(defaults.scriptsDir .. "/ScreenShot.sh --area"))

hl.bind("SUPER + CTRL + F6", hl.dsp.exec_cmd(defaults.scriptsDir .. "/ScreenShot.sh --in5"))

hl.bind("ALT + F6", hl.dsp.exec_cmd(defaults.scriptsDir .. "/ScreenShot.sh --active"))

local Touchpad_Device = "asue1209:00-04f3:319f-touchpad"

local TOUCHPAD_ENABLED = true
hl.device({
	name = Touchpad_Device,
	enabled = TOUCHPAD_ENABLED,
})

-- These configs are mostly for laptops. This is addemdum to Keybinds.conf

-- Below are useful when you are connecting your laptop in external display
--Suggest you edit below for your laptop display
-- From WIKI This is to disable laptop monitor when lid is closed.
-- consult https://wiki.hyprland.org/hyprland-wiki/pages/Configuring/Binds/#switches
-- bindl = , switch:off:Lid Switch,exec,hyprctl keyword monitor "eDP-1, preferred, auto, 1"
-- bindl = , switch:on:Lid Switch,exec,hyprctl keyword monitor "eDP-1, disable"

-- WARNING! Using this method has some caveats!! USE THIS PART WITH SOME CAUTION!
-- CONS of doing this, is that you need to set up your wallpaper (SUPER W) and choose wallpaper.
-- CAVEATS! Sometimes the Main Laptop Monitor DOES NOT have display that it needs to re-connect your external monitor
-- One work around is to ensure that before shutting down laptop, MAKE SURE your laptop lid is OPEN!!
-- Make sure to comment (put # on the both the bindl = , switch ......) above
-- -- NOTE: Display for laptop are being generated into LaptopDisplay.conf
-- This part is to be use if you do not want your main laptop monitor to wake up during say wallpaper change etc

-- bindl = , switch:off:Lid Switch,exec,echo "monitor = eDP-1, preferred, auto, 1" > $UserConfigs/LaptopDisplay.conf
-- bindl = , switch:on:Lid Switch,exec,echo "monitor = eDP-1, disable" > $UserConfigs/LaptopDisplay.conf

-- for laptop-lid action (to erase the last entry)
-- exec-once = echo "monitor = eDP-1, preferred, auto, 1" > $HOME/.config/hypr/UserConfigs/LaptopDisplay.conf
