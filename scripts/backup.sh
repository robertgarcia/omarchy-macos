#!/bin/bash
# Saves everything omarchy-macos may touch, so rollback.sh can undo it.
# Run it once, before applying any layer.
set -euo pipefail
umask 077 # the backup holds personal config (shell.json is 0600)

source "$(dirname "$(realpath "$0")")/managed-paths.sh"

dest="$BACKUP_ROOT/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$dest"

existing=()
for p in "${MANAGED_PATHS[@]}"; do
  [[ -e $HOME/$p || -L $HOME/$p ]] && existing+=("$p")
done

tar -C "$HOME" -czf "$dest/home.tar.gz" "${existing[@]}"
pacman -Qq >"$dest/packages-before.txt"
dconf dump /org/gnome/desktop/interface/ >"$dest/dconf-interface.ini"
omarchy theme current >"$dest/theme.txt"
omarchy font current >"$dest/font.txt"

# Don't call it a backup until every saved path is really in the archive.
listing="$(tar -tzf "$dest/home.tar.gz")"
for p in "${existing[@]}"; do
  grep -Fxq -e "$p" -e "$p/" <<<"$listing" || { echo "Copia incompleta: falta $p" >&2; exit 1; }
done

echo "Copia creada en $dest"
echo "  rutas guardadas: ${existing[*]}"
echo "  tema: $(<"$dest/theme.txt")  fuente: $(<"$dest/font.txt")"
