#!/bin/bash
# Undoes omarchy-macos: restores the files from a backup, removes the packages it
# added, disables hyprbars and re-applies the previous GTK settings, theme and font.
# Works from a text console (Ctrl+Alt+F3) if Hyprland does not start.
#
# Usage: rollback.sh [backup-dir]   (default: the most recent backup)
set -euo pipefail

repo="$(dirname "$(dirname "$(realpath "$0")")")"
source "$repo/scripts/managed-paths.sh"

src="${1:-$(ls -d "$BACKUP_ROOT"/*/ 2>/dev/null | sort | tail -1)}"
src="${src%/}"
[[ -n $src && -f $src/home.tar.gz ]] || { echo "No hay ninguna copia en '${src:-$BACKUP_ROOT}'" >&2; exit 1; }

echo "Restaurar desde: $src"
echo "  tema: $(<"$src/theme.txt")  fuente: $(<"$src/font.txt")"
read -rp "¿Continuar? [s/N] " ok
[[ $ok == [sS] ]] || exit 1

# 1. Files. Current state is copied aside first, so nothing is lost.
#    rsync updates in place, so Hyprland never sees its config directory missing.
aside="$src/replaced-$(date +%Y%m%d-%H%M%S)"
staged="$(mktemp -d)"
trap 'rm -rf "$staged"' EXIT
trap 'echo "Error. Tu estado anterior al rollback está en $aside" >&2' ERR

tar -C "$staged" -xzf "$src/home.tar.gz"
for p in "${MANAGED_PATHS[@]}"; do
  if [[ -e $HOME/$p || -L $HOME/$p ]]; then
    mkdir -p "$aside/$(dirname "$p")"
    cp -a "$HOME/$p" "$aside/$p"
  fi
  if [[ -e $staged/$p ]]; then
    mkdir -p "$HOME/$p"
    rsync -a --delete "$staged/$p/" "$HOME/$p/"
  else
    rm -rf "${HOME:?}/$p" # did not exist before; its copy is in $aside
  fi
done
echo "Archivos restaurados (lo que había quedó en $aside)"

# The glassy bar leaves a toggle in ~/.local/state/omarchy/toggles (not a managed
# path: it holds unrelated toggles); re-derive it from the restored shell.json.
omarchy bar sync-glass || echo "Aviso: repite 'omarchy bar sync-glass' tras iniciar sesión" >&2

# 2. Packages this project installed that were not there before.
#    The dock is running from one of them, and the restored hooks no longer stop it.
pkill -f '^nwg-dock-hyprland' || true
to_remove=()
while read -r pkg; do
  [[ -z $pkg || $pkg == \#* ]] && continue
  pacman -Qq "$pkg" &>/dev/null && ! grep -Fxq "$pkg" "$src/packages-before.txt" && to_remove+=("$pkg")
done <"$repo/packages.txt"
if ((${#to_remove[@]})); then
  sudo pacman -Rns "${to_remove[@]}" || echo "Aviso: no se pudieron quitar ${to_remove[*]}" >&2
fi

# 3. hyprbars. Its load line lived in ~/.config/hypr, already restored above.
if command -v hyprpm >/dev/null; then
  hyprpm disable hyprbars &>/dev/null || true
fi

# 4. GTK settings (theme, icons, cursor, fonts).
dconf reset -f /org/gnome/desktop/interface/
dconf load /org/gnome/desktop/interface/ <"$src/dconf-interface.ini"

# 5. Omarchy font and theme (these rewrite terminal configs, bar, etc.).
omarchy font set "$(<"$src/font.txt")" || echo "Aviso: repite 'omarchy font set \"$(<"$src/font.txt")\"' tras iniciar sesión" >&2
omarchy theme set "$(<"$src/theme.txt")" || echo "Aviso: repite 'omarchy theme set \"$(<"$src/theme.txt")\"' tras iniciar sesión" >&2

if [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]]; then
  hyprctl reload >/dev/null
fi
echo "Rollback completo."
