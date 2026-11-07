#!/bin/bash
# Omarchy theme-set hook (Capa 4): GTK theme, cursor and UI font follow the
# macos theme. Switching to any other theme undoes only what this hook set.
# Runs after omarchy-theme-set-gnome, which has just reset gtk-theme to Adwaita-dark.
theme=$1
iface=org.gnome.desktop.interface
gtk4="$HOME/.config/gtk-4.0"
whitesur=/usr/share/themes/WhiteSur-Dark
cursor=macOS
font="Inter 11"

if [[ $theme == macos ]]; then
  if [[ -d $whitesur ]]; then
    gsettings set $iface gtk-theme WhiteSur-Dark
    # libadwaita (GTK4) ignores gtk-theme and only reads ~/.config/gtk-4.0.
    mkdir -p "$gtk4"
    for f in gtk.css gtk-dark.css assets; do
      # Never replace a real file of the user's, only our own links.
      [[ -e $whitesur/gtk-4.0/$f ]] && [[ ! -e $gtk4/$f || -L $gtk4/$f ]] && ln -sfn "$whitesur/gtk-4.0/$f" "$gtk4/$f"
    done
  fi
  if [[ -d /usr/share/icons/$cursor ]]; then
    gsettings set $iface cursor-theme $cursor # Omarchy re-reads this at login
    hyprctl setcursor $cursor 24 >/dev/null
  fi
  fc-list -q Inter && gsettings set $iface font-name "$font"
else
  for f in gtk.css gtk-dark.css assets; do
    [[ -L $gtk4/$f && $(readlink "$gtk4/$f") == "$whitesur"/* ]] && rm "$gtk4/$f"
  done
  if [[ $(gsettings get $iface cursor-theme) == "'$cursor'" ]]; then
    gsettings set $iface cursor-theme default
    hyprctl setcursor default 24 >/dev/null
  fi
  [[ $(gsettings get $iface font-name) == "'$font'" ]] && gsettings reset $iface font-name
fi
exit 0
