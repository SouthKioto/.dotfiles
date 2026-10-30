-------------------
---- POWERSAVE ----
-------------------
-- Profil "power-saver" (scripts/power-profile.sh watch zapisuje go do pliku
-- i robi reload) → bez animacji, bluru i przyciemniania. Ładowany na końcu,
-- więc nadpisuje decorations.lua; reload z gamemode.sh/wallpaper.sh go nie zgubi.

local f = io.open((os.getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/power-profile", "r")
local profile = f and f:read("*l") or ""
if f then
	f:close()
end

if profile == "power-saver" then
	hl.config({
		animations = { enabled = false },
		decoration = { blur = { enabled = false }, dim_inactive = false },
	})
end
