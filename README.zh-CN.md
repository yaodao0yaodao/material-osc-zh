# material-osc 简体中文适配

这是基于官方 `material-osc` 的简体中文与 Caelestia/Hyprland 定制版。除为 OSC
控件、设置页、上下文菜单、工具提示、通知和系统文件对话框加入简体中文外，
还整合了系统音量与亮度控制、自动裁剪、字幕偏好及逐视频状态记忆等功能。

## 使用

构建产物位于 `build/0.0.15-zh-cn/`。将其中的 `scripts/material-osc.lua` 和
`fonts/` 复制到 mpv 配置目录，并与 `thumbfast.lua` 放在同一个 `scripts/` 目录。
在 `script-opts/material-osc.conf` 中可以选择语言：

```conf
# 默认简体中文；可改为 en，或改为 auto 跟随 LANG/LC_ALL
language=zh-CN
```

媒体标题、字幕内容和流媒体元数据不会被翻译；它们由文件或播放器提供，保留
原文更适合识别内容。若遇到未覆盖的新文案，会安全地显示英文原文。

视频窗口左半边滚轮调用 Caelestia 调节显示器背光，右半边滚轮以 2% 步进调节
系统输出音量，并使用 material-osc 自己的 OSD 显示逻辑目标值。配置的 Jieli USB
音响会把逻辑 0–100% 映射到实际可用的 34–100% 硬件范围。上/下方向键以 5% 步进调节
mpv 独立的播放器音量，即使已经到 0% 或 100% 也会显示反馈。进度条拖动也
使用 material-osc 的进度条和时间提示，不显示 mpv 原生 OSD；键盘 seek 时也会
自动显示底部控件。键盘上方向键后退、下方向键前进。通过 mpv 调整的最后一个背光值会保存在
`script-opts/material-osc-brightness`，下次启动 mpv 自动恢复；mpv 退出时恢复
启动前的系统背光值。

设置页中新增“字幕标题偏好”，可按优先级输入逗号分隔的字幕标题关键词；默认值为
`特效,Simplified,chs,CN,简,ch,zh,中`。仅当 mpv 的 `sid` 选项是 `auto`、没有恢复或指定
字幕状态时，material-osc 才会在外部字幕标题中按该顺序匹配；手动选择、`sid=no` 和
watch-later 恢复的字幕都会保留，不会被覆盖。

裁剪模式、缩放参数和字幕选择会按视频单独保存到 mpv 状态目录；在播放列表中
切换视频或重新启动 mpv 后都会恢复，同时不会额外创建或修改播放进度记录。

## 构建

```bash
python -m venv .venv
.venv/bin/pip install -r requirements-build.txt
.venv/bin/python bundle.py 0.0.15-zh-cn
```
