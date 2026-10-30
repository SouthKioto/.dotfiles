------------------
---- MONITORS ----
------------------
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- UWAGA: dopasowanie po "desc:" zamiast "DP-x", bo numeracja portów
-- potrafi się zmieniać przy podłączaniu przez dock/KVM (widziane:
-- DP-6 = Asus, DP-7 = LG, wcześniej DP-4/DP-5 — nazwy nie są stałe)

-- === ekran laptopa vs klapa ===
-- Klapa zamknięta + podpięte zewnętrzne → eDP-1 wyłączony. Sprawdzane nie tylko
-- przy zamknięciu klapy, ale też przy starcie/reloadzie configu i przy podpięciu
-- docka — inaczej po wybudzeniu z zamkniętą klapą albo `hyprctl reload`
-- (gamemode.sh, autoreload po zapisie) iGPU renderował 3 ekrany zamiast 2.
local LAPTOP = "eDP-1"

local function lid_closed()
	local f = io.open("/proc/acpi/button/lid/LID/state", "r")
	if not f then
		return false
	end
	local state = f:read("*a")
	f:close()
	return state:match("closed") ~= nil
end

local function monitor_names()
	local ok, mons = pcall(hl.get_monitors)
	local names = {}
	for _, m in ipairs(ok and mons or {}) do
		names[m.name] = true
	end
	return names
end

local function has_external(names)
	for name in pairs(names) do
		if name ~= LAPTOP then
			return true
		end
	end
	return false
end

local function laptop_monitor(disabled)
	hl.monitor({
		output = LAPTOP,
		mode = "1920x1080@60",
		position = "0x0",
		scale = 1.25, -- Zmiana z 1.33 na 1.25 odciąża iGPU (czysty podział pikseli)
		disabled = disabled,
	})
end

-- zmienia stan eDP-1 tylko gdy trzeba (bez pętli added/removed)
local function sync_laptop_screen()
	local names = monitor_names()
	local want_off = lid_closed() and has_external(names)
	if want_off == (names[LAPTOP] == true) then
		laptop_monitor(want_off)
	end
end

laptop_monitor(lid_closed() and has_external(monitor_names()))

hl.on("monitor.added", sync_laptop_screen) -- dock podpięty przy zamkniętej klapie
hl.on("monitor.removed", sync_laptop_screen) -- dock odpięty → ekran laptopa wraca
-- zamknięta bez monitorów → systemd-logind usypia laptopa sam, hypridle go wcześniej blokuje
hl.bind("switch:on:Lid Switch", sync_laptop_screen, { locked = true })
hl.bind("switch:off:Lid Switch", sync_laptop_screen, { locked = true })

hl.monitor({
	output = "desc:ASUSTek COMPUTER INC VG249QM5A TCLMTF056255",
	mode = "1920x1080@60",
	position = "1536x0", -- 1920 / 1.25 = dokładnie 1536
	scale = 1.0,
	transform = 1,
})

hl.monitor({
	output = "desc:LG Electronics LG ULTRAGEAR 0x000A2758",
	mode = "1920x1080@60",
	position = "2616x0", -- 1536 + 1080 (pionowy Asus) = dokładnie 2616
	scale = 1.0,
})

---------------------
---- WORKSPACES ----
---------------------
-- LG (desc match) - główny, workspace 1-5 (zostaje na dwindle, domyślny layout)
hl.workspace_rule({
	workspace = "1",
	monitor = "desc:LG Electronics LG ULTRAGEAR 0x000A2758",
	default = true,
	persistent = true,
})
hl.workspace_rule({ workspace = "2", monitor = "desc:LG Electronics LG ULTRAGEAR 0x000A2758", persistent = true })
hl.workspace_rule({ workspace = "3", monitor = "desc:LG Electronics LG ULTRAGEAR 0x000A2758", persistent = true })
hl.workspace_rule({ workspace = "4", monitor = "desc:LG Electronics LG ULTRAGEAR 0x000A2758", persistent = true })
hl.workspace_rule({ workspace = "5", monitor = "desc:LG Electronics LG ULTRAGEAR 0x000A2758", persistent = true })

-- Asus (desc match, pion) - scrolling layout, okna w pionowej taśmie (jedno pod drugim)
hl.workspace_rule({
	workspace = "6",
	monitor = "desc:ASUSTek COMPUTER INC VG249QM5A TCLMTF056255",
	default = true,
	persistent = true,
	layout = "scrolling",
	layout_opts = { direction = "down" },
})

hl.workspace_rule({
	workspace = "7",
	monitor = "desc:ASUSTek COMPUTER INC VG249QM5A TCLMTF056255",
	persistent = true,
	layout = "scrolling",
	layout_opts = { direction = "down" },
})
hl.workspace_rule({
	workspace = "8",
	monitor = "desc:ASUSTek COMPUTER INC VG249QM5A TCLMTF056255",
	persistent = true,
	layout = "scrolling",
	layout_opts = { direction = "down" },
})
hl.workspace_rule({
	workspace = "9",
	monitor = "desc:ASUSTek COMPUTER INC VG249QM5A TCLMTF056255",
	persistent = true,
	layout = "scrolling",
	layout_opts = { direction = "down" },
})
hl.workspace_rule({
	workspace = "10",
	monitor = "desc:ASUSTek COMPUTER INC VG249QM5A TCLMTF056255",
	persistent = true,
	layout = "scrolling",
	layout_opts = { direction = "down" },
})

hl.config({
	scrolling = {
		fullscreen_on_one_column = true, -- pojedyncze okno = pełny ekran
		column_width = 0.5, -- to i tak nieistotne przy direction=down, kontroluje szerokość "kolumny" gdy scrollujesz w poziomie
	},
})
