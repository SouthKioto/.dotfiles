---------------------
---- MY PROGRAMS ----
---------------------
local terminal = "kitty"
local fileManager = terminal .. " -e yazi"
local scripts = "~/.config/hypr/scripts/"
local menu = scripts .. "launcher.sh"
local lockMenu = "wlogout -b 5 -T 400 -B 400 -L 120 -R 120"
local chooseWallpaper = scripts .. "wallpaper.sh"
local powerMenu = scripts .. "power-menu.sh"
local procsMenu = scripts .. "proc-menu.sh"
local waybarRestart = scripts .. "waybar-restart.sh"
local clipboardMenu = scripts .. "clipboard.sh"

---------------------
---- KEYBINDINGS ----
---------------------
-- Każdy bind ma `description` — z tego SUPER + F1 (keybinds.sh) buduje ściągę
local mainMod = "SUPER"

local function bind(keys, dispatcher, desc, opts)
	opts = opts or {}
	opts.description = desc
	hl.bind(keys, dispatcher, opts)
end

-- === podstawowe ===
bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal), "Terminal")
bind(mainMod .. " + W", hl.dsp.window.close(), "Zamknij okno")
bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager), "Pliki (yazi)")
bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }), "Okno pływające / kafelek")
bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd(clipboardMenu), "Historia schowka")
bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(menu), "Launcher aplikacji")
bind(mainMod .. " + J", hl.dsp.layout("togglesplit"), "Zmień podział (dwindle)")
bind(mainMod .. " + R", hl.dsp.exec_cmd(waybarRestart), "Restart waybara")
bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd(scripts .. "refresh.sh"), "Odśwież wszystko (Hyprland, waybar, widgety)")
bind(mainMod .. " + ESCAPE", hl.dsp.exec_cmd(lockMenu), "Menu wylogowania (wlogout)")
bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"), "Zablokuj ekran")
bind(mainMod .. " + P", hl.dsp.exec_cmd(powerMenu), "Menu zasilania")
bind(mainMod .. " + O", hl.dsp.exec_cmd(procsMenu), "Procesy (zabij)")
bind(mainMod .. " + ALT + SPACE", hl.dsp.exec_cmd(chooseWallpaper), "Wybór tapety (+ kolory)")
bind(mainMod .. " + N", hl.dsp.exec_cmd(scripts .. "nightlight.sh toggle"), "Nocne światło wł./wył.")
bind(mainMod .. " + D", hl.dsp.exec_cmd(scripts .. "focus.sh toggle"), "Tryb skupienia (bez powiadomień i widżetów)")
bind(
	mainMod .. " + M",
	hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"),
	"Wyjdź z Hyprlanda"
)

-- === menu rofi ===
bind(mainMod .. " + F1", hl.dsp.exec_cmd(scripts .. "keybinds.sh"), "Ściąga skrótów (ta lista)")
bind(mainMod .. " + TAB", hl.dsp.exec_cmd("qs -c widgets ipc call overview toggle"), "Podgląd workspace'ów")
bind(mainMod .. " + period", hl.dsp.exec_cmd(scripts .. "emoji.sh"), "Emoji")
bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd(scripts .. "wifi-menu.py"), "Wi-Fi")
bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd(scripts .. "bluetooth-menu.sh"), "Bluetooth")
bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd(scripts .. "power-profile.sh menu"), "Profil zasilania")

-- === focus ===
bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }), "Fokus w lewo")
bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }), "Fokus w prawo")
bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }), "Fokus w górę")
bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }), "Fokus w dół")

-- === workspaces ===
for i = 1, 10 do
	local key = i % 10
	bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }), "Workspace " .. i)
	bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }), "Przenieś okno na workspace " .. i)
end

-- === scratchpad (magic) — pozostałe scratchpady: modules/scratchpads.lua ===
bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"), "Scratchpad: magic")
bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }), "Wrzuć okno do magic")

-- === screenshot / nagrywanie ===
bind("Print", hl.dsp.exec_cmd(scripts .. "screenshot.sh region"), "Zrzut: obszar")
bind(mainMod .. " + Print", hl.dsp.exec_cmd(scripts .. "screenshot.sh window"), "Zrzut: okno")
bind(mainMod .. " + SHIFT + Print", hl.dsp.exec_cmd(scripts .. "screenshot.sh output"), "Zrzut: ekran")
bind(mainMod .. " + ALT + R", hl.dsp.exec_cmd(scripts .. "record.sh region"), "Nagrywanie obszaru (start/stop)")
bind(mainMod .. " + ALT + SHIFT + R", hl.dsp.exec_cmd(scripts .. "record.sh menu"), "Menu nagrywania")

-- === resize mode (SUPER + ALT + arrows) ===
bind(mainMod .. " + ALT + right", hl.dsp.window.resize({ x = 50, y = 0 }), "Poszerz okno")
bind(mainMod .. " + ALT + left", hl.dsp.window.resize({ x = -50, y = 0 }), "Zwęź okno")
bind(mainMod .. " + ALT + up", hl.dsp.window.resize({ x = 0, y = -50 }), "Zmniejsz wysokość okna")
bind(mainMod .. " + ALT + down", hl.dsp.window.resize({ x = 0, y = 50 }), "Zwiększ wysokość okna")

-- === mysz ===
bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), "Następny workspace")
bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }), "Poprzedni workspace")
bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), "Przeciągnij okno", { mouse = true })
bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), "Zmień rozmiar okna", { mouse = true })

-- === klapa laptopa === → modules/monitors.lua (razem z logiką eDP-1)

-- === multimedia / głośność / jasność — przez swayosd, żeby pokazywał się OSD ===
local osd = "swayosd-client --monitor \"$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')\" "
local media = { locked = true, repeating = true }
bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(osd .. "--output-volume +5 --max-volume 100"), "Głośniej", media)
bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(osd .. "--output-volume -5"), "Ciszej", media)
bind("XF86AudioMute", hl.dsp.exec_cmd(osd .. "--output-volume mute-toggle"), "Wycisz", { locked = true })
bind("XF86AudioMicMute", hl.dsp.exec_cmd(osd .. "--input-volume mute-toggle"), "Wycisz mikrofon", { locked = true })
bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(osd .. "--brightness +5"), "Jaśniej", media)
bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(osd .. "--brightness -5"), "Ciemniej", media)
bind("XF86AudioNext", hl.dsp.exec_cmd(osd .. "--playerctl next"), "Następny utwór", { locked = true })
bind("XF86AudioPause", hl.dsp.exec_cmd(osd .. "--playerctl play-pause"), "Pauza", { locked = true })
bind("XF86AudioPlay", hl.dsp.exec_cmd(osd .. "--playerctl play-pause"), "Odtwórz / pauza", { locked = true })
bind("XF86AudioPrev", hl.dsp.exec_cmd(osd .. "--playerctl prev"), "Poprzedni utwór", { locked = true })
-- Caps Lock: OSD po puszczeniu klawisza (stan już zmieniony)
bind("Caps_Lock", hl.dsp.exec_cmd("sleep 0.1; " .. osd .. "--caps-lock"), "OSD Caps Lock", { release = true, non_consuming = true })
