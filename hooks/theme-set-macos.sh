#!/bin/bash
# Omarchy theme-set hook (Capa 4): GTK theme, cursor and UI font follow the
# macos theme. Switching to any other theme undoes only what this hook set.
# Runs after omarchy-theme-set-gnome, which has just reset gtk-theme to Adwaita-dark.
theme=$1
iface=org.gnome.desktop.interface
gtk4="$HOME/.config/gtk-4.0"
whitesur=/usr/share/themes/WhiteSur-Dark
marker="/* omarchy-macos: generated, removed when leaving the macos theme */"
cursor=macOS
font="Inter 11"

ours() { [[ -f $gtk4/gtk.css && $(head -1 "$gtk4/gtk.css") == "$marker" ]]; }

# libadwaita (GTK4) ignores gtk-theme and only reads ~/.config/gtk-4.0/gtk.css.
# WhiteSur ships its GTK4 CSS inside a gresource that only a named theme can
# reach, so unpack it next to gtk.css (its asset URLs are relative).
unpack_whitesur_gtk4() {
  rm -rf "$gtk4/whitesur"
  python3 -I - "$whitesur/gtk-4.0/gtk.gresource" "$gtk4/whitesur" <<'EOF' || return 1
import os, sys
import gi
from gi.repository import Gio
res, dest = Gio.Resource.load(sys.argv[1]), sys.argv[2]
root = "/org/gnome/theme/"
def walk(p):
    for c in res.enumerate_children(p, 0):
        yield from walk(p + c) if c.endswith("/") else [p + c]
for path in walk(root):
    out = os.path.join(dest, path[len(root):])
    os.makedirs(os.path.dirname(out), exist_ok=True)
    with open(out, "wb") as f:
        f.write(res.lookup_data(path, 0).get_data())
EOF
  printf '%s\n@import url("whitesur/gtk-dark.css");\n' "$marker" >"$gtk4/gtk.css"
}

if [[ $theme == macos ]]; then
  if [[ -d $whitesur ]]; then
    gsettings set $iface gtk-theme WhiteSur-Dark
    mkdir -p "$gtk4"
    if [[ ! -e $gtk4/gtk.css ]] || ours; then # never replace the user's own gtk.css
      unpack_whitesur_gtk4 || echo "omarchy-macos: could not unpack WhiteSur for GTK4" >&2
    fi
  fi
  if [[ -d /usr/share/icons/$cursor ]]; then
    gsettings set $iface cursor-theme $cursor # Omarchy re-reads this at login
    hyprctl setcursor $cursor 24 >/dev/null
  fi
  fc-list -q Inter && gsettings set $iface font-name "$font"
  dock=~/.config/nwg-dock-hyprland/launch.sh
  [[ -x $dock ]] && setsid -f "$dock" >/dev/null 2>&1
else
  pkill -f '^nwg-dock-hyprland' || true
  if ours; then
    rm -rf "$gtk4/gtk.css" "$gtk4/whitesur"
  fi
  if [[ $(gsettings get $iface cursor-theme) == "'$cursor'" ]]; then
    gsettings set $iface cursor-theme default
    hyprctl setcursor default 24 >/dev/null
  fi
  [[ $(gsettings get $iface font-name) == "'$font'" ]] && gsettings reset $iface font-name
fi
exit 0
