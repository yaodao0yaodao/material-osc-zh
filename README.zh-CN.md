# material-osc 简体中文适配

这是基于官方 `material-osc` 的本地 `feature/zh-cn` 分支。官方仓库目前没有
语言包、翻译目录或开放的 Pull Request；本分支在不改动播放逻辑的前提下，
为 OSC 控件、设置页、上下文菜单、工具提示、通知和系统文件对话框加入简体中文。

## 使用

构建产物位于 `build/0.0.13-zh-cn/`。将其中的 `scripts/material-osc.lua` 和
`fonts/` 复制到 mpv 配置目录，并与 `thumbfast.lua` 放在同一个 `scripts/` 目录。
在 `script-opts/material-osc.conf` 中可以选择语言：

```conf
# 默认简体中文；可改为 en，或改为 auto 跟随 LANG/LC_ALL
language=zh-CN
```

媒体标题、字幕内容和流媒体元数据不会被翻译；它们由文件或播放器提供，保留
原文更适合识别内容。若遇到未覆盖的新文案，会安全地显示英文原文。

## 构建

```bash
python -m venv .venv
.venv/bin/pip install -r requirements-build.txt
.venv/bin/python bundle.py 0.0.13-zh-cn
```
