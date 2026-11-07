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

-- Capa 6: traffic lights on every window. The plugin is Omarchy's own hyprbars
-- build (package omarchy-hyprland-titlebars), rebuilt with every Hyprland update.
-- Loading it here means switching away from this theme unloads it. The plugin
-- reloads the config once it is in; that second pass is the one that finds
-- hl.plugin.hyprbars and configures it.
local TITLEBARS = "/usr/lib/omarchy-hyprland-titlebars/titlebars.so"
local titlebars_file = io.open(TITLEBARS, "r")
if titlebars_file then
  titlebars_file:close()
  hl.plugin.load(TITLEBARS)
end

if hl.plugin.hyprbars then
  local window = [[window = "address:%WINDOW%"]]
  local zoom = "hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = \"maximized\", action = \"toggle\", " .. window .. " })'"

  hl.config({
    plugin = {
      hyprbars = {
        enabled = true,
        bar_height = 28,
        bar_color = "rgb(2c2c2e)",
        bar_color_inactive = "rgb(232325)",
        col = { text = "rgb(e5e5e7)" },
        bar_text_font = "Inter",
        bar_text_size = 11,
        bar_text_weight = 600,
        bar_text_align = "center",
        bar_buttons_alignment = "left",
        bar_part_of_window = true,
        bar_precedence_over_border = true,
        bar_padding = 12,
        bar_button_padding = 8,
        icon_on_hover = true, -- symbols appear only under the pointer, like macOS
        inactive_button_color = "rgb(48484a)", -- grey dots on unfocused windows
        on_double_click = zoom,
      },
    },
  })

  -- Left to right: close, minimize, zoom.
  for _, button in ipairs({
    { color = "rgb(ff5f57)", icon = "×", action = "hyprctl dispatch 'hl.dsp.window.close({ " .. window .. " })'" },
    -- Omarchy's own minimize only acts on floating workspaces; the dock brings the window back.
    { color = "rgb(febc2e)", icon = "−", action = "hyprctl dispatch 'hl.dsp.window.move({ workspace = \"special:minimized\", follow = false, " .. window .. " })'" },
    { color = "rgb(28c840)", icon = "+", action = zoom },
  }) do
    hl.plugin.hyprbars.add_button({
      bg_color = button.color,
      fg_color = "rgba(0000008c)",
      size = 12,
      icon = button.icon,
      action = button.action,
    })
  end

  -- Clicking a minimized window in the dock focuses it, which on its own would only
  -- show the hidden workspace as an overlay. Bring it back to the current one instead.
  hl.on("window.active", function(w)
    if not (w and w.workspace and w.workspace.name == "special:minimized") then
      return
    end
    local ws = hl.get_active_workspace()
    if ws and ws.id and ws.id > 0 then
      hl.dispatch(hl.dsp.window.move({ workspace = tostring(ws.id), window = "address:" .. w.address }))
    end
  end)
end
