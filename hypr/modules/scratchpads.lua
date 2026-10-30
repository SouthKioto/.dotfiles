--------------------
---- SCRATCHPADS ----
--------------------
-- Wysuwane okna na special workspace. Pierwsze wciśnięcie odpala aplikację,
-- kolejne tylko chowa/pokazuje (aplikacja żyje w tle). Okna pływają na środku.

local terminal = "kitty"

local scratchpads = {
	{ key = "grave", name = "term", class = "scratchterm", cmd = terminal .. " --class=scratchterm", size = "monitor_w*0.7 monitor_h*0.65", desc = "Scratchpad: terminal" },
	{ key = "B", name = "btop", class = "scratchbtop", cmd = terminal .. " --class=scratchbtop -e btop", size = "monitor_w*0.8 monitor_h*0.8", desc = "Scratchpad: btop" },
	{ key = "Y", name = "music", class = "scratchmusic", cmd = terminal .. " --class=scratchmusic -e spotify_player", size = "monitor_w*0.7 monitor_h*0.7", desc = "Scratchpad: muzyka (spotify_player)" },
	{ key = "C", name = "calc", class = "scratchcalc", cmd = terminal .. " --class=scratchcalc -e numbat", size = "monitor_w*0.4 monitor_h*0.45", desc = "Scratchpad: kalkulator (numbat)" },
	{ key = "A", name = "mixer", class = "org.pavucontrol_qt.pavucontrol-qt", cmd = "pavucontrol-qt", size = "800 600", desc = "Scratchpad: mikser dźwięku" },
}

for _, s in ipairs(scratchpads) do
	hl.window_rule({
		name = "scratchpad-" .. s.name,
		match = { class = "^" .. s.class:gsub("%.", "\\.") .. "$" },
		workspace = "special:" .. s.name,
		float = true,
		size = s.size,
		center = true,
	})

	hl.bind("SUPER + " .. s.key, function()
		if #hl.get_windows({ class = s.class }) == 0 then
			-- reguła wyżej sama wrzuci okno na special workspace i go pokaże
			hl.dispatch(hl.dsp.exec_cmd(s.cmd))
		else
			hl.dispatch(hl.dsp.workspace.toggle_special(s.name))
		end
	end, { description = s.desc })
end

-- scratchpady mają własną animację: wjazd z góry zamiast slidevert workspace'ów
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 5.0, bezier = "easeOutQuint", style = "slidefadevert -30%" })
