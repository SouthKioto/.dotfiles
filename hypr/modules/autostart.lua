-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:

hl.on("hyprland.start", function()
	hl.exec_cmd("waybar")
	hl.exec_cmd("swaync")
	hl.exec_cmd("awww-daemon")
	hl.exec_cmd(
		"bash -c 'dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=Hyprland && systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP && systemctl --user start hyprland-session.target && systemctl --user start xdg-desktop-portal'"
	)
	hl.exec("swayosd-server")
	hl.exec("~/.config/hypr/lid.sh auto")
end)
