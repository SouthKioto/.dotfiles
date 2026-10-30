#!/usr/bin/env python3
# Workspace'y w waybarze: numer + jedna ikona na aplikację, w tooltipie lista okien.
# Wbudowany hyprland/workspaces nie umie ani deduplikacji ikon, ani tooltipów,
# więc każdy workspace to osobny moduł custom/ws#N, który robi tylko `cat` pliku.
# Ten skrypt (moduł custom/ws-daemon) słucha eventów Hyprlanda, zapisuje pliki
# $XDG_RUNTIME_DIR/waybar-workspaces/<monitor>/<N>.json i budzi moduły sygnałem.

import fcntl
import html
import json
import os
import re
import select
import socket
import subprocess
import time

SIGNAL = 14
MAX_WORKSPACE = 10
TITLE_LENGTH = 50
DEBOUNCE = 0.05
DEFAULT_ICON = ""

# (regex klasy, ikona, nazwa w tooltipie)
APPS = [
    (r"kitty", "", "Terminal"),
    (r"brave-browser", "", "Brave"),
    (r"code-oss", "", "Code"),
    (r"spotify", "", "Spotify"),
    (r"vesktop", "", "Vesktop"),
    (r"obsidian", "", "Obsidian"),
    (r"org\.gnome\.Nautilus", "", "Pliki"),
    (r"steam", "", "Steam"),
    (r"mpv", "", "mpv"),
    (r"org\.pwmt\.zathura", "", "Zathura"),
    (r"libreoffice-.*", "", "LibreOffice"),
]

STATE_DIR = os.path.join(os.environ.get("XDG_RUNTIME_DIR", "/tmp"), "waybar-workspaces")
SOCKET = os.path.join(
    os.environ["XDG_RUNTIME_DIR"], "hypr", os.environ["HYPRLAND_INSTANCE_SIGNATURE"], ".socket2.sock"
)


def hyprctl(what):
    out = subprocess.run(["hyprctl", "-j", what], capture_output=True, text=True).stdout
    return json.loads(out or "[]")


def app_for(cls):
    for pattern, icon, name in APPS:
        if re.fullmatch(pattern, cls):
            return icon, name
    return DEFAULT_ICON, cls or "?"


def shorten(text):
    return text if len(text) <= TITLE_LENGTH else text[: TITLE_LENGTH - 1] + "…"


def render():
    """Zwraca {(monitor, id): json} dla wszystkich workspace'ów 1..MAX_WORKSPACE."""
    active = {m["name"]: m["activeWorkspace"]["id"] for m in hyprctl("monitors")}
    clients = hyprctl("clients")
    result = {}
    for ws in hyprctl("workspaces"):
        wid = ws.get("id", 0)
        if not 1 <= wid <= MAX_WORKSPACE:
            continue
        windows = [c for c in clients if c.get("workspace", {}).get("id") == wid and c.get("mapped", True)]
        windows.sort(key=lambda c: (c["at"][0], c["at"][1]))

        icons, lines = [], []
        for c in windows:
            icon, name = app_for(c["class"])
            if icon not in icons:
                icons.append(icon)
            title = html.escape(shorten(c["title"]))
            lines.append(f"{icon}  {html.escape(name)}  <span alpha='55%'>{title}</span>")

        classes = []
        if active.get(ws["monitor"]) == wid:
            classes.append("active")
        if not windows:
            classes.append("empty")
        result[(ws["monitor"], wid)] = json.dumps({
            "text": " ".join([str(wid)] + icons),
            "tooltip": f"Workspace {wid}\n" + ("\n".join(lines) if lines else "<span alpha='55%'>pusty</span>"),
            "class": classes,
        })
    return result


def write(state, previous):
    if state == previous:
        return
    # zapis przez rename, bo moduły mogą akurat czytać pliki z poprzedniego sygnału
    for (monitor, wid), data in state.items():
        os.makedirs(os.path.join(STATE_DIR, monitor), exist_ok=True)
        path = os.path.join(STATE_DIR, monitor, f"{wid}.json")
        with open(path + ".tmp", "w") as f:
            f.write(data + "\n")
        os.replace(path + ".tmp", path)
    for (monitor, wid) in (previous or {}).keys() - state.keys():
        try:
            os.remove(os.path.join(STATE_DIR, monitor, f"{wid}.json"))
        except FileNotFoundError:
            pass
    subprocess.run(["pkill", f"-RTMIN+{SIGNAL}", "-x", "waybar"])


def main():
    # przy kilku paskach (kilka monitorów) każdy odpala ten moduł; działa tylko jeden,
    # reszta czeka na locku i przejmuje robotę, gdy tamten zniknie
    lock = open(os.path.join(os.environ["XDG_RUNTIME_DIR"], "waybar-workspaces.lock"), "w")
    fcntl.flock(lock, fcntl.LOCK_EX)

    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.connect(SOCKET)
    state = render()
    write(state, None)
    while True:
        select.select([sock], [], [])
        # eventy przychodzą seriami (np. otwarcie okna = kilka linii), zbierz je razem
        deadline = time.monotonic() + DEBOUNCE
        while (wait := deadline - time.monotonic()) > 0 and select.select([sock], [], [], wait)[0]:
            if not sock.recv(65536):
                return
        new = render()
        write(new, state)
        state = new


if __name__ == "__main__":
    main()
