# Linux / Caelestia 完整集成

根目录的 `install-linux.sh` 会安装中文版 material-osc、官方自动裁剪脚本、
thumbfast、单窗口启动器、mpv 配置和桌面入口。已有同名文件会先生成带时间戳的
备份；现有 `mpv.conf` 会在开头加入一条 include，`input.conf` 只会追加缺失的
按键绑定。include 放在开头可避免它意外落进文件末尾的命名 profile。

```bash
./install-linux.sh
```

Arch/CachyOS 上同时安装 MPRIS：

```bash
./install-linux.sh --install-mpris
```

同时把 Caelestia 的音量与亮度步进合并为 2%：

```bash
./install-linux.sh --with-caelestia
```

Caelestia 的 Hyprland 配置使用 Lua 生成规则，无法安全地从安装脚本自动合并。
把 `extras/hyprland/caelestia-mpv.lua` 中对应行合并到
`~/.config/hypr/hyprland/keybinds.lua` 和 `rules.lua`。mpv 不透明规则必须放在
通用透明规则之后。

## 包含内容

- `mpv-single-instance`：文件管理器再次打开或拖入文件时复用现有 mpv，首个文件
  替换当前项目，之后的文件追加到播放列表。
- `material-osc-zh.conf`：`gpu-next`、Vulkan、NVIDIA NVDEC 全格式硬解、
  Hyprland HDR 元数据、默认适应屏幕、中文字幕语言优先级和逐文件状态隔离。
- `autocrop.lua`：mpv 官方脚本本体；已关闭脚本自身的自动模式，只由
  material-osc 的“适应屏幕”模式开关。
- `thumbfast.lua`：进度条缩略图。
- `mpv-mpris`：由系统软件包提供，支持桌面媒体控制与 Caelestia 媒体服务。
- `input.conf`：上下键以 5% 步进调整播放器音量，范围固定为 0–100%。
- `shell.services.json`：Caelestia 系统音量与亮度均为 2% 步进，不包含任何
  USB 音响或其他硬件专用映射。

## HDR 前置条件

mpv 配置只能把视频色彩信息交给合成器；显示器、驱动和 Hyprland 输出本身仍需
启用 HDR。SDR 默认使用显示目标色彩空间，只有 PQ/HLG 视频才进入 source hint
配置段，避免把普通 SDR 视频当 HDR 直通。
