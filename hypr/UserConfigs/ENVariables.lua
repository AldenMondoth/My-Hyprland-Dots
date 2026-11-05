-- Backend Vars
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("CLUTTER_BACKEND", "wayland")

-- SDL2 apps on wayland
-- hl.env("SDL_VIDEODRIVER", "wayland")

-- XDG Spec
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- Qt vars
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_QUICK_CONTROLS_STYLE", "org.hyprland.style")

-- xwayland app scale fix for monitor scaling
hl.env("GDK_SCALE", "1")
hl.env("QT_SCALE_FACTOR", "1")

-- selects wayland if possible for ozone apps, fallback to x11
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto ")
hl.env("MOZ_ENABLE_WAYLAND", "1")

hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("HYPRCURSOR_SIZE", "24")
