------------------
---- MONITORS ----
------------------
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- UWAGA: dopasowanie po "desc:" zamiast "DP-x", bo numeracja portów
-- potrafi się zmieniać przy podłączaniu przez dock/KVM (widziane:
-- DP-6 = Asus, DP-7 = LG, wcześniej DP-4/DP-5 — nazwy nie są stałe)

hl.monitor({
	output = "eDP-1",
	mode = "1920x1080@60",
	position = "0x0",
	scale = 1.25, -- Zmiana z 1.33 na 1.25 odciąża iGPU (czysty podział pikseli)
	-- disabled = true,
})

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
