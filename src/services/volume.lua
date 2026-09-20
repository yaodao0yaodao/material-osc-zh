local volume = {}

local MIN_VALUE, WHEEL_MAX_VALUE = 0, 100

local function clamp(value, minimum, maximum)
  return math.max(minimum, math.min(maximum, value))
end

function volume.new(args)
  local mp, properties = args.mp, args.properties
  local service = {}
  local on_change = args.on_change
  local optimistic_target = nil

  local function current_value()
    if optimistic_target ~= nil then return optimistic_target end
    local value = properties and properties.volume or
      mp.get_property_number("volume", 0)
    return tonumber(value) or 0
  end

  local function publish(value)
    optimistic_target = value
    if properties then properties.volume = value end
    if on_change then on_change(value) end
    -- Direct property writes avoid mpv's native OSD. The material-osc OSD is
    -- rendered from the optimistic target above, without waiting for mpv's
    -- asynchronous property observer.
    mp.set_property_number("volume", value)
  end

  function service:adjust(amount)
    amount = tonumber(amount) or 0
    if amount == 0 then return end
    local base = current_value()
    local target = clamp(base + amount, MIN_VALUE, WHEEL_MAX_VALUE)
    if math.abs(target - base) <= 0.0001 then
      -- Repeated input at 0%/100% is still meaningful feedback. Refresh the
      -- OSD without writing the unchanged value back to mpv.
      if on_change then on_change(base) end
      return
    end
    publish(target)
  end

  function service:set(value)
    value = tonumber(value)
    if not value then return end
    local maximum = math.max(WHEEL_MAX_VALUE,
      tonumber(args.max_value and args.max_value()) or WHEEL_MAX_VALUE)
    local target = clamp(value, MIN_VALUE, maximum)
    if math.abs(target - current_value()) <= 0.0001 then return end
    publish(target)
  end

  function service:observe(value)
    value = tonumber(value)
    if not value then return end
    if optimistic_target ~= nil and
      math.abs(value - optimistic_target) <= 0.0001 then
      optimistic_target = nil
    end
  end

  function service:set_on_change(callback)
    on_change = callback
  end

  function service:reset()
    optimistic_target = nil
  end

  return service
end

return volume
