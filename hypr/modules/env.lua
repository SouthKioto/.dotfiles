------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
-- XDG_CURRENT_DESKTOP / XDG_SESSION_* ustawia sam Hyprland

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- toolkit backend (z fallbackiem na X11, inaczej część gier/Steam się nie odpali)
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("SDL_VIDEODRIVER", "wayland,x11")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("MOZ_ENABLE_WAYLAND", "1")

-- Qt
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

-- Intel iGPU: sprzętowe dekodowanie wideo (VA-API, intel-media-driver)
hl.env("LIBVA_DRIVER_NAME", "iHD")

-- motywy TUI z kolorów matugena (lazygit: config + theme.yml; bat: paleta ANSI terminala = kitty z matugena)
hl.env("LG_CONFIG_FILE", os.getenv("HOME") .. "/.config/lazygit/config.yml," .. os.getenv("HOME") .. "/.config/lazygit/theme.yml")
hl.env("BAT_THEME", "base16")
