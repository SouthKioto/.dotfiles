----------------
----  MISC  ----
----------------

hl.config({
	misc = {
		force_default_wallpaper = 1, -- Set to 0 or 1 to disable the anime mascot wallpapers
		disable_hyprland_logo = true, -- If true disables the random hyprland logo / anime girl background. :(
		disable_splash_rendering = true,
		vrr = 0, -- monitory i tak 60 Hz, VRR na iGPU tylko przeszkadza
		mouse_move_enables_dpms = true,
		key_press_enables_dpms = true,
		focus_on_activate = true, -- klik w link z Vesktopa przełącza na Brave
	},
})

hl.config({
	render = {
		-- potrójne buforowanie gdy klatka nie zdąży — mniej gubionych klatek na słabym iGPU
		new_render_scheduling = true,
		-- bez color managementu: każda powierzchnia omija shader CM (nie używam HDR/ICC)
		cm_enabled = false,
	},
})
