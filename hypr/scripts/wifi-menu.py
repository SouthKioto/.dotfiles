#!/usr/bin/env python3
# Wi-Fi w Rofi (SUPER + SHIFT + W) dla iwd: skan → lista sieci z siłą sygnału →
# połącz (hasło pytane tylko dla nowych sieci). Rozłączanie i zaawansowane → impala.

import os
import re
import subprocess
import time

THEME = os.path.expanduser("~/.config/rofi/menu.rasi")
ANSI = re.compile(r"\x1b\[[0-9;]*m")
BARS = ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"]


def run(*cmd):
    return subprocess.run(cmd, capture_output=True, text=True).stdout


def notify(title, body=""):
    subprocess.run(["notify-send", "-a", "Wi-Fi", "-i", "network-wireless", title, body])


def rofi(entries, mesg, extra=()):
    r = subprocess.run(
        ["rofi", "-dmenu", "-i", "-p", "", "-mesg", mesg, "-theme", THEME,
         "-theme-str", "window { width: 520px; } listview { lines: 10; }", *extra],
        input="\n".join(entries), capture_output=True, text=True,
    )
    return r.stdout.strip() if r.returncode == 0 else None


def device():
    for line in ANSI.sub("", run("iwctl", "station", "list")).splitlines()[4:]:
        if line.strip():
            return line.split()[0]
    return None


def networks(dev):
    nets = []
    for raw in run("iwctl", "station", dev, "get-networks").splitlines()[4:]:
        # gwiazdki sygnału: jasne = zasięg, szare (\e[1;90m) = brak
        stars = re.search(r"(\*+)(?:\x1b\[1;90m(\*+))?", raw)
        line = ANSI.sub("", raw)
        m = re.match(r"^\s{2}(>|\s)\s+(.+?)\s{2,}(psk|open|8021x|wep|owe)\s+\*+", line)
        if not m:
            continue
        strength = len(stars.group(1)) if stars else 0
        nets.append({"active": m.group(1) == ">", "ssid": m.group(2), "sec": m.group(3), "sig": strength})
    return nets


def known():
    out = ANSI.sub("", run("iwctl", "known-networks", "list")).splitlines()[4:]
    return {re.split(r"\s{2,}", l.strip())[0] for l in out if l.strip()}


def main():
    dev = device()
    if not dev:
        notify("Brak karty Wi-Fi w trybie station")
        return
    run("iwctl", "station", dev, "scan")
    time.sleep(1.5)

    nets, saved = networks(dev), known()
    entries = [
        f"{BARS[min(n['sig'], 4)]}  {n['ssid']}{'  ' if n['sec'] != 'open' else ''}{'   połączono' if n['active'] else ''}"
        for n in nets
    ]
    entries.append("󰒓  Zaawansowane (impala)")
    choice = rofi(entries, f"Wi-Fi ({dev})")
    if not choice:
        return
    if "impala" in choice:
        subprocess.Popen(["kitty", "-e", "impala"])
        return

    net = nets[entries.index(choice)]
    if net["active"]:
        return

    cmd = ["iwctl", "station", dev, "connect", net["ssid"]]
    if net["sec"] != "open" and net["ssid"] not in saved:
        pw = rofi([], f"Hasło do {net['ssid']}", ("-password", "-theme-str", "listview { enabled: false; }"))
        if not pw:
            return
        cmd = ["iwctl", "--passphrase", pw, *cmd[1:]]

    notify(f"Łączenie z {net['ssid']}…")
    ok = subprocess.run(cmd, capture_output=True, text=True, timeout=30).returncode == 0
    notify(f"Połączono z {net['ssid']}" if ok else f"Nie udało się połączyć z {net['ssid']}")


if __name__ == "__main__":
    main()
