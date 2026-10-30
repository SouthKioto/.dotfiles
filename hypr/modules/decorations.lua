-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Paleta: witchHat (zoptymalizowane dla Intel iGPU)
-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
--
--

-- kolory z matugena: modules/colors.lua
local rgba = require("modules.colors").rgba

hl.config({
	general = {
		gaps_in = 6,
		gaps_out = 8,

		border_size = 0,

		col = {
			active_border = {
				colors = { rgba("primary", "ee"), rgba("secondary", "ee"), rgba("tertiary", "ee") },
				angle = 45,
			},
			inactive_border = rgba("outline_variant", "44"),
		},
		resize_on_border = false,
		allow_tearing = false,
	},

	decoration = {
		rounding = 4, -- było 12, mniej obliczeń przy wielu oknach
		rounding_power = 3, -- było 3

		-- Opacity: wyższe wartości = mniej blendingu = mniej pracy GPU
		active_opacity = 1, -- było 0.90, pełna nieprzezroczystość = brak kosztu blendingu
		inactive_opacity = 1, -- było 0.94: każde nieaktywne okno wymuszało blur pod spodem (3 monitory na iGPU)
		dim_inactive = true, -- przyciemnienie zostaje, jest prawie darmowe
		dim_strength = 0.06,

		shadow = {
			enabled = false,
			range = 24, -- było 28, mniejszy zasięg = mniej sampli
			render_power = 4, -- było 4
			color = rgba("shadow", "cc"),
			color_inactive = rgba("shadow", "66"),
		},

		blur = {
			enabled = true,
			size = 6, -- było 12
			passes = 2, -- było 3 ← największa zmiana; koszt rośnie jako passes²
			popups = false, -- menu kontekstowe bez bluru
			special = false, -- scratchpady bez bluru tła
			vibrancy = 0.2,
			vibrancy_darkness = 0.08,
			noise = 0.015,
			contrast = 0.95,
			brightness = 0.85,
			new_optimizations = true,
			ignore_opacity = false,
			xray = true, -- blur liczy tylko tapetę (cache) zamiast wszystkiego pod oknem — duża ulga dla iGPU na 2 ekranach
		},
	},
})

-- ┌─────────────────────────────────────────┐
-- │         MAGICZNE KRZYWE RUCHU           │
-- └─────────────────────────────────────────┘

-- Płynne, mistyczne wejście (jak unoszący się dym)
hl.curve("witchSmoke", { type = "bezier", points = { { 0.0, 0.0 }, { 0.05, 1.0 } } })

-- Sprężyste, magiczne lądowanie (jak kapelusz czarownicy opadający)
hl.curve("witchLand", { type = "bezier", points = { { 0.34, 1.56 }, { 0.64, 1.0 } } })

-- Szybkie zniknięcie (teleportacja)
hl.curve("witchVanish", { type = "bezier", points = { { 0.7, 0.0 }, { 1.0, 0.0 } } })

-- Powolne, mroczne wyłanianie
hl.curve("witchReveal", { type = "bezier", points = { { 0.0, 0.0 }, { 0.2, 1.0 } } })

-- Mistyczny drżenie (quint out dla warstw)
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })

-- Linearne (tło)
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })

-- Sprężyna — jak różdżka (lżejsze parametry dla iGPU)
hl.curve("wandSpring", { type = "spring", mass = 0.7, stiffness = 80.0, dampening = 14.0 })

-- ┌─────────────────────────────────────────┐
-- │         MAGICZNE ANIMACJE               │
-- └─────────────────────────────────────────┘

-- Globalna prędkość — wyższe speed = krótsza animacja = mniej klatek do wyrenderowania
hl.animation({ leaf = "global", enabled = true, speed = 8, bezier = "default" })

-- Obramowanie pulsuje jak zaklęcie
hl.animation({ leaf = "border", enabled = true, speed = 9.0, bezier = "witchReveal" })

-- Okna poruszają się z mistyczną sprężystością
hl.animation({ leaf = "windows", enabled = true, speed = 7.0, spring = "wandSpring" })

-- Wejście okna — wyłania się z dymu
hl.animation({ leaf = "windowsIn", enabled = true, speed = 6.5, spring = "wandSpring", style = "popin 80%" })

-- Wyjście okna — rozpływa się jak dym (krótkie i szybkie)
hl.animation({ leaf = "windowsOut", enabled = true, speed = 4.5, bezier = "witchVanish", style = "popin 90%" })

-- Fade wejście
hl.animation({ leaf = "fadeIn", enabled = true, speed = 4.0, bezier = "witchReveal" })

-- Fade wyjście
hl.animation({ leaf = "fadeOut", enabled = true, speed = 3.5, bezier = "witchVanish" })

-- Ogólny fade
hl.animation({ leaf = "fade", enabled = true, speed = 5.0, bezier = "witchSmoke" })

-- Warstwy (np. rofi, mako)
hl.animation({ leaf = "layers", enabled = true, speed = 5.5, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 6.0, bezier = "witchSmoke", style = "popin 70%" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 3.0, bezier = "witchVanish", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 3.5, bezier = "witchReveal" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 2.5, bezier = "witchVanish" })

-- Workspace — przesuwanie; wyższy speed = mniej input lag przy przełączaniu
hl.animation({ leaf = "workspaces", enabled = true, speed = 6.0, bezier = "witchSmoke", style = "slidevert" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 5.5, bezier = "witchReveal", style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 4.5, bezier = "witchVanish", style = "slide" })

hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7.0, spring = "wandSpring" })
-- hl.animation({ leaf = "borderangle", enabled = true, speed = 40.0, bezier = "linear", style = "loop" })

-- ┌─────────────────────────────────────────┐
-- │     REGUŁY OKIEN (opcjonalne)           │
-- └─────────────────────────────────────────┘

-- Smart gaps — odkomentuj jeśli chcesz
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({
--     name  = "no-gaps-wtv1",
--     match = { float = false, workspace = "w[tv1]" },
--     border_size = 0,
--     rounding    = 0,
-- })
-- hl.window_rule({
--     name  = "no-gaps-f1",
--     match = { float = false, workspace = "f[1]" },
--     border_size = 0,
--     rounding    = 0,
-- })
