#!/usr/bin/env python3
"""Capa 3: macOS menu bar layout in ~/.config/omarchy/shell.json (hot-reloads).

Left: Omarchy menu (the "Apple" menu) + focused window title.
Center: workspaces. Right: every status widget, clock last.
Keeps any widget it doesn't know about (it lands on the right). Safe to re-run.
Also run: omarchy bar background glassy
"""
import json
import os

p = os.path.expanduser("~/.config/omarchy/shell.json")
cfg = json.load(open(p))
cfg["bar"].pop("transparent", None)  # superseded by "background"
L = cfg["bar"]["layout"]
sections = ("left", "centerBegin", "center", "centerEnd", "right")
order = [w for sec in sections for w in L.get(sec, [])]
items = {w["id"]: w for w in order}


def pick(*ids):
    return [items.pop(i) for i in ids if i in items]


clock = items.pop("omarchy.clock", {"id": "omarchy.clock"})
clock["format"] = "ddd d MMM  HH:mm"  # macOS: "Fri 6 Nov  19:38"
clock["formatAlt"] = "dddd d MMMM yyyy  'W'ww"
title = pick("omarchy.active-window") or [{"id": "omarchy.active-window"}]
title[0].setdefault("maxWidth", 320)

L["left"] = pick("omarchy.menu") + title
L["center"] = pick("omarchy.workspaces")
L["centerBegin"], L["centerEnd"] = [], []
first = pick("omarchy.indicators", "omarchy.elsewhen", "omarchy.weather", "omarchy.system-update")
rest = [w for w in order if w["id"] in items]  # original order of everything else
L["right"] = first + rest + [clock]

assert sum(len(L[s]) for s in sections) == len({w["id"] for s in sections for w in L[s]}), "duplicate widget"

tmp = p + ".tmp"
with open(tmp, "w") as f:
    json.dump(cfg, f, indent=2)
os.chmod(tmp, 0o600)
os.replace(tmp, p)
print({s: [w["id"] for w in L[s]] for s in sections})
