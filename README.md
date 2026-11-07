# omarchy-macos

Aspecto macOS (modo oscuro) para [Omarchy](https://omarchy.org/) 4.x sobre Hyprland, aplicado por capas y siempre reversible.

## Capas

| # | Capa | Estado |
|---|------|--------|
| 0 | Copia de seguridad y rollback | ✅ |
| 1 | Tema Omarchy `macos` (colores y fondos) | ✅ |
| 2 | Ventanas: esquinas, sombras, desenfoque, animaciones | ✅ |
| 3 | Barra superior estilo macOS | pendiente |
| 4 | Fuentes, iconos, cursor y GTK | pendiente |
| 5 | Dock (`nwg-dock-hyprland`) | pendiente |
| 6 | Botones de semáforo en las ventanas (`hyprbars`) | pendiente |

## Antes de empezar

```bash
omarchy snapshot create     # instantánea del sistema (paquetes, /usr, /etc)
scripts/backup.sh           # copia de lo que se toca en $HOME
```

Snapper no cubre `/home` en Omarchy, así que `backup.sh` hace falta aunque tengas instantáneas.
Guarda las rutas de `scripts/managed-paths.sh`, la lista de paquetes instalados, los ajustes GTK (dconf) y el tema y la fuente actuales en `~/.local/share/omarchy-macos/backups/<fecha>/`.

## Capa 1: tema

```bash
ln -s "$PWD/themes/macos" ~/.config/omarchy/themes/macos
omarchy theme set macos
```

Colores del modo oscuro de macOS (`systemBlue` como acento) y dos fondos abstractos originales (`1-noche`, `2-grafito`). Cambia de fondo con `omarchy theme bg next`.

## Capa 2: ventanas

Va dentro del tema, en `themes/macos/hyprland.lua`, así que se activa y se desactiva al cambiar de tema. No toca `~/.config/hypr`.
Esquinas de 12 px casi en forma de squircle, borde fino, sombra amplia que cae un poco, desenfoque para lo translúcido, ventanas que aparecen creciendo desde el 92 % y escritorios que se deslizan de lado, como los Spaces de macOS.

Lo que pongas en `~/.config/hypr/looknfeel.lua` o actives con un toggle de Omarchy se carga después y manda sobre esto.

## Deshacer

```bash
scripts/rollback.sh [carpeta-de-copia]   # por defecto, la copia más reciente
```

Funciona desde una consola de texto (Ctrl+Alt+F3) si Hyprland no arranca. Esto es lo que hace:

1. Devuelve las rutas gestionadas a su estado anterior. Antes guarda lo que hay en ese momento en `<copia>/replaced-<fecha>/`, así que no se pierde nada.
2. Desinstala los paquetes de `packages.txt` que no estaban instalados antes.
3. Desactiva `hyprbars`.
4. Restaura los ajustes GTK y vuelve a aplicar el tema y la fuente que había.

Ojo: también devuelve a su estado anterior **cualquier** cambio que hayas hecho en esas rutas después de la copia, aunque no tenga nada que ver con este proyecto (por ejemplo, un atajo nuevo en `~/.config/hypr`). Lo encontrarás en `replaced-<fecha>/`.

Si algo va peor que eso, arranca una instantánea anterior desde el menú de Limine.

## Pruebas

```bash
tests/roundtrip.sh   # backup -> cambios -> rollback sobre un $HOME falso
```
