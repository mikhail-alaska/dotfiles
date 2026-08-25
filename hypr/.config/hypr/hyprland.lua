-- Hyprland 0.56+ configuration.
-- The previous hyprland.conf is intentionally kept as a rollback copy.

local terminal = "kitty"
local file_manager = "thunar"
local menu = "wofi --show drun"
local main_mod = "SUPER"

-- Keep native 1920x1080 rendering. Fractional scaling is deliberately avoided.
hl.monitor({
    output = "eDP-1",
    mode = "1920x1080@59.999",
    position = "0x0",
    scale = 1,
})

hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1,
})

hl.env("HYPRCURSOR_THEME", "catppuccin_mocha_lavender_cursors")
hl.env("XCURSOR_THEME", "catppuccin_mocha_lavender_cursors")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")

hl.on("hyprland.start", function()
    hl.exec_cmd("hyprlock")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("waybar")
    hl.exec_cmd(terminal)
    hl.exec_cmd("firefox")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE")
    hl.exec_cmd("gitwatch -r https://github.com/mikhail-alaska/dotfiles/ /home/alaska/dotfiles/")
    hl.exec_cmd("gitwatch -r https://github.com/mikhail-alaska/hse/ -R /home/alaska/Documents/hse")
end)

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 5,
        border_size = 2,
        col = {
            active_border = {
                colors = { "rgba(ca9ee6ff)", "rgba(e78284ee)" },
                angle = 45,
            },
            inactive_border = "rgba(595959aa)",
        },
        resize_on_border = false,
        allow_tearing = false,
        layout = "dwindle",
    },

    decoration = {
        rounding = 10,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = "rgba(1a1a1aee)",
        },
        blur = {
            enabled = true,
            size = 3,
            passes = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
    },

    input = {
        kb_layout = "us,ru",
        kb_variant = "",
        kb_model = "",
        kb_options = "grp:caps_toggle",
        kb_rules = "",
        follow_mouse = 1,
        sensitivity = 0.2,
        touchpad = {
            -- macOS-style scrolling: content follows the fingers.
            natural_scroll = true,
            tap_to_click = true,
            tap_and_drag = false,
            drag_lock = 0,
            clickfinger_behavior = true,
            disable_while_typing = true,
        },
    },

    gestures = {
        -- Deliberate travel with an easy commit and reliable quick flicks.
        workspace_swipe_distance = 360,
        workspace_swipe_cancel_ratio = 0.32,
        workspace_swipe_min_speed_to_force = 20,

        -- Let Hyprland distinguish horizontal motion from up/down first.
        workspace_swipe_direction_lock = true,
        workspace_swipe_direction_lock_threshold = 24,

        -- One existing workspace per gesture, without accidental creation at an edge.
        workspace_swipe_create_new = false,
        workspace_swipe_forever = false,
        workspace_swipe_use_r = false,
    },
})

hl.curve("macEaseOut", {
    type = "bezier",
    points = { { 0.22, 1 }, { 0.36, 1 } },
})

hl.curve("macEaseInOut", {
    type = "bezier",
    points = { { 0.65, 0 }, { 0.35, 1 } },
})

hl.curve("macSpring", {
    type = "spring",
    mass = 1,
    stiffness = 170,
    dampening = 26,
})

hl.animation({ leaf = "windows", enabled = true, speed = 4, spring = "macSpring", style = "popin 94%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "macEaseInOut", style = "popin 94%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4, spring = "macSpring" })
hl.animation({ leaf = "border", enabled = true, speed = 5, bezier = "macEaseInOut" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 6, bezier = "macEaseInOut" })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "macEaseOut" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, spring = "macSpring", style = "slide" })

-- Native, 1:1 three-finger horizontal workspace switching.
hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})

hl.device({
    name = "logitech-g102-lightsync-gaming-mouse",
    sensitivity = 0.1,
})

hl.bind(main_mod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(main_mod .. " + Q", hl.dsp.window.close())
hl.bind(main_mod .. " + E", hl.dsp.exec_cmd(file_manager))
hl.bind(main_mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(main_mod .. " + X", hl.dsp.exec_cmd("hyprlock"))
hl.bind(main_mod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(main_mod .. " + P", hl.dsp.window.pseudo())
hl.bind(main_mod .. " + M", hl.dsp.exit())

hl.bind(main_mod .. " + Print", hl.dsp.exec_cmd("hyprshot -m window"))
hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m output"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m region"))

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

local directions = {
    h = "l",
    l = "r",
    k = "u",
    j = "d",
}

for key, direction in pairs(directions) do
    hl.bind(main_mod .. " + " .. key, hl.dsp.focus({ direction = direction }))
    hl.bind(main_mod .. " + SHIFT + " .. key, hl.dsp.window.swap({ direction = direction }))
end

for workspace = 1, 10 do
    local key = workspace % 10
    hl.bind(main_mod .. " + " .. key, hl.dsp.focus({ workspace = workspace }))
    hl.bind(main_mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }))
end

hl.bind(main_mod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(main_mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind(main_mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(main_mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(main_mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(main_mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- HyprExpo: macOS Mission Control-style overview.
-- Built locally so the plugin matches the exact Hyprland ABI without sudo.
local hyprexpo_path = "/home/alaska/.local/src/hyprexpo/hyprexpo.so"
hl.plugin.load(hyprexpo_path)

local hyprexpo_loaded = false
for _, plugin in ipairs(hl.get_loaded_plugins()) do
    if plugin.name == "hyprexpo" then
        hyprexpo_loaded = true
        break
    end
end

if hyprexpo_loaded then
    hl.config({
        plugin = {
            hyprexpo = {
                columns = 3,
                gaps_in = 14,
                gaps_out = 24,
                bg_col = "rgb(1e1e2e)",
                workspace_method = "center current",
                gesture_distance = 200,
                gesture_close_distance = 200,
                cancel_key = "escape",
                show_cursor = 1,
                show_pinned_windows = 0,
                drag_drop_enable = 0,
                dynamic_grid = 1,
                fill_gaps = 0,
                mru_sort = 0,
                wallpaper_bg = 1,

                -- Catppuccin Mocha workspace tiles.
                tile_rounding = 16,
                tile_rounding_power = 2.0,
                border_width = 3,
                border_color = "rgba(45475aaa)",
                border_color_current = "rgba(b4bebeff) rgba(cba6f7ff) 45deg",
                border_color_hover = "rgb(89b4fa)",
                border_color_focus = "rgb(fab387)",

                -- Catppuccin labels: Text on a translucent Mantle pill.
                label_enable = 1,
                label_text_mode = "id",
                label_position = "bottom-left",
                label_offset_x = 10,
                label_offset_y = 10,
                label_show = "always",
                label_color_default = "rgb(cdd6f4)",
                label_color_current = "rgb(b4befe)",
                label_color_hover = "rgb(89b4fa)",
                label_color_focus = "rgb(fab387)",
                label_scale_hover = 1.05,
                label_scale_focus = 1.05,
                label_font_size = 16,
                label_font_family = "Adwaita Sans",
                label_font_bold = 1,
                label_bg_enable = 1,
                label_bg_color = "rgba(181825dd)",
                label_bg_shape = "rounded",
                label_bg_rounding = 10,
                label_padding = 8,

                keynav_enable = 1,
                number_key_mode = "index",
                keynav_wrap_h = 1,
                keynav_wrap_v = 1,
            },
        },
    })

    -- Interactive Mission Control gestures: both directions follow the fingers.
    hl.plugin.hyprexpo.gesture({
        fingers = 3,
        direction = "up",
        action = "open",
    })

    hl.plugin.hyprexpo.gesture({
        fingers = 3,
        direction = "down",
        action = "close",
    })

    hl.bind(main_mod .. " + G", function()
        hl.plugin.hyprexpo.expo("toggle")
    end)

    hl.define_submap("hyprexpo", function()
        hl.bind("h", function() hl.plugin.hyprexpo.kb_focus("left") end)
        hl.bind("l", function() hl.plugin.hyprexpo.kb_focus("right") end)
        hl.bind("k", function() hl.plugin.hyprexpo.kb_focus("up") end)
        hl.bind("j", function() hl.plugin.hyprexpo.kb_focus("down") end)
        hl.bind("left", function() hl.plugin.hyprexpo.kb_focus("left") end)
        hl.bind("right", function() hl.plugin.hyprexpo.kb_focus("right") end)
        hl.bind("up", function() hl.plugin.hyprexpo.kb_focus("up") end)
        hl.bind("down", function() hl.plugin.hyprexpo.kb_focus("down") end)
        hl.bind("return", function() hl.plugin.hyprexpo.kb_confirm() end)
        hl.bind("escape", function() hl.plugin.hyprexpo.expo("cancel") end)
    end)
end
