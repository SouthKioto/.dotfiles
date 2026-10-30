-----------------
---- PLUGINS ----
-----------------
-- Budowane przez hyprpm (patrz ~/.config/rice/install.sh) do /var/cache/hyprpm/$USER,
-- ładowane w autostarcie przez `hyprctl plugin load`. Dopóki plugin nie jest załadowany,
-- jego sekcja nic nie robi — config nie wywala się bez pluginów.
-- (hyprexpo wypadł z hyprland-plugins w 05.2026 — podgląd workspace'ów robi Quickshell, SUPER + TAB)

local rgba = require("modules.colors").rgba

-- === hyprbars: paski tytułowe tylko na oknach pływających ===
if hl.plugin.hyprbars then
	hl.config({
		plugin = {
			hyprbars = {
				bar_height = 26,
				bar_color = rgba("surface_container"),
				["col.text"] = rgba("on_surface"),
				bar_text_font = "JetBrainsMono Nerd Font Propo",
				bar_text_size = 10,
				bar_text_weight = "semibold",
				bar_padding = 10,
				bar_button_padding = 7,
				bar_part_of_window = true,
				bar_precedence_over_border = true,
				bar_blur = true,
				inactive_button_color = rgba("outline_variant"),
				on_double_click = [[hyprctl dispatch 'hl.dsp.window.float({ action = "toggle" })']],
			},
		},
	})

	-- przyciski od prawej: zamknij, pływające/kafelek
	hl.plugin.hyprbars.add_button({
		bg_color = rgba("error"),
		fg_color = rgba("surface"),
		size = 12,
		icon = "󰅖",
		action = "hyprctl dispatch 'hl.dsp.window.close()'",
	})
	hl.plugin.hyprbars.add_button({
		bg_color = rgba("tertiary"),
		fg_color = rgba("surface"),
		size = 12,
		icon = "󰖲",
		action = [[hyprctl dispatch 'hl.dsp.window.float({ action = "toggle" })']],
	})

	hl.window_rule({
		name = "hyprbars-tiled-no-bar",
		match = { float = false },
		["hyprbars:no_bar"] = true,
	})
end
