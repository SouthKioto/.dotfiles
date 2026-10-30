#!/usr/bin/env bash
# Rice: część systemowa (wymaga sudo, pyta o hasło raz). Można odpalać wielokrotnie.
# Uruchom:  bash ~/.config/rice/install.sh
# Log:      ~/.cache/rice-install.log
#
#   1. paczki            polkit, udiskie, nagrywanie, atuin, CLI, timeshift, plymouth, motywy, quickshell, hyprpm
#   2. motywy GTK/Qt     adw-gtk3 + Papirus, kolory z matugena (gtk.css, qt*ct)
#   3. Timeshift         snapshoty rsync na partycji /home + hook pacmana + timer
#   4. Plymouth          motyw "rice" w UKI (kopia starego UKI zostaje jako zapasowy wpis w systemd-boot)
#   5. SDDM              motyw "rice" jak hyprlock, tapeta/kolory synchronizowane przez wallpaper.sh
#   6. usługi usera      polkit, udiskie, widgety, tldr, import historii do atuin
#   7. pluginy           hyprpm + hyprbars (ładowany w autostart.lua, konfigurowany w plugins.lua)

set -uo pipefail
LOG="$HOME/.cache/rice-install.log"
exec > >(tee "$LOG") 2>&1

RICE="$HOME/.config/rice"
step() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
ok()   { printf '\033[1;32m  ✓ %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m  ! %s\033[0m\n' "$*"; }

sudo -v || exit 1
while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done 2>/dev/null &
KEEPALIVE=$!
trap 'kill $KEEPALIVE 2>/dev/null' EXIT

# kolor z hypr/colors.conf (matugen) → "r g b" jako ułamki 0–1 albo hex
color_hex() { sed -nE "s/^\\\$$1 *= *rgb\(([0-9a-fA-F]{6})\).*/\1/p" "$HOME/.config/hypr/colors.conf" | head -1; }
color_frac() { local h; h=$(color_hex "$1"); awk -v r=$((16#${h:0:2})) -v g=$((16#${h:2:2})) -v b=$((16#${h:4:2})) 'BEGIN { printf "%.3f %.3f %.3f", r/255, g/255, b/255 }'; }

# ─────────────────────────────────────────────────────────────
step "1/7 Paczki"
PKGS=(
    hyprpolkitagent udiskie                      # 13: okienka z hasłem, automontowanie
    wf-recorder                                  # 12: nagrywanie ekranu
    atuin tealdeer dust procs                    # 15–16: historia powłoki, nowoczesne CLI
    timeshift                                    # 2: snapshoty
    plymouth                                     # 7: ekran startowy
    adw-gtk-theme papirus-icon-theme             # 4: GTK3 pod kolory libadwaita, ikony
    rofi-emoji                                   # 11: menu emoji
    quickshell                                   # 20: widgety na pulpicie
    hyprpm                                       # 6: pluginy Hyprlanda (hyprbars)
    imagemagick
)
sudo pacman -S --needed --noconfirm "${PKGS[@]}" && ok "zainstalowane" || { warn "pacman się nie powiódł — przerywam"; exit 1; }

# ─────────────────────────────────────────────────────────────
step "2/7 Motywy GTK / Qt"
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
ok "GTK: adw-gtk3-dark + Papirus-Dark (kolory: ~/.config/gtk-*/gtk.css z matugena)"
ok "Qt: qt5ct/qt6ct → colors/matugen.conf (zmiana widoczna po restarcie aplikacji)"

# ─────────────────────────────────────────────────────────────
step "3/7 Timeshift (rsync → partycja /home)"
home_uuid=$(findmnt -no UUID /home)
sudo install -d /etc/timeshift
sed "s/@HOME_UUID@/$home_uuid/" "$RICE/timeshift/timeshift.json" | sudo tee /etc/timeshift/timeshift.json >/dev/null
sudo install -Dm755 "$RICE/pacman/pacman-snapshot" /usr/local/bin/pacman-snapshot
sudo install -Dm644 "$RICE/pacman/00-timeshift-snapshot.hook" /etc/pacman.d/hooks/00-timeshift-snapshot.hook
sudo install -Dm644 "$RICE/systemd/timeshift-check.service" /etc/systemd/system/timeshift-check.service
sudo install -Dm644 "$RICE/systemd/timeshift-check.timer" /etc/systemd/system/timeshift-check.timer
sudo systemctl daemon-reload
sudo systemctl enable --now timeshift-check.timer >/dev/null && ok "timer: codzienne (4) + tygodniowe (2) snapshoty"
ok "hook pacmana: snapshot przed każdą instalacją/aktualizacją (max 1/h, trzyma 5)"
if sudo timeshift --list --scripted 2>/dev/null | grep -q 'pierwszy snapshot'; then
    ok "pierwszy snapshot już istnieje"
else
    echo "  Pierwszy snapshot kopiuje cały system (~kilkanaście GB) — to potrwa kilka minut."
    echo "  Kolejne są przyrostowe (hardlinki) i trwają sekundy."
    sudo timeshift --create --scripted --tags O --comments "rice: pierwszy snapshot" && ok "pierwszy snapshot gotowy" || warn "snapshot się nie udał (szczegóły wyżej)"
fi

# ─────────────────────────────────────────────────────────────
step "4/7 Plymouth (motyw rice w UKI)"
THEME_DIR=/usr/share/plymouth/themes/rice
read -r bg_r bg_g bg_b <<<"$(color_frac surface)"
read -r fg_r fg_g fg_b <<<"$(color_frac on_surface)"
tmp=$(mktemp -d)
sed -e "s/@BG_R@/$bg_r/g; s/@BG_G@/$bg_g/g; s/@BG_B@/$bg_b/g" \
    -e "s/@FG_R@/$fg_r/g; s/@FG_G@/$fg_g/g; s/@FG_B@/$fg_b/g" \
    "$RICE/plymouth/rice/rice.script.in" >"$tmp/rice.script"
magick -size 16x16 xc:none -fill "#$(color_hex primary)" -draw "circle 8,8 8,2" "$tmp/dot.png"
sudo install -d "$THEME_DIR"
sudo install -m644 "$RICE/plymouth/rice/rice.plymouth" "$tmp/rice.script" "$tmp/dot.png" "$THEME_DIR/"
rm -rf "$tmp"
ok "motyw zainstalowany (tło #$(color_hex surface), spinner #$(color_hex primary))"

# kopia działającego UKI — systemd-boot sam pokaże ją w menu jako osobny wpis
if [[ -f /boot/EFI/Linux/arch-linux.efi && ! -f /boot/EFI/Linux/arch-linux-pre-plymouth.efi ]]; then
    sudo cp /boot/EFI/Linux/arch-linux.efi /boot/EFI/Linux/arch-linux-pre-plymouth.efi
    ok "kopia UKI: /boot/EFI/Linux/arch-linux-pre-plymouth.efi (zapasowy wpis w menu startowym)"
fi
sudo cp -n /etc/mkinitcpio.conf /etc/mkinitcpio.conf.pre-plymouth
sudo cp -n /etc/kernel/cmdline /etc/kernel/cmdline.pre-plymouth

if ! grep -qE '^HOOKS=.*\bplymouth\b' /etc/mkinitcpio.conf; then
    sudo sed -i -E 's/^(HOOKS=\(.*\budev\b)/\1 plymouth/' /etc/mkinitcpio.conf
fi
grep -E '^HOOKS=' /etc/mkinitcpio.conf | sed 's/^/  /'
for opt in quiet splash; do
    grep -qw "$opt" /etc/kernel/cmdline || sudo sed -i "s/\$/ $opt/" /etc/kernel/cmdline
done
echo "  cmdline: $(cat /etc/kernel/cmdline)"
sudo plymouth-set-default-theme rice
if sudo mkinitcpio -P; then
    ok "UKI przebudowany z Plymouth"
else
    warn "mkinitcpio się nie powiódł — przywracam poprzednią konfigurację"
    sudo cp /etc/mkinitcpio.conf.pre-plymouth /etc/mkinitcpio.conf
    sudo cp /etc/kernel/cmdline.pre-plymouth /etc/kernel/cmdline
    sudo mkinitcpio -P
fi

# ─────────────────────────────────────────────────────────────
step "5/7 SDDM (motyw rice)"
SDDM_DIR=/usr/share/sddm/themes/rice
sudo install -d "$SDDM_DIR"
sudo install -m644 "$RICE/sddm/rice/Main.qml" "$RICE/sddm/rice/metadata.desktop" "$RICE/sddm/rice/theme.conf" "$SDDM_DIR/"
# dynamic/ należy do usera — wallpaper.sh podmienia tam tapetę i kolory bez sudo
sudo install -d -o "$USER" -g "$USER" -m755 "$SDDM_DIR/dynamic"
cp ~/Obrazy/curr_wallpaper/curr_wallpaper.png "$SDDM_DIR/dynamic/background.png"
cp "$RICE/sddm/rice/dynamic/avatar.png" "$RICE/sddm/rice/dynamic/theme.conf.user" "$SDDM_DIR/dynamic/"
sudo ln -sfn dynamic/theme.conf.user "$SDDM_DIR/theme.conf.user"
sudo install -d /etc/sddm.conf.d
printf '[Theme]\nCurrent=rice\n' | sudo tee /etc/sddm.conf.d/10-theme.conf >/dev/null
ok "SDDM → rice (podgląd: sddm-greeter-qt6 --test-mode --theme $SDDM_DIR)"

# ─────────────────────────────────────────────────────────────
step "6/7 Usługi i dane użytkownika"
systemctl --user start hyprpolkitagent && ok "agent polkit działa"
pgrep -x udiskie >/dev/null || { setsid -f udiskie --smart-tray --notify >/dev/null 2>&1; ok "udiskie działa"; }
pgrep -f 'qs -c widgets' >/dev/null || { setsid -f qs -c widgets >/dev/null 2>&1; ok "widgety na pulpicie działają"; }
tldr --update >/dev/null 2>&1 && ok "tldr: pobrane ściągi"
atuin import auto >/dev/null 2>&1 && ok "atuin: zaimportowana historia fisha"

# ─────────────────────────────────────────────────────────────
step "7/7 Pluginy Hyprlanda (hyprpm)"
echo "  hyprpm buduje pluginy lokalnie pod Twoją wersję Hyprlanda (sam pyta o sudo/zaufanie repo)."
echo "  Ładuje je autostart.lua (hyprctl plugin load), więc 'hyprpm enable' nie jest potrzebne."
echo "  (hyprexpo wypadł z hyprland-plugins — podgląd workspace'ów robi Quickshell, SUPER + TAB)"
hyprpm update
hyprpm list 2>/dev/null | grep -q hyprland-plugins || hyprpm add https://github.com/hyprwm/hyprland-plugins
so="/var/cache/hyprpm/$USER/hyprland-plugins/hyprbars.so"
if [[ -f $so ]] && hyprctl plugin load "$so" >/dev/null && hyprctl reload >/dev/null; then
    ok "hyprbars załadowany (paski tytułowe na oknach pływających)"
else
    warn "hyprbars się nie załadował — szczegóły wyżej"
fi

step "Gotowe"
echo "  log: $LOG"
echo "  Plymouth i SDDM zobaczysz po restarcie. Gdyby start się wysypał: w menu systemd-boot"
echo "  wybierz wpis z arch-linux-pre-plymouth.efi."
