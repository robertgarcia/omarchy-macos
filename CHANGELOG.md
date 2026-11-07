# Changelog

All notable changes to this project are listed here. Versions follow [Semantic Versioning](https://semver.org/).

## [0.1.0] - 2026-11-06

First public release. Tested on Omarchy 4.5.0 with Hyprland 0.56.2.

### Added

- **Layer 0:** `scripts/backup.sh` and `scripts/rollback.sh`, with a round-trip test against a fake `$HOME`.
- **Layer 1:** the Omarchy theme `macos`, with macOS dark mode colors and two original wallpapers.
- **Layer 2:** squircle-like corners, soft shadows, blur, and AppKit-like window and workspace animations.
- **Layer 3:** a top bar laid out like macOS (`scripts/bar-layout.py`), translucent with blur.
- **Layer 4:** Inter as the UI font, WhiteSur icons and GTK theme (libadwaita included) and the macOS cursor, all bound to the theme through a theme-set hook.
- **Layer 5:** an always-visible dock (`nwg-dock-hyprland`) that prefers the external monitor.
- **Layer 6:** traffic-light buttons on every window, using Omarchy's own `hyprbars` build. Minimized windows come back from the dock.

[0.1.0]: https://github.com/robertgarcia/omarchy-macos/releases/tag/v0.1.0
