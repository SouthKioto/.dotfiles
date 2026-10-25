------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- toolkit backend
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")

-- xdg
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- Qt
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

-- Intel iGPU
hl.env("LIBVA_DRIVER_NAME", "iHD")
hl.env("VDPAU_DRIVER", "va_gl")
-- hl.env("WLR_NO_HARDWARE_CURSORS", "1")
hl.env("MESA_VK_WSI_PRESENT_MODE", "fifo")
-- INTEL_DEBUG=nocompute USUNIĘTE
-- WLR_DRM_NO_ATOMIC=0 USUNIĘTE (default)

hl.env("GBM_BACKEND", "drm-backend")
hl.env("MOZ_ENABLE_WAYLAND", "1") -- Wymusza natywny Wayland dla Firefoxa
hl.env("NVD_BACKEND", "direct")
