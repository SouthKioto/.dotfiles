--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

local floatAllRule = hl.window_rule({
	-- Wszystkie okna floating przy starcie
	name = "float-all-windows",
	match = { class = ".*" },
	float = true,
	center = true,
	size = "1300 750",
})
-- floatAllRule:set_enabled(false)

local suppressMaximizeRule = hl.window_rule({
	-- Ignore maximize requests from all apps. You'll probably like this.
	name = "suppress-maximize-events",
	match = { class = ".*" },

	suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
	-- Fix some dragging issues with XWayland
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},

	no_focus = true,
})

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

-- Hyprland-run windowrule
hl.window_rule({
	name = "move-hyprland-run",
	match = { class = "hyprland-run" },

	move = "20 monitor_h-120",
	float = true,
})

hl.layer_rule({
	name = "notification-animations",
	match = { namespace = "swaync-control-center" },
	animation = "slide right",
})

hl.window_rule({
	name = "scratchterm",
	match = { class = "scratchterm" },
	workspace = "special:term",
})

hl.window_rule({
	name = "steam-games-fullscreen",
	match = { class = "^steam_app_.*" },
	fullscreen = true,
})

-- pavucontrol (mikser dźwięku)
hl.window_rule({
	name = "float-pavucontrol",
	match = { class = "org.pavucontrol_qt.pavucontrol-qt" },
	float = true,
	size = "800 600",
	center = true,
})

-- waypaper (picker tapet, jeśli używasz zamiast swojego skryptu)
hl.window_rule({
	name = "float-waypaper",
	match = { class = "waypaper" },
	float = true,
	center = true,
})

-- zenity / kdialog (systemowe dialogi, np. z Twoich skryptów bash)
hl.window_rule({
	name = "float-dialogs",
	match = { class = "^(zenity|kdialog)$" },
	float = true,
	center = true,
})

-- xdg-desktop-portal file picker (GTK)
hl.window_rule({
	name = "float-filepicker",
	match = { class = "xdg-desktop-portal-gtk" },
	float = true,
	center = true,
	size = "900 650",
})

-- GIMP dialogi (toolboxy, okna narzędzi)
hl.window_rule({
	name = "float-gimp-dialogs",
	match = { class = "^Gimp.*", title = "^(?!.*GNU Image Manipulation Program).*$" },
	float = true,
})
