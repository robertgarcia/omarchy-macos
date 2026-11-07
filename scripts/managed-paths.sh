# shellcheck shell=bash disable=SC2034 # sourced by backup.sh and rollback.sh, which use these
# Paths (relative to $HOME) that omarchy-macos may change.
# backup.sh saves them and rollback.sh puts them back exactly as they were.
MANAGED_PATHS=(
  .config/hypr
  .config/omarchy
  .config/gtk-3.0
  .config/gtk-4.0
  .config/fontconfig
  .config/nwg-dock-hyprland
  .cache/nwg-dock-pinned
  .local/state/omarchy/current
  .local/share/icons
  .local/share/themes
  .local/share/fonts
  .icons
  .themes
)

BACKUP_ROOT="${OMARCHY_MACOS_BACKUPS:-$HOME/.local/share/omarchy-macos/backups}"
