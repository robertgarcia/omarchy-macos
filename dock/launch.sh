#!/bin/bash
# Capa 5: starts the macOS-style dock once. Called at login by the macos theme
# (themes/macos/hyprland.lua) and by the theme-set hook when switching to it.
# A second nwg-dock-hyprland would toggle the first one's visibility, so guard.
pgrep -f '^nwg-dock-hyprland' >/dev/null && exit 0
# First run: seed the pinned apps. After that the dock owns the file (right-click > pin/unpin).
pins="${XDG_CACHE_HOME:-$HOME/.cache}/nwg-dock-pinned"
[[ -e $pins ]] || cp "$(dirname "$(realpath "$0")")/pinned" "$pins"
# Always visible, like macOS by default; -x makes windows stop above it.
# (-d autohide only reacts to a narrow strip at the bottom centre, too easy to miss.)
# The launcher button opens Omarchy's app grid, the Launchpad equivalent.
exec nwg-dock-hyprland -x -i 48 -mb 8 -lp start -c "omarchy-shell omarchy.dock apps"
