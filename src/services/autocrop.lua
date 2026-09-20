local autocrop = {}

function autocrop.new(args)
  local mp, render = args.mp, args.render
  local service = {pending = nil}

  local function has_video()
    return tostring(mp.get_property("video-format", "") or "") ~= ""
  end

  local function cancel_pending()
    if service.pending then
      service.pending:kill()
      service.pending = nil
    end
  end

  local function detect()
    service.pending = nil
    if not has_video() or mp.get_property_native("keepaspect") == false or
      (mp.get_property_number("panscan", 0) or 0) <= 0.99 then
      return
    end
    -- The official autocrop.lua keeps its normal manual binding even when
    -- automatic startup is disabled. This lets the Fit-to-Screen control
    -- explicitly start detection for the current video only.
    if mp.get_property("video-crop", "") == "" then
      mp.commandv("script-binding", "autocrop/toggle_crop")
    end
  end

  function service:is_fit()
    return mp.get_property_native("keepaspect") ~= false and
      (mp.get_property_number("panscan", 0) or 0) > 0.99
  end

  function service:set_fit(enabled)
    cancel_pending()
    mp.set_property("video-aspect-override", "no")
    mp.set_property_native("keepaspect", true)
    mp.set_property_number("panscan", enabled and 1 or 0)
    if enabled then
      mp.set_property("video-crop", "")
      -- Let the video decoder settle before cropdetect is inserted.
      service.pending = mp.add_timeout(0.08, detect)
    else
      mp.set_property("video-crop", "")
    end
    if render then render() end
  end

  function service:on_file_loaded()
    cancel_pending()
    if service:is_fit() then
      service.pending = mp.add_timeout(0.12, detect)
    end
  end

  mp.register_event("file-loaded", function() service:on_file_loaded() end)
  mp.register_event("end-file", cancel_pending)
  mp.add_hook("on_unload", 20, cancel_pending)

  return service
end

return autocrop
