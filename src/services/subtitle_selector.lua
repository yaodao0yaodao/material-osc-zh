local subtitle_selector = {}

local function trim(value)
  return tostring(value or ""):match("^%s*(.-)%s*$") or ""
end

local function lower(value)
  return trim(value):lower()
end

local function escape_pattern(value)
  return tostring(value):gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
end

local function is_short_ascii_code(value)
  return #value <= 3 and value:match("^[a-z0-9]+$") ~= nil
end

local function matches_title(title, keyword)
  title, keyword = lower(title), lower(keyword)
  if keyword == "" then return false end
  if not is_short_ascii_code(keyword) then
    return title:find(keyword, 1, true) ~= nil
  end
  -- Lua frontier patterns provide the same boundary behavior as the Android
  -- implementation's negative lookaround regex for short language codes.
  return title:find("%f[%w]" .. escape_pattern(keyword) .. "%f[%W]") ~= nil
end

local function keywords(value)
  local result = {}
  for raw in tostring(value or ""):gmatch("[^,]+") do
    local keyword = lower(raw)
    if keyword ~= "" then result[#result + 1] = keyword end
  end
  return result
end

local function title_match(tracks, ordered)
  local candidates = {}
  for _, track in ipairs(tracks) do candidates[#candidates + 1] = track end
  local matched = false
  for _, keyword in ipairs(ordered) do
    local matches = {}
    for _, track in ipairs(candidates) do
      if matches_title(track.title, keyword) then
        matches[#matches + 1] = track
      end
    end
    if #matches > 0 then
      candidates, matched = matches, true
    end
  end
  return matched and candidates[1] or nil
end

local function media_key(mp)
  return tostring(mp.get_property("path", "") or
    mp.get_property("filename", "") or "")
end

function subtitle_selector.new(args)
  local mp, msg = args.mp, args.msg
  local service = {
    preferences = args.preferences or "",
    generation = 0,
    attempts = 0,
    selected = false,
    timer = nil,
    manual = false,
    preloaded = false,
    start_sid = "auto",
    media_path = ""
  }

  local function cancel_timer()
    if service.timer then service.timer:kill(); service.timer = nil end
  end

  local function tracks()
    local value = mp.get_property_native("track-list", {}) or {}
    local result = {}
    for _, track in ipairs(value) do
      if track.type == "sub" then result[#result + 1] = track end
    end
    return result
  end

  local function choose(items)
    local ordered = keywords(service.preferences)
    if #ordered == 0 then return nil end
    local external = {}
    for _, track in ipairs(items) do
      if track.external == true then external[#external + 1] = track end
    end
    return title_match(#external > 0 and external or items, ordered)
  end

  local function run(generation)
    service.timer = nil
    if generation ~= service.generation or service.selected or service.manual then
      return
    end
    local items = tracks()
    if #items == 0 then
      if service.attempts < 20 then
        service.attempts = service.attempts + 1
        service.timer = mp.add_timeout(0.05, function() run(generation) end)
      end
      -- Keep waiting for a later track-list update when a demuxer exposes
      -- subtitle tracks after the retry window (common with network media).
      return
    end
    service.selected = true
    local selected = choose(items)
    if not selected or selected.id == nil then return end
    local current = mp.get_property_number("sid", 0) or 0
    if current == tonumber(selected.id) then return end
    mp.set_property_number("sid", tonumber(selected.id))
    if msg and msg.info then
      msg.info("subtitle selector: selected " .. tostring(selected.title or
        selected.lang or selected.id))
    end
  end

  function service:set_preferences(value)
    self.preferences = tostring(value or "")
  end

  function service:on_start_file()
    -- Capture mpv's selection option before file loading. A numeric value or
    -- `no` means the caller supplied/restored an explicit choice (including
    -- watch-later); only `auto` is eligible for the preference fallback.
    cancel_timer()
    self.generation = self.generation + 1
    self.selected = true -- Ignore track-list notifications during loading.
    self.start_sid = mp.get_property("options/sid", "auto") or "auto"
    self.media_path = media_key(mp)
    self.preloaded = false
  end

  function service:mark_manual(item)
    self.manual = true
    cancel_timer()
    -- file_state captures the final choice on unload, including keyboard and
    -- IPC changes. A second UI-only cache would restore stale selections.
  end

  function service:on_preloaded()
    -- mpv invokes this synchronous hook after demuxing but before its own
    -- default track selection. Restore a per-file choice (or apply the title
    -- preference) here so the first rendered frame does not briefly show a
    -- different subtitle track.
    cancel_timer()
    self.preloaded = true
    self.generation = self.generation + 1
    self.attempts, self.selected, self.manual = 0, false, false
    self.media_path = media_key(mp)

    -- Read after file_state's priority-40 restore, not at start-file where the
    -- previous video's track state can still be visible.
    self.start_sid = mp.get_property("options/sid", "auto") or "auto"

    local items = tracks()
    if #items == 0 then
      if tostring(self.start_sid):lower() ~= "auto" then
        self.selected = true
      end
      return
    end

    if tostring(self.start_sid):lower() ~= "auto" then
      self.selected = true
      return
    end

    -- Keep the automatic selection eligible for the post-load fallback. This
    -- lets late external subtitle tracks replace an embedded match, while the
    -- preloaded selection already prevents a visible default-track flash.
    local selected = choose(items)
    if selected and selected.id ~= nil then
      mp.set_property_number("sid", tonumber(selected.id))
      if msg and msg.info then
        msg.info("subtitle selector: selected " .. tostring(selected.title or
          selected.lang or selected.id))
      end
    end
  end

  function service:on_file_loaded()
    cancel_timer()
    if self.preloaded then
      self.preloaded = false
      self.media_path = media_key(mp)
      if self.selected then return end
      local generation = self.generation
      self.timer = mp.add_timeout(0.15, function() run(generation) end)
      return
    end
    self.generation = self.generation + 1
    self.attempts, self.selected, self.manual = 0, false, false
    self.media_path = media_key(mp)
    if tostring(self.start_sid):lower() ~= "auto" then
      self.selected = true
      return
    end
    local generation = self.generation
    self.timer = mp.add_timeout(0.15, function() run(generation) end)
  end

  function service:on_tracks_changed()
    if self.selected or self.manual or self.timer then return end
    local generation = self.generation
    self.timer = mp.add_timeout(0.05, function() run(generation) end)
  end

  function service:dispose()
    cancel_timer()
  end

  mp.add_hook("on_unload", 20, function()
    cancel_timer()
    service.generation = service.generation + 1
    service.selected = true
  end)

  return service
end

return subtitle_selector
