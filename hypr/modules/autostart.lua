-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

hl.on("hyprland.start", function()
	-- najpierw środowisko dla systemd/dbus, żeby portale, polkit i aplikacje widziały sesję Wayland
	hl.exec_cmd(
		"bash -c 'dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE && systemctl --user start hyprland-session.target'"
	)

	hl.exec_cmd("waybar")
	hl.exec_cmd("swaync")
	hl.exec_cmd("awww-daemon") -- tapeta (przywraca ostatnią sama)
	hl.exec_cmd("swayosd-server") -- OSD głośności/jasności
	hl.exec_cmd("hypridle") -- blokada i wygaszanie ekranu po bezczynności
	hl.exec_cmd("hyprsunset") -- nocne światło wg harmonogramu (~/.config/hypr/hyprsunset.conf)
	hl.exec_cmd("systemctl --user start hyprpolkitagent") -- okienka z hasłem (polkit)
	hl.exec_cmd("wl-paste --watch cliphist store") -- historia schowka
	hl.exec_cmd("udiskie --smart-tray --notify") -- automontowanie pendrive'ów (ikonka w trayu tylko gdy coś jest podpięte)
	hl.exec_cmd("~/.config/hypr/scripts/power-profile.sh watch") -- power-saver → bez animacji i bluru
	hl.exec_cmd("qs -c widgets") -- widgety na pulpicie (~/.config/quickshell/widgets)
	-- pluginy zbudowane przez hyprpm; po załadowaniu reload, żeby modules/plugins.lua je skonfigurował
	hl.exec_cmd("bash -c 'for p in hyprbars; do hyprctl plugin load /var/cache/hyprpm/$USER/hyprland-plugins/$p.so; done; hyprctl reload'")
end)
