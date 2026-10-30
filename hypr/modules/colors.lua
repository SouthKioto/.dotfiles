------------------
---- KOLORY ----
------------------
-- Parser colors.conf (matugen): linie typu `$primary = rgb(8bd0ef)`
-- Użycie: local rgba = require("modules.colors").rgba;  rgba("primary", "ee")

local COLORS_FILE = os.getenv("HOME") .. "/.config/hypr/colors.conf"

local FALLBACK = {
	primary = "8bd0ef",
	secondary = "c6c2ea",
	tertiary = "354a53",
	outline_variant = "40484c",
}

local function load_colors(path)
	local colors = {}
	local f = io.open(path, "r")
	if not f then
		return colors
	end
	for line in f:lines() do
		local name, value = line:match("^%s*%$([%w_]+)%s*=%s*(.-)%s*$")
		if name then
			local hex = value:match("rgba?%((%x+)%)") or value:match("^0x(%x+)$") or value:match("^#(%x+)$")
			if hex then
				if #hex == 8 then
					hex = value:match("^0x") and hex:sub(3, 8) or hex:sub(1, 6)
				end
				if #hex == 6 then
					colors[name] = hex
				end
			end
		end
	end
	f:close()
	return colors
end

local C = load_colors(COLORS_FILE)

-- kolor z matugena (albo fallback) + alfa w hex, np. "ee"
local function rgba(name, alpha)
	return "rgba(" .. (C[name] or FALLBACK[name] or "ffffff") .. (alpha or "ff") .. ")"
end

return { colors = C, rgba = rgba }
