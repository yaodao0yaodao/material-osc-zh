-- Lightweight, dependency-free translations for the material-osc interface.
-- Media titles, subtitle text, and track metadata are intentionally left alone.
local i18n = {}

local TRANSLATIONS = {
  ["Mute"] = "静音", ["Play"] = "播放", ["Pause"] = "暂停",
  ["Toggle Remaining"] = "切换剩余时间", ["Cached Time"] = "已缓存时间",
  ["Subtitles"] = "字幕", ["Hide Subtitles"] = "隐藏字幕",
  ["Show Subtitles"] = "显示字幕", ["Take Screenshot"] = "截图",
  ["Settings"] = "设置", ["Picture in Picture"] = "画中画",
  ["Exit Picture in Picture"] = "退出画中画", ["Exit PiP"] = "退出画中画",
  ["Fullscreen"] = "全屏", ["Exit Fullscreen"] = "退出全屏",
  ["Minimize"] = "最小化", ["Maximize"] = "最大化", ["Restore"] = "还原",
  ["Close"] = "关闭", ["Back"] = "返回", ["Chapters"] = "章节",
  ["Chapter"] = "章节", ["Playback Speed"] = "播放速度",
  ["Decrease Speed"] = "降低速度", ["Increase Speed"] = "提高速度",
  ["File(s)"] = "文件", ["Link"] = "链接", ["Shuffle"] = "随机播放",
  ["Turn Shuffle Off"] = "关闭随机播放", ["Loop: off"] = "循环：关闭",
  ["Loop: Current Item"] = "循环：当前项目", ["Loop: Playlist"] = "循环：播放列表",
  ["Loop: Off"] = "循环：关闭", ["Playlist"] = "播放列表",
  ["Previous"] = "上一个", ["Next"] = "下一个", ["Collapse"] = "收起",
  ["Images"] = "图像", ["Image"] = "图像", ["Original"] = "原始",
  ["Stretch"] = "拉伸", ["Fit to Screen"] = "适应屏幕", ["Crop"] = "裁剪",
  ["Aspect Override"] = "宽高比覆盖", ["Video"] = "视频", ["Audio"] = "音频",
  ["Subtitle Settings"] = "字幕设置", ["Reset Subtitle Settings"] = "重置字幕设置",
  ["Timing"] = "时间", ["Font size"] = "字体大小", ["Border"] = "描边",
  ["Color"] = "颜色", ["Font"] = "字体", ["Video Settings"] = "视频设置",
  ["Reset Video Settings"] = "重置视频设置", ["Secondary Subtitles"] = "第二字幕",
  ["Secondary Subtitle"] = "第二字幕", ["Auto Captions"] = "自动字幕",
  ["Shaders"] = "着色器", ["Clear Shaders"] = "清除着色器", ["Add"] = "添加",
  ["Off"] = "关闭", ["Keybindings"] = "按键绑定", ["Configurations"] = "配置",
  ["Copy Subtitle Text"] = "复制字幕文本", ["Share"] = "分享",
  ["Copy Media Path"] = "复制媒体路径", ["Set A–B Loop Start"] = "设置 A–B 循环起点",
  ["Set A–B Loop End"] = "设置 A–B 循环终点", ["Clear A–B Loop"] = "清除 A–B 循环",
  ["Add Bookmark"] = "添加书签", ["Hide Media Information"] = "隐藏媒体信息",
  ["Media Information"] = "媒体信息", ["Open in Browser"] = "在浏览器中打开",
  ["Reveal in File Manager"] = "在文件管理器中显示", ["Subtitles off"] = "字幕关闭",
  ["A–B loop cleared"] = "A–B 循环已清除", ["Undo"] = "撤销", ["Cancel"] = "取消",
  ["Okay"] = "确定", ["Update"] = "更新", ["Updating…"] = "更新中…",
  ["material-osc updated"] = "material-osc 已更新",
  ["material-osc update available"] = "有可用的 material-osc 更新",
  ["Disable automatic updates"] = "禁用自动更新", ["Don’t ask again"] = "不再询问",
  ["Bookmark already exists"] = "书签已存在", ["Could not save bookmark"] = "无法保存书签",
  ["Bookmark removed"] = "书签已删除", ["Bookmark name cannot be empty"] = "书签名称不能为空",
  ["Could not rename bookmark"] = "无法重命名书签", ["Bookmark renamed"] = "书签已重命名",
  ["Bookmark name:"] = "书签名称：", ["Clipboard is unavailable"] = "剪贴板不可用",
  ["Subtitle text copied"] = "字幕文本已复制", ["Share link copied"] = "分享链接已复制",
  ["Share text copied"] = "分享文本已复制", ["Timestamp copied"] = "时间戳已复制",
  ["Media link copied"] = "媒体链接已复制", ["Media path copied"] = "媒体路径已复制",
  ["mpv configuration directory is unavailable"] = "mpv 配置目录不可用",
  ["Could not create script-opts directory"] = "无法创建 script-opts 目录",
  ["Could not create material-osc.conf"] = "无法创建 material-osc.conf",
  ["Open files"] = "打开文件", ["Add files to playlist"] = "添加文件到播放列表",
  ["Open link"] = "打开链接", ["Add link to playlist"] = "添加链接到播放列表",
  ["Enter a media URL:"] = "输入媒体 URL：",
  ["Enter a media URL to add to the playlist:"] = "输入要添加到播放列表的媒体 URL：",
  ["Choose files"] = "选择文件", ["Input"] = "输入", ["Files"] = "文件",
  ["All files"] = "所有文件", ["Add subtitles"] = "添加字幕",
  ["Add secondary subtitle"] = "添加第二字幕", ["Subtitle files"] = "字幕文件",
  ["Add subtitle link"] = "添加字幕链接", ["Add secondary subtitle link"] = "添加第二字幕链接",
  ["Enter a subtitle URL:"] = "输入字幕 URL：", ["Add video shaders"] = "添加视频着色器",
  ["Shader files"] = "着色器文件", ["Add video shader link"] = "添加视频着色器链接",
  ["Enter a shader URL:"] = "输入着色器 URL：",
  ["Could not create the shader cache directory"] = "无法创建着色器缓存目录",
  ["Shader download failed"] = "着色器下载失败", ["Could not save collection"] = "无法保存彩蛋收集记录",
  ["...or just drag and drop stuff here"] = "……或将文件拖放到这里",
  ["Sponsor"] = "广告", ["Intro"] = "片头", ["Outro"] = "片尾",
  ["Interaction reminder"] = "互动提醒", ["Self promotion"] = "自我推广",
  ["Exclusive access"] = "独家内容", ["Preview"] = "预览", ["Hook / greeting"] = "开场／问候",
  ["Off-topic music"] = "无关音乐", ["Highlight"] = "精彩片段", ["Filler"] = "填充内容",
  ["Skip undone"] = "已撤销跳过", ["No SponsorBlock segment is available to vote on"] = "没有可投票的 SponsorBlock 片段",
  ["Upvote submitted"] = "赞成票已提交", ["Downvote submitted"] = "反对票已提交",
  ["Open a YouTube video before marking a segment"] = "请先打开 YouTube 视频，再标记片段",
  ["Segment start set"] = "已设置片段起点", ["Segment end set"] = "已设置片段终点",
  ["Set both segment boundaries before submitting"] = "提交前请先设置片段的起止位置",
  ["Do not skip this segment"] = "不要跳过此片段", ["Upvote this segment"] = "赞成此片段",
  ["Downvote this segment"] = "反对​​此片段", ["Undo the last skip"] = "撤销上次跳过",
  ["Set the start of a SponsorBlock segment"] = "设置 SponsorBlock 片段起点",
  ["Set end"] = "设置终点", ["Set the end of the SponsorBlock segment"] = "设置 SponsorBlock 片段终点",
  ["Cancel segment"] = "取消片段", ["Change segment category"] = "更改片段类别",
  ["Submit this segment to SponsorBlock"] = "将此片段提交到 SponsorBlock",
  ["Submitting"] = "提交中", ["Submit"] = "提交", ["Failed to load auto subtitle"] = "自动字幕加载失败",
  ["See the GitHub release for details."] = "详情请查看 GitHub 发布页。",
  ["This release does not include an update archive."] = "此版本不包含更新压缩包。",
  ["Download failed. Check your internet connection and try again."] = "下载失败，请检查网络连接后重试。",
  ["Installation failed. "] = "安装失败。", ["Could not open the material-osc repository"] = "无法打开 material-osc 仓库",
  ["Could not open the release page"] = "无法打开发布页",
}

local function language_for(value)
  value = tostring(value or "zh-CN"):lower()
  if value == "en" or value == "english" then return "en" end
  if value == "auto" then
    local locale = os.getenv("LC_ALL") or os.getenv("LC_MESSAGES") or os.getenv("LANG") or ""
    return locale:lower():match("^zh") and "zh-CN" or "en"
  end
  return "zh-CN"
end

local function translate_text(text)
  text = tostring(text or "")
  local direct = TRANSLATIONS[text]
  if direct then return direct end
  local number = text:match("^Bookmark (%d+)$")
  if number then return "书签 " .. number end
  number = text:match("^Item (%d+)$")
  if number then return "项目 " .. number end
  number = text:match("^Chapter (%d+)$")
  if number then return "章节 " .. number end
  number = text:match("^Video (%d+)$")
  if number then return "视频 " .. number end
  number = text:match("^Subtitle (%d+)$")
  if number then return "字幕 " .. number end
  number = text:match("^Audio (%d+)$")
  if number then return "音频 " .. number end
  local speed = text:match("^Temporary ([%d%.]+x)$")
  if speed then return "临时 " .. speed end
  local count, egg = text:match('^Collected (%d+) of "(.-)"$')
  if count then return string.format("已收集 %s／%s", count, egg) end
  local time = text:match("^Bookmark added at (.*)$")
  if time then return "已在 " .. time .. " 添加书签" end
  time = text:match("^Loop start · (.*)$")
  if time then return "循环开始 · " .. time end
  time = text:match("^Loop end · (.*)$")
  if time then return "循环结束 · " .. time end
  time = text:match("^Share at (.*)$")
  if time then return "分享于 " .. time end
  time = text:match("^Copy Timestamp · (.*)$")
  if time then return "复制时间戳 · " .. time end
  local inner = text:match("^SponsorBlock · (.*)$")
  if inner then return "SponsorBlock · " .. translate_text(inner) end
  inner = text:match("^Skip chapter: (.*)$")
  if inner then return "跳过章节：" .. inner end
  inner = text:match("^Skip SponsorBlock (.*)$")
  if inner then return "跳过 SponsorBlock " .. translate_text(inner) end
  inner = text:match("^(.*) skipped$")
  if inner then return translate_text(inner) .. " 已跳过" end
  inner = text:match("^(.*) segment submitted$")
  if inner then return translate_text(inner) .. "片段已提交" end
  local status = text:match("^Vote failed %(HTTP (.*)%)$")
  if status then return "投票失败（HTTP " .. status .. "）" end
  status = text:match("^Submission failed %(HTTP (.*)%)$")
  if status then return "提交失败（HTTP " .. status .. "）" end
  local reason = text:match("^Installation failed%. (.*)$")
  if reason then return "安装失败：" .. reason end
  local path = text:match("^Could not open (.*)$")
  if path then return "无法打开 " .. path end
  path = text:match("^Could not extract image track: (.*)$")
  if path then return "无法提取图像轨道：" .. path end
  path = text:match("^Could not load segments(.*)$")
  if path then return "无法加载片段" .. path end
  local value = text:match("^Video %((.*)%)$")
  if value then return "视频（" .. value .. "）" end
  value = text:match("^Audio %((.*)%)$")
  if value then return "音频（" .. value .. "）" end
  value = text:match("^Subtitles %((.*)%)$")
  if value then return "字幕（" .. value .. "）" end
  value = text:match("^(%d+%.?%d*) fps$")
  if value then return value .. " 帧/秒" end
  value = text:match("^(%d+) Kbps$")
  if value then return value .. " 千比特/秒" end
  value = text:match("^(%d+%.?%d*) Hz$")
  if value then return value .. " 赫兹" end
  return text
end

function i18n.new(args)
  args = args or {}
  local language = args.language
  local service = {}
  function service:language()
    local value = type(language) == "function" and language() or language
    return language_for(value)
  end
  function service:translate(value)
    if self:language() == "en" then return tostring(value or "") end
    return translate_text(value)
  end
  return service
end

i18n.translate = translate_text

return i18n
