# Installation

## Complete Linux setup

The repository includes a complete setup for the Chinese fork: material-osc,
the official autocrop script, thumbfast, mpv/Vulkan/NVDEC/HDR defaults, a
single-instance desktop launcher, and optional Caelestia/MPRIS integration.

```bash
./install-linux.sh --with-caelestia --install-mpris
```

See [`extras/README.zh-CN.md`](extras/README.zh-CN.md) for the exact behavior
and manual Hyprland merge step. The installer backs up files before replacing
them and does not include device-specific volume mappings.

## Manual cross-platform setup

1. Download `material-osc.zip` and
   [`thumbfast.lua`](https://github.com/po5/thumbfast/raw/refs/heads/master/thumbfast.lua).
2. Unzip `material-osc.zip` into your mpv configuration directory, then place
   `thumbfast.lua` beside `material-osc.lua` in the `scripts` directory.

The usual mpv configuration directories are:

- Linux and macOS: `~/.config/mpv/`
- Windows: `%APPDATA%\mpv\`

The resulting layout should look like this:

```text
📁 mpv
├── 📁 fonts
│   ├── material-osc_icons.otf
│   └── material-osc_google_sans_flex.ttf
├── 📁 scripts
│   ├── material-osc.lua
│   └── thumbfast.lua
└── 📁 script-opts (optional)
    ├── material-osc.conf
    └── thumbfast.conf
```
