#!/usr/bin/env python3
# Moduł waybara custom/mpris: tytuł utworu z przewijaniem.
# Zamiast odpytywać playerctl co 0.4 s, nasłuchuje zmian (playerctl --follow)
# i budzi się co SCROLL_INTERVAL tylko wtedy, gdy długi tytuł faktycznie się przewija.

import json
import select
import subprocess
import time

GLYPH_FONT_FAMILY = "Symbols Nerd Font Mono"
GLYPHS = {"playing": "", "paused": "", "stopped": ""}
TEXT_WHEN_STOPPED = "Nothing playing right now"
SCROLL_TEXT_LENGTH = 25
SCROLL_INTERVAL = 0.4
SEP = "\x1f"


def emit(glyph, text):
    span = f"<span font_family='{GLYPH_FONT_FAMILY}'>{glyph}</span>"
    print(json.dumps({"text": f"{span} {text}"}), flush=True)


def follow():
    return subprocess.Popen(
        ["playerctl", "--follow", "metadata", "--format", "{{lc(status)}}" + SEP + "{{title}}"],
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
        bufsize=1,
    )


def main():
    status, title, offset = "stopped", "", 0
    emit(GLYPHS["stopped"], TEXT_WHEN_STOPPED.ljust(SCROLL_TEXT_LENGTH))
    proc = follow()
    while True:
        scrolling = status == "playing" and len(title) > SCROLL_TEXT_LENGTH
        ready, _, _ = select.select([proc.stdout], [], [], SCROLL_INTERVAL if scrolling else None)

        if ready:
            line = proc.stdout.readline()
            if not line:  # playerctl padł — odpal ponownie
                proc.wait()
                time.sleep(2)
                proc = follow()
                continue
            new_status, _, new_title = line.rstrip("\n").partition(SEP)
            if new_title != title:
                offset = 0
            status, title = (new_status or "stopped"), new_title
        else:
            offset += 1

        if not title:
            emit(GLYPHS["stopped"], TEXT_WHEN_STOPPED.ljust(SCROLL_TEXT_LENGTH))
        elif len(title) <= SCROLL_TEXT_LENGTH:
            emit(GLYPHS.get(status, ""), title.ljust(SCROLL_TEXT_LENGTH))
        else:
            loop = title + "   "
            i = offset % len(loop)
            emit(GLYPHS.get(status, ""), (loop + loop)[i : i + SCROLL_TEXT_LENGTH])


if __name__ == "__main__":
    main()
