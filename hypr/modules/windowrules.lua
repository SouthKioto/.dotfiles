--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

-- Okna kafelkują się normalnie; pływają tylko te z reguł niżej (dialogi, mikser, pickery)

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

hl.layer_rule({
	-- podgląd workspace'ów (Quickshell, SUPER + TAB): rozmyte tło, przyciemnienie robi sam QML
	name = "overview-blur",
	match = { namespace = "^overview$" },
	blur = true,
	ignore_alpha = 0.3,
	animation = "fade",
})

hl.window_rule({
	name = "steam-games-fullscreen",
	match = { class = "^steam_app_.*" },
	fullscreen = true,
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

-- edytor zrzutów ekranu (scripts/screenshot.sh): satty, a swappy jako zapas
hl.window_rule({
	name = "float-screenshot-editor",
	match = { class = "^(com\\.gabm\\.satty|swappy)$" },
	float = true,
	center = true,
	size = "monitor_w*0.8 monitor_h*0.8",
})

-- GIMP dialogi (toolboxy, okna narzędzi)
hl.window_rule({
	name = "float-gimp-dialogs",
	match = { class = "^Gimp.*", title = "negative:.*GNU Image Manipulation Program.*" },
	float = true,
})

-- Typowe okna dialogowe (otwórz/zapisz, potwierdzenia) w każdej aplikacji
hl.window_rule({
	name = "float-common-dialogs",
	match = { title = "^(Open File|Save As|Save File|Otwórz plik|Zapisz plik|Zapisz jako|File Upload|Choose Files|Confirm.*|Potwierdź.*)$" },
	float = true,
	center = true,
})

-- Obraz w obrazie (Brave/YouTube) — pływa, przypięty w rogu
hl.window_rule({
	name = "pip",
	match = { title = "^(Picture in picture|Obraz w obrazie)$" },
	float = true,
	pin = true,
	size = "640 360",
	move = "monitor_w-660 monitor_h-380",
})

-- ── Steam / gry ──────────────────────────────────────────
-- okna pomocnicze Steama (znajomi, ustawienia, pobieranie) pływają, główne okno kafelkuje
hl.window_rule({
	name = "steam-dialogs",
	match = { class = "^steam$", title = "negative:^Steam$" },
	float = true,
	center = true,
})

-- gra: bez bluru, przyciemniania i zaokrągleń, blokuje wygaszanie ekranu
hl.window_rule({
	name = "steam-games-perf",
	match = { class = "^(steam_app_.*|gamescope)$" },
	no_blur = true,
	no_dim = true,
	rounding = 0,
	idle_inhibit = "always",
})
