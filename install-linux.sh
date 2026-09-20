#!/usr/bin/env bash

set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
mpv_dir="${XDG_CONFIG_HOME:-${HOME}/.config}/mpv"
data_dir="${XDG_DATA_HOME:-${HOME}/.local/share}"
bin_dir="${HOME}/.local/bin"
version="0.0.15-zh-cn"
with_caelestia=false
install_mpris=false

usage() {
    printf '%s\n' \
        'Usage: ./install-linux.sh [--with-caelestia] [--install-mpris]' \
        '' \
        '  --with-caelestia  merge the 2% audio/brightness service settings' \
        '  --install-mpris   install the distro mpv-mpris package (Arch only)'
}

for argument in "$@"; do
    case "$argument" in
        --with-caelestia) with_caelestia=true ;;
        --install-mpris) install_mpris=true ;;
        -h|--help) usage; exit 0 ;;
        *) printf 'Unknown option: %s\n' "$argument" >&2; usage >&2; exit 2 ;;
    esac
done

timestamp=$(date +%Y%m%d-%H%M%S)

backup_once() {
    local target=$1
    if [[ -e "$target" && ! -e "${target}.material-osc-zh.${timestamp}.bak" ]]; then
        cp -a -- "$target" "${target}.material-osc-zh.${timestamp}.bak"
    fi
}

install_owned_file() {
    local source=$1 target=$2 mode=${3:-0644}
    mkdir -p -- "$(dirname -- "$target")"
    if [[ -e "$target" ]] && cmp -s -- "$source" "$target"; then
        return
    fi
    backup_once "$target"
    install -m "$mode" -- "$source" "$target"
}

ensure_bundle() {
    local artifact="$repo_dir/build/$version/scripts/material-osc.lua"
    if [[ -f "$artifact" ]]; then
        return
    fi

    local python=python3
    if ! "$python" -c 'import fontTools' >/dev/null 2>&1; then
        if [[ ! -x "$repo_dir/.venv/bin/python" ]]; then
            "$python" -m venv "$repo_dir/.venv"
        fi
        "$repo_dir/.venv/bin/pip" install -r "$repo_dir/requirements-build.txt"
        python="$repo_dir/.venv/bin/python"
    fi
    "$python" "$repo_dir/bundle.py" "$version"
}

append_once() {
    local file=$1 line=$2 pattern=$3
    mkdir -p -- "$(dirname -- "$file")"
    if [[ ! -f "$file" ]] || ! grep -Fq -- "$pattern" "$file"; then
        backup_once "$file"
        touch "$file"
        printf '\n%s\n' "$line" >> "$file"
    fi
}

prepend_once() {
    local file=$1 line=$2 pattern=$3
    mkdir -p -- "$(dirname -- "$file")"
    if [[ -f "$file" ]] && grep -Fq -- "$pattern" "$file"; then
        return
    fi

    local updated
    updated=$(mktemp)
    if [[ -f "$file" ]]; then
        backup_once "$file"
        awk -v first="$line" 'BEGIN { print first; print "" } { print }' \
            "$file" > "$updated"
    else
        printf '%s\n' "$line" > "$updated"
    fi
    install -m 0644 -- "$updated" "$file"
}

merge_material_options() {
    local target="$mpv_dir/script-opts/material-osc.conf"
    local existed=false backed_up=false
    [[ -e "$target" ]] && existed=true
    mkdir -p -- "$(dirname -- "$target")"
    while IFS= read -r line; do
        [[ -z "$line" || "$line" == \#* ]] && continue
        local key=${line%%=*}
        if [[ ! -f "$target" ]] || \
            ! grep -Eq "^[[:space:]]*${key}[[:space:]]*=" "$target"; then
            if "$existed" && ! "$backed_up"; then
                backup_once "$target"
                backed_up=true
            fi
            touch "$target"
            printf '%s\n' "$line" >> "$target"
        fi
    done < "$repo_dir/extras/mpv/script-opts/material-osc.conf"
}

merge_caelestia_services() {
    local target="${XDG_CONFIG_HOME:-${HOME}/.config}/caelestia/shell.json"
    local fragment="$repo_dir/extras/caelestia/shell.services.json"
    local merged
    merged=$(mktemp)
    mkdir -p -- "$(dirname -- "$target")"
    python3 - "$target" "$fragment" "$merged" <<'PY'
import json
import pathlib
import sys

target = pathlib.Path(sys.argv[1])
fragment = pathlib.Path(sys.argv[2])
merged = pathlib.Path(sys.argv[3])
current = json.loads(target.read_text()) if target.exists() else {}
patch = json.loads(fragment.read_text())
for section, values in patch.items():
    current.setdefault(section, {}).update(values)
merged.write_text(json.dumps(current, ensure_ascii=False, indent=4) + "\n")
PY
    if [[ ! -f "$target" ]] || ! cmp -s -- "$merged" "$target"; then
        backup_once "$target"
        install -m 0644 -- "$merged" "$target"
    fi
}

ensure_bundle

install_owned_file "$repo_dir/build/$version/scripts/material-osc.lua" \
    "$mpv_dir/scripts/material-osc.lua"
install_owned_file "$repo_dir/build/$version/fonts/material-osc_icons.otf" \
    "$mpv_dir/fonts/material-osc_icons.otf"
install_owned_file "$repo_dir/build/$version/fonts/material-osc_google_sans_flex.ttf" \
    "$mpv_dir/fonts/material-osc_google_sans_flex.ttf"
install_owned_file "$repo_dir/extras/mpv/scripts/autocrop.lua" \
    "$mpv_dir/scripts/autocrop.lua"
install_owned_file "$repo_dir/extras/mpv/scripts/thumbfast.lua" \
    "$mpv_dir/scripts/thumbfast.lua"
install_owned_file "$repo_dir/extras/mpv/material-osc-zh.conf" \
    "$mpv_dir/material-osc-zh.conf"

prepend_once "$mpv_dir/mpv.conf" 'include=material-osc-zh.conf' \
    'include=material-osc-zh.conf'
if [[ -e "$mpv_dir/input.conf" ]]; then
    append_once "$mpv_dir/input.conf" \
        'UP no-osd script-binding material_osc/player-volume-up' \
        'material_osc/player-volume-up'
    append_once "$mpv_dir/input.conf" \
        'DOWN no-osd script-binding material_osc/player-volume-down' \
        'material_osc/player-volume-down'
else
    install_owned_file "$repo_dir/extras/mpv/input.conf" "$mpv_dir/input.conf"
fi
merge_material_options

install_owned_file "$repo_dir/extras/bin/mpv-single-instance" \
    "$bin_dir/mpv-single-instance" 0755

desktop_tmp=$(mktemp)
sed "s|@MPV_SINGLE_INSTANCE@|${bin_dir}/mpv-single-instance|g" \
    "$repo_dir/extras/applications/mpv-material-osc.desktop.in" > "$desktop_tmp"
install_owned_file "$desktop_tmp" "$data_dir/applications/mpv.desktop"

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$data_dir/applications" >/dev/null 2>&1 || true
fi

if "$with_caelestia"; then
    merge_caelestia_services
    printf '%s\n' \
        'Merged Caelestia audio/brightness increments.' \
        "Merge extras/hyprland/caelestia-mpv.lua into your Caelestia Hyprland files."
fi

if "$install_mpris"; then
    if command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --needed mpv-mpris
    else
        printf '%s\n' 'Install mpv-mpris with your distribution package manager.' >&2
        exit 1
    fi
elif [[ ! -e /etc/mpv/scripts/mpris.so && ! -e "$mpv_dir/scripts/mpris.so" ]]; then
    printf '%s\n' \
        'MPRIS is not installed. On Arch/CachyOS: ./install-linux.sh --install-mpris'
fi

printf '%s\n' \
    "Installed material-osc-zh into $mpv_dir" \
    'Log out/in or refresh the desktop database before testing file-manager launches.'
