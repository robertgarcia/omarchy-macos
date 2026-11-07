-- macOS dark window look. Shipping this file replaces Omarchy's generated
-- hyprland.lua for the theme, so the border colors live here too.
-- Loaded after Omarchy's defaults, before ~/.config/hypr overrides and toggles.

-- macOS windows have no colored frame, only a faint hairline.
local active_border_color = "rgba(ffffff38)"
local inactive_border_color = "rgba(ffffff14)"

hl.config({
  general = {
    gaps_in = 6,
    gaps_out = 12,
    border_size = 1,
    col = {
      active_border = active_border_color,
      inactive_border = inactive_border_color,
    },
  },

  group = {
    col = {
      border_active = active_border_color,
      border_inactive = inactive_border_color,
    },
  },

  decoration = {
    -- Apple's "continuous" corners: closer to a squircle than to a circle arc.
    rounding = 12,
    rounding_power = 3,

    -- Big, soft shadow that drops a little; lighter on unfocused windows.
    shadow = {
      enabled = true,
      range = 32,
      render_power = 3,
      offset = { 0, 8 },
      color = "rgba(00000099)",
      color_inactive = "rgba(00000055)",
    },

    -- Vibrancy for whatever is translucent (bar, menus, terminals).
    blur = {
      enabled = true,
      size = 10,
      passes = 3,
      new_optimizations = true,
      xray = false,
      noise = 0.02,
      contrast = 1.0,
      brightness = 0.85,
      vibrancy = 0.25,
      vibrancy_darkness = 0.2,
      popups = true,
    },
  },
})

-- Animations: short and decelerating, like AppKit. Windows grow in from 92%,
-- workspaces slide sideways like Spaces.
hl.curve("macos", { type = "bezier", points = { { 0.32, 0.72 }, { 0, 1 } } })
hl.curve("macosOut", { type = "bezier", points = { { 0.4, 0 }, { 1, 1 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 3.5, bezier = "macos" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3.2, bezier = "macos", style = "popin 92%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2.2, bezier = "macosOut", style = "popin 92%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 3.5, bezier = "macos" })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "macos" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4.5, bezier = "macos", style = "slide" })

-- Capa 5: macOS-style dock (nwg-dock-hyprland). Frosted like the bar, and
-- started at login only while this theme is active; the theme-set hook starts
-- or stops it when switching themes later.
hl.layer_rule({
  match = { namespace = "^nwg-dock$" },
  blur = true,
  ignore_alpha = 0.3,
})

hl.on("hyprland.start", function()
  hl.exec_cmd(os.getenv("HOME") .. "/.config/nwg-dock-hyprland/launch.sh")
end)
