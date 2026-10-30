# dotfiles · Hyprland na Arch

Rice na Hyprland (config w Lua), na którym cały system bierze kolory z tapety przez **matugen**.
Repo to `~/.config` w trybie *whitelist*: `.gitignore` domyślnie ignoruje wszystko, a wersjonowane są tylko jawnie odblokowane katalogi.

| | |
|---|---|
| WM | Hyprland 0.56 (Lua: `hypr/hyprland.lua` + `hypr/modules/*.lua`) |
| Pasek | waybar |
| Launcher / menu | rofi (`hypr/scripts/*.sh`) |
| Powiadomienia / OSD | swaync / swayosd |
| Widgety / podgląd workspace'ów | Quickshell (`quickshell/widgets`) |
| Pluginy | hyprbars przez hyprpm (`hypr/modules/plugins.lua`) |
| Terminal / powłoka | kitty (+ ghostty) / fish + starship + atuin |
| Pliki / edytor | yazi / Neovim |
| Blokada / logowanie / boot | hyprlock / SDDM (`rice/sddm`) / Plymouth (`rice/plymouth`) |
| Tapety | awww + `hypr/scripts/wallpaper.sh` (SUPER + ALT + SPACE) |
| Snapshoty | Timeshift (rsync) + hook pacmana |

## Instalacja na nowej maszynie

```bash
git clone --recurse-submodules git@github.com:SouthKioto/.dotfiles.git ~/.config
bash ~/.config/rice/install.sh        # paczki, Timeshift, Plymouth, SDDM, hyprbars (pyta o sudo raz)
~/.config/hypr/scripts/wallpaper.sh   # wybierz tapetę → matugen wygeneruje wszystkie kolory
```

`fish`, `ghostty` i `nvim` to submoduły, czyli osobne repo.

## Kolory: jedna tapeta, cały system

`wallpaper.sh` → `matugen image` → szablony z `matugen/config.toml`:

- **pulpit:** Hyprland (`colors.conf` czytany w `decorations.lua`), waybar, rofi, swaync, wlogout, hyprlock, swayosd, widgety Quickshell
- **aplikacje:** GTK3/GTK4 (`gtk.css`, motyw adw-gtk3), Qt (`qt*ct/colors/matugen.conf`), Vesktop
- **terminal:** kitty, ghostty, zellij, btop, cava, yazi, lazygit, spotify-player (fzf, bat i delta biorą paletę ANSI z kitty)
- **logowanie:** SDDM (`wallpaper.sh` kopiuje tapetę i kolory do `/usr/share/sddm/themes/rice/dynamic`)

Plymouth dostaje kolory w chwili `rice/install.sh`, bo siedzi w initramfs. Żeby je odświeżyć, uruchom skrypt jeszcze raz.

Szablony leżą w `matugen/templates/` oraz obok swoich aplikacji (`*.template`).

## Skróty

Pełna lista: **SUPER + F1**. Generuje się na żywo z `description` w `hypr/modules/binds.lua`.

| Skrót | |
|---|---|
| `SUPER + SPACE` / `F1` | launcher / ściąga skrótów |
| `SUPER + grave / B / Y / C / A` | scratchpady: terminal, btop, muzyka, kalkulator, mikser |
| `SUPER + .` | emoji |
| `SUPER + SHIFT + W` / `B` / `P` | Wi-Fi (iwd) / Bluetooth / profil zasilania |
| `SUPER + SHIFT + V` | historia schowka |
| `SUPER + TAB` | podgląd workspace'ów z żywymi miniaturami (Quickshell) |
| `Print` / `SUPER + ALT + R` | zrzut obszaru / nagrywanie obszaru (start/stop) |

## Zasilanie

TLP (`tlp-pd`) udostępnia profile przez D-Bus. `power-profile.sh watch` reaguje na każdą zmianę profilu, także tę automatyczną po odpięciu zasilacza. W trybie **power-saver** `hypr/modules/powersave.lua` wyłącza animacje, blur i przyciemnianie.

## Snapshoty

- przed każdym `pacman`/`yay`: snapshot Timeshift (najwyżej jeden na godzinę, trzymane 5 ostatnich), skrypt w `rice/pacman/`
- codzienne i tygodniowe przez `timeshift-check.timer`
- snapshoty leżą na partycji `/home` w `/home/timeshift` i obejmują system bez `/home`
- przywracanie: `sudo timeshift --restore` (albo z live USB, jeśli system nie wstaje)

To ochrona przed zepsutą aktualizacją, **nie backup**. Dane nadal leżą na tym samym dysku.
