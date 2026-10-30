#!/usr/bin/env bash
# Dodatki do rice'a (2026-10-28) — części wymagające sudo. Konfiguracje są już na miejscu.
#   1. nocne światło        hyprsunset          (hypr/hyprsunset.conf, SUPER + N)
#   2. ochrona przed OOM    systemd-oomd + polityki ManagedOOM (Arch ich domyślnie nie ma)
#   3. szybkie mirrory      reflector (PL/DE, raz w tygodniu)
#   4. PDF / wideo / zdjęcia zathura, mpv, imv + domyślne w mimeapps.list
#   6. adnotacje zrzutów    satty               (hypr/scripts/screenshot.sh)
#   5. kopie zapasowe       restic              (konfiguracja osobno)
set -euo pipefail

echo "==> Pakiety"
sudo pacman -S --needed hyprsunset reflector zathura zathura-pdf-mupdf mpv imv satty restic

echo "==> systemd-oomd"
# jak w Fedorze (systemd-oomd-defaults): całość przy braku swapu, sesja użytkownika przy dużym ciśnieniu pamięci
sudo install -Dm644 /dev/stdin /etc/systemd/system/-.slice.d/10-oomd-root-slice-defaults.conf <<'EOF'
[Slice]
ManagedOOMSwap=kill
EOF
sudo install -Dm644 /dev/stdin /etc/systemd/system/user@.service.d/10-oomd-user-service-defaults.conf <<'EOF'
[Service]
ManagedOOMMemoryPressure=kill
ManagedOOMMemoryPressureLimit=50%
EOF
sudo install -Dm644 /dev/stdin /etc/systemd/oomd.conf.d/10-rice.conf <<'EOF'
[OOM]
DefaultMemoryPressureDurationSec=20s
EOF
sudo systemctl daemon-reload
sudo systemctl enable --now systemd-oomd.service

echo "==> reflector"
sudo install -Dm644 /dev/stdin /etc/xdg/reflector/reflector.conf <<'EOF'
# reflector.timer: raz w tygodniu najszybsze mirrory HTTPS z Polski i Niemiec
--save /etc/pacman.d/mirrorlist
--protocol https
--country Poland,Germany
--age 12
--latest 20
--sort rate
EOF
[[ -f /etc/pacman.d/mirrorlist.przed-reflector ]] || sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.przed-reflector
sudo systemctl enable --now reflector.timer
sudo systemctl start reflector.service || echo "   (reflector: nie udało się teraz — spróbuje timer)"

echo "==> Domyślne aplikacje"
pdf=org.pwmt.zathura-pdf-mupdf.desktop
[[ -f /usr/share/applications/$pdf ]] || pdf=org.pwmt.zathura.desktop
xdg-mime default "$pdf" application/pdf
xdg-mime default imv.desktop image/png image/jpeg image/jpg image/webp image/gif image/bmp image/tiff
xdg-mime default mpv.desktop video/mp4 video/x-matroska video/webm video/quicktime video/x-msvideo audio/mpeg audio/flac audio/ogg audio/x-wav
# SVG zostaje w GIMP-ie (imv nie wyświetla wektorów dobrze)

echo "==> Uruchomienie bez wylogowania"
if [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]]; then
    pgrep -x hyprsunset >/dev/null || hyprctl dispatch 'hl.dsp.exec_cmd("hyprsunset")' >/dev/null
    pkill -RTMIN+11 -x waybar || true
fi

echo
echo "Gotowe. Kopia starej listy mirrorów: /etc/pacman.d/mirrorlist.przed-reflector"
systemctl is-active systemd-oomd reflector.timer | paste -sd' ' | sed 's/^/oomd, reflector.timer: /'
