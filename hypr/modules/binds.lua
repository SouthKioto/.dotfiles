---------------------
---- MY PROGRAMS ----
---------------------
local terminal = "kitty"
local fileManager = terminal .. " -e yazi"
local menu = "~/.config/hypr/scripts/launcher.sh"
local lockMenu = "wlogout"
local chooseWallpaper = "~/.config/hypr/scripts/wallpaper.sh"
local powerMenu = "~/.config/rofi/scripts/power-menu.sh"
local procsMenu = "~/.config/waybar/scripts/procs-menu.sh"
local LID = os.getenv("HOME") .. "/.config/hypr/lid.sh"

---------------------
---- KEYBINDINGS ----
---------------------
local mainMod = "SUPER"

-- === podstawowe ===
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + W", hl.dsp.window.close())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("/home/kioto/.config/waybar/scripts/launch.sh"))
hl.bind(mainMod .. " + ESCAPE", hl.dsp.exec_cmd(lockMenu))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd(powerMenu))
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd(procsMenu))
hl.bind(mainMod .. " + ALT + SPACE", hl.dsp.exec_cmd(chooseWallpaper))
hl.bind(
	mainMod .. " + M",
	hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'")
)

-- === focus ===
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- === workspaces ===
for i = 1, 10 do
	local key = i % 10
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- === scratchpad (magic) ===
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- === scratchpad terminal (SUPER + `) ===
hl.bind(mainMod .. " + grave", hl.dsp.workspace.toggle_special("term"))
hl.bind(mainMod .. " + SHIFT + grave", hl.dsp.exec_cmd(terminal .. " --class=scratchterm"))

-- === screenshot ===
hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m region -- | swappy -f -"))
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("hyprshot -m window -- | swappy -f -"))
hl.bind(mainMod .. " + SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m output -- | swappy -f -"))

-- === resize mode (SUPER + ALT + arrows) ===
hl.bind(mainMod .. " + ALT + right", hl.dsp.window.resize({ x = 50, y = 0 }))
hl.bind(mainMod .. " + ALT + left", hl.dsp.window.resize({ x = -50, y = 0 }))
hl.bind(mainMod .. " + ALT + up", hl.dsp.window.resize({ x = 0, y = -50 }))
hl.bind(mainMod .. " + ALT + down", hl.dsp.window.resize({ x = 0, y = 50 }))

-- === mysz ===
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd(LID .. " close"), { locked = true })
hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd(LID .. " open"), { locked = true })

-- === multimedia / głośność ===
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
