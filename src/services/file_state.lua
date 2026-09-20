-- Persist crop and subtitle choices independently of playback progress.
-- All managed options remain file-local, so an unseen file starts from mpv's
-- configured defaults or its existing watch-later values.
local file_state = {}

local names = {
  "keepaspect", "panscan", "video-crop", "video-aspect-override",
  "video-zoom", "video-pan-x", "video-pan-y", "video-scale-x", "video-scale-y",
  "sid", "secondary-sid", "sub-visibility", "secondary-sub-visibility"
}

function file_state.new(args)
  local mp = args.mp
  local store = args.store
  local cache = store and store:load() or {}
  if type(cache) ~= "table" then cache = {} end
  local service = {cache = cache, path = nil, loaded = false, initial = {}}

  mp.add_hook("on_load", 30, function()
    service.loaded = false
    service.path = mp.get_property("path", "")
    service.initial = {}
    -- Watch-later options have already been loaded at this point. Preserve
    -- those values, while arranging for later UI/keyboard changes to reset.
    for _, name in ipairs(names) do
      local value = mp.get_property_native("options/" .. name)
      if value ~= nil then
        service.initial[name] = value
        mp.set_property_native("file-local-options/" .. name, value)
      end
    end
  end)

  mp.add_hook("on_preloaded", 40, function()
    local saved = service.cache[service.path]
    for _, name in ipairs(names) do
      -- Persisted material-osc state wins, while missing fields still inherit
      -- mpv's watch-later state (for example a subtitle choice saved earlier).
      local value = saved and saved[name]
      if value == nil then value = service.initial[name] end
      if value ~= nil then
        mp.set_property_native("file-local-options/" .. name, value)
      end
    end
  end)

  mp.register_event("file-loaded", function() service.loaded = true end)
  mp.add_hook("on_unload", 30, function()
    if service.loaded and service.path and service.path ~= "" then
      local values = {}
      for _, name in ipairs(names) do
        values[name] = mp.get_property_native(name)
      end
      service.cache[service.path] = values
      if store then store:save(service.cache) end
    end
    service.loaded = false
  end)
  return service
end

return file_state
