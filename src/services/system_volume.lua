local system_volume = {}

local MIN_VALUE, MAX_VALUE = 0, 100

local function clamp(value)
  return math.max(MIN_VALUE, math.min(MAX_VALUE, value))
end

local function parse_volume(output)
  local value = tostring(output and output.stdout or ""):
    match("Volume:%s*([%d%.]+)")
  value = tonumber(value)
  if not value then return nil end
  return clamp(math.floor(value * 100 + 0.5))
end

function system_volume.new(args)
  local process, msg = args.process, args.msg
  local service = {
    active = false,
    value = nil,
    committed = nil,
    pending = nil,
    operation = nil,
    on_change = nil
  }

  local function warn(text)
    if msg and msg.warn then msg.warn("system volume: " .. text) end
  end

  local function read()
    local ok, result = process:run({
      "wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"
    }, {capture_size = 4096})
    if not ok then
      warn("wpctl could not read the default output")
      return nil
    end
    return parse_volume(result)
  end

  local function run_pending()
    if service.operation or service.pending == nil or not service.active then
      return
    end
    local target = service.pending
    service.pending = nil
    local base = service.committed or target
    if math.abs(target - base) < 0.0001 then
      run_pending()
      return
    end

    local command = {
      "wpctl", "set-volume", "-l", "1", "@DEFAULT_AUDIO_SINK@",
      string.format("%d%%", target)
    }
    service.operation = process:run_async(command, {capture_size = 4096}, function(ok)
      service.operation = nil
      if not ok then warn("wpctl could not change the default output") end
      local actual = read()
      if actual then
        if service.pending == nil then
          -- Keep the optimistic integer target as the baseline. Some hardware
          -- mixers quantize the readback to a nearby value, but the UI should
          -- continue in fixed 2% steps.
          service.committed = service.value
        else
          service.committed = target
        end
      else
        service.committed = target
      end
      run_pending()
    end)
  end

  function service:start()
    if self.active then return end
    self.active = true
    local actual = read()
    self.value = actual or 0
    self.committed = self.value
  end

  function service:adjust(amount)
    self:start()
    amount = tonumber(amount) or 0
    if amount == 0 then return end
    local base = self.pending or self.value or self.committed or read() or 0
    local target = clamp(base + amount)
    self.value = target
    self.pending = target
    if self.on_change then self.on_change(target) end
    run_pending()
  end

  function service:set_on_change(callback)
    self.on_change = callback
  end

  function service:dispose()
    if self.operation then
      self.operation:cancel()
      self.operation = nil
    end
    self.pending = nil
    self.active = false
  end

  return service
end

return system_volume
