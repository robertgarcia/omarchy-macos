# Security policy

## Supported versions

Only the latest release gets fixes.

## Reporting a vulnerability

Do not open a public issue. Report the problem privately on GitHub instead: on the repository's **Security** tab, choose **Report a vulnerability**.

Include what an attacker could do, the steps to reproduce it, and the affected files. You will get an answer within a week.

## Scope

Parts of this project run with privileges or automatically:

- `scripts/rollback.sh` removes packages with `sudo pacman`.
- `hooks/theme-set-macos.sh` runs on every Omarchy theme change.
- `themes/macos/hyprland.lua` runs inside Hyprland, and its traffic-light buttons run commands for a window.

Problems in Omarchy, Hyprland, WhiteSur or nwg-dock-hyprland belong to those projects.
