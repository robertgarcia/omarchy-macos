#!/bin/bash
# backup -> change things -> rollback must leave $HOME exactly as before.
# Runs against a fake $HOME with stubbed system commands; touches nothing real.
set -euo pipefail

repo="$(dirname "$(dirname "$(realpath "$0")")")"
t="$(mktemp -d)"
trap 'rm -rf "$t"' EXIT
export HOME="$t/home" OMARCHY_MACOS_BACKUPS="$t/backups"
unset HYPRLAND_INSTANCE_SIGNATURE

mkdir -p "$t/bin" "$HOME/.config/hypr" "$HOME/.config/omarchy"
echo original >"$HOME/.config/hypr/looknfeel.lua"
echo '{}' >"$HOME/.config/omarchy/shell.json"
for cmd in omarchy dconf sudo pkill; do
  printf '#!/bin/bash\necho "%s $*" >>"%s/calls"\n[[ "$*" == "theme current" ]] && echo Ethereal\n[[ "$*" == "font current" ]] && echo "JetBrainsMono Nerd Font"\nexit 0\n' "$cmd" "$t" >"$t/bin/$cmd"
done
printf '#!/bin/bash\n[[ -z ${2:-} ]] && { echo base; exit 0; }\n[[ $2 == fake-dock ]]\n' >"$t/bin/pacman"
chmod +x "$t/bin"/*
export PATH="$t/bin:$PATH"

before="$(cd "$HOME" && find . -printf '%p %s\n' | sort; cat .config/hypr/looknfeel.lua)"

"$repo/scripts/backup.sh" >/dev/null

# Simulate applying layers: edit, add a file, add a whole new dir, install a package.
echo macos >"$HOME/.config/hypr/looknfeel.lua"
echo 'x' >"$HOME/.config/hypr/macos.lua"
mkdir -p "$HOME/.config/nwg-dock-hyprland" && echo y >"$HOME/.config/nwg-dock-hyprland/style.css"
cp "$repo/packages.txt" "$t/packages.bak"
echo fake-dock >>"$repo/packages.txt"
trap 'cp "$t/packages.bak" "$repo/packages.txt"; rm -rf "$t"' EXIT

echo s | "$repo/scripts/rollback.sh" >/dev/null

after="$(cd "$HOME" && find . -printf '%p %s\n' | sort; cat .config/hypr/looknfeel.lua)"
[[ $before == "$after" ]] || { diff <(echo "$before") <(echo "$after"); echo "FALLO: \$HOME no quedó igual"; exit 1; }
grep -q "sudo pacman -Rns fake-dock" "$t/calls" || { echo "FALLO: no quitó el paquete añadido"; exit 1; }
grep -q "dconf reset -f /org/gnome/desktop/wm/preferences/" "$t/calls" || { echo "FALLO: no restauró los botones GTK"; exit 1; }
grep -q "omarchy theme set Ethereal" "$t/calls" || { echo "FALLO: no reaplicó el tema"; exit 1; }
ls "$t"/backups/*/replaced-*/.config/nwg-dock-hyprland/style.css >/dev/null || { echo "FALLO: no guardó lo reemplazado"; exit 1; }
echo "OK: backup + rollback dejan \$HOME igual"
