#!/usr/bin/env bash
# Jednorazowe porządki systemowe (wymaga sudo, pyta o hasło raz).
# Uruchom:  bash ~/.config/hypr/scripts/system-setup.sh
# Log:      ~/.cache/system-setup.log

set -uo pipefail
LOG="$HOME/.cache/system-setup.log"
exec > >(tee "$LOG") 2>&1

step() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
ok()   { printf '\033[1;32m  ✓ %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m  ! %s\033[0m\n' "$*"; }

installed() { pacman -Qq "$@" 2>/dev/null; }

sudo -v || exit 1
# podtrzymuj sudo do końca skryptu
while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done 2>/dev/null &
KEEPALIVE=$!
trap 'kill $KEEPALIVE 2>/dev/null' EXIT

df_before=$(df --output=avail -BM / | tail -1)

# ─────────────────────────────────────────────────────────────
step "1/6 TLP: na zasilaczu turbo + balance_performance"
sudo sed -i 's/^CPU_ENERGY_PERF_POLICY_ON_AC=performance/CPU_ENERGY_PERF_POLICY_ON_AC=balance_performance/' /etc/tlp.conf
sudo tlp start >/dev/null && ok "TLP przeładowany"
echo "  no_turbo=$(cat /sys/devices/system/cpu/intel_pstate/no_turbo)  EPP=$(cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference)"

# ─────────────────────────────────────────────────────────────
step "2/6 Instalacja: polkit, narzędzia dev, gaming"
PKGS=(
    hyprpolkitagent papirus-icon-theme pacman-contrib
    # dev
    mise lazygit git-delta fd shellcheck shfmt tealdeer
    # gry
    gamemode lib32-gamemode gamescope mangohud lib32-mangohud ttf-liberation
)
sudo pacman -S --needed --noconfirm "${PKGS[@]}" && ok "zainstalowane"
sudo usermod -aG gamemode "$USER" && ok "$USER w grupie gamemode (działa po ponownym zalogowaniu)"
systemctl --user daemon-reload
systemctl --user start hyprpolkitagent && ok "agent polkit działa"

# ─────────────────────────────────────────────────────────────
step "3/6 Oznaczam jako jawnie zainstalowane to, czego używasz (żeby nie zniknęło z illogical-impulse)"
KEEP=(
    hyprland hyprlock hypridle hyprpicker hyprshot xdg-desktop-portal xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland xorg-xwayland wl-clipboard cliphist grim slurp swappy wlogout
    brightnessctl playerctl pavucontrol-qt qt6-wayland matugen upower libdbusmenu-gtk3 cava
    kitty fish starship eza ttf-jetbrains-mono-nerd gnome-keyring imagemagick
    jq ripgrep go-yq uv rsync wget curl go
)
mapfile -t keep_ok < <(installed "${KEEP[@]}")
sudo pacman -D --asexplicit "${keep_ok[@]}" >/dev/null && ok "${#keep_ok[@]} pakietów zabezpieczonych"

# ─────────────────────────────────────────────────────────────
step "4/6 Usuwam zbędne aplikacje"
mapfile -t remove < <(
    { pacman -Qq | grep -E '^illogical-impulse-|-debug$'
      installed alacritty ghostty zen-browser-bin browsh-bin dunst cbonsai unimatrix-git fnt; } | sort -u
)
if ((${#remove[@]})); then
    printf '  %s\n' "${remove[@]}" | column -c 100
    sudo pacman -Rns --noconfirm "${remove[@]}" && ok "usunięto ${#remove[@]} pakietów (+ ich zależności)" \
        || warn "pacman odmówił — szczegóły wyżej, nic nie zostało usunięte"
else
    ok "nic do usunięcia"
fi

# ─────────────────────────────────────────────────────────────
step "5/6 Osierocone pakiety (resztki po budowaniu z AUR itp.)"
for _ in 1 2 3; do
    mapfile -t orphans < <(pacman -Qdtq)
    ((${#orphans[@]})) || break
    printf '  %s\n' "${orphans[@]}" | column -c 100
    sudo pacman -Rns --noconfirm "${orphans[@]}" || { warn "nie udało się usunąć części sierot"; break; }
done
ok "brak sierot"

# ─────────────────────────────────────────────────────────────
step "6/6 Czyszczenie cache"
sudo paccache -rk1 -q && sudo paccache -ruk0 -q && ok "cache pacmana: zostawiona 1 wersja każdego pakietu"
rm -rf "$HOME/.cache/yay/"* && ok "cache yay (stare buildy AUR) wyczyszczony"
sudo journalctl --vacuum-size=200M -q && ok "journal przycięty do 200 MB"

df_after=$(df --output=avail -BM / | tail -1)
step "Gotowe"
echo "  wolne miejsce na /:  ${df_before// /} → ${df_after// /}"
echo "  log: $LOG"
echo "  Docker zostaje bez zmian (działają kontenery openplc-runtime i auto-detailing)."
echo "  Wyloguj się i zaloguj ponownie (SUPER+M), żeby zadziałały grupa gamemode i nowe zmienne środowiskowe."
