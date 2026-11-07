# Contributing

Thanks for helping. Issues and pull requests are welcome in English or Spanish.

## What fits

This project gives Omarchy 4.x a dark macOS look and keeps every change reversible. Good contributions include:

- fixes for the existing layers;
- support for newer Omarchy or Hyprland releases;
- visual details that bring the look closer to macOS;
- documentation and translations.

A light mode or another desktop look would be a separate project; open an issue first if you are unsure.

## Ground rules

These keep the rollback honest. A PR that breaks one of them will be asked to change.

1. **Everything must be undoable.**
   - A new package goes in `packages.txt`, so `rollback.sh` can remove it.
   - A new path under `$HOME` goes in `scripts/managed-paths.sh`, so `backup.sh` saves it.
   - Add only paths that are safe to delete when they did not exist at backup time, because the rollback removes them.
2. **Follow the theme when you can.**
   - Hyprland settings belong in `themes/macos/hyprland.lua`.
   - Desktop settings outside Hyprland (GTK, cursor, fonts, the dock process) belong in `hooks/theme-set-macos.sh`.
   - The hook must undo, when the user leaves the theme, only what it set.
3. **Never edit `/usr/share/omarchy`.** Omarchy updates overwrite it.
4. **No personal data** in code, commits or screenshots: no usernames, hostnames, paths under your home, window titles, folders or accounts.

## Development setup

```bash
git clone https://github.com/<you>/omarchy-macos.git
cd omarchy-macos
scripts/backup.sh          # before you try anything on your own session
```

Omarchy applies a theme by copying it, so run `omarchy theme set macos` after you change anything under `themes/macos`.

## Checks

CI runs these on every pull request. Run them locally first:

```bash
shellcheck -S warning scripts/*.sh hooks/*.sh dock/launch.sh tests/*.sh
luac -p themes/macos/hyprland.lua
python3 -m py_compile scripts/bar-layout.py
tests/roundtrip.sh
```

CI cannot run Hyprland. For any change that touches the desktop, also check it on a real Omarchy session:

- `hyprctl configerrors` prints nothing after `omarchy theme set macos`.
- Switching to another theme and back leaves no leftovers: cursor, GTK theme, dock, window buttons.
- `scripts/rollback.sh` still undoes your change. Run it against a fresh backup, or extend `tests/roundtrip.sh`.

## Pull requests

- Branch from `main` and keep one topic per PR.
- Say which layer you changed, and the Omarchy (`omarchy version`) and Hyprland (`hyprctl version`) versions you tested on.
- Add a screenshot for visual changes, taken on a workspace with nothing personal on it.
- Write short commit messages in the imperative, prefixed with the layer when it applies, for example `Layer 5: center the dock icons`.
- `main` is protected: changes land through pull requests once CI passes.

## Reporting bugs

Use the bug report form. Include the output of `hyprctl configerrors` and what you changed before the problem started.

Report bugs in Omarchy itself to [Omarchy](https://github.com/omacom/omarchy), not here.

Report security problems privately, as described in [SECURITY.md](SECURITY.md).
