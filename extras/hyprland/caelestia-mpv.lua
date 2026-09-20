-- Merge these entries into the corresponding sections of Caelestia's
-- ~/.config/hypr/hyprland/keybinds.lua and rules.lua.

-- Brightness uses Caelestia's own service and the 2% increment configured in
-- extras/caelestia/shell.services.json.
create_bind("XF86MonBrightnessUp", hl.dsp.global("caelestia:brightnessUp"), locked)
create_bind("XF86MonBrightnessDown", hl.dsp.global("caelestia:brightnessDown"), locked)

-- Generic PipeWire system volume; no device-specific remapping is applied.
create_bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%+"), locked_repeating)
create_bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"), locked_repeating)
create_bind({ vars.kbVolumeMute, "XF86AudioMute" }, hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), locked)

-- Put this after the general non-fullscreen opacity rule: later Hyprland rules
-- win, keeping SDR video from showing the wallpaper through the mpv window.
hl.window_rule({ match = { class = "mpv" }, opacity = "1.0 override" })
