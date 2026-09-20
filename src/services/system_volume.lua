local system_volume = {}

local MIN_VALUE, MAX_VALUE = 0, 100
local USB_SPEAKER_FLOOR = 0.34
local USB_SPEAKER_PATTERN =
  'node.name = "alsa_output.usb-Jieli_Technology_USB_Composite_Device_'
local HELPER = "/home/lillia/.local/bin/usb-speaker-volume"

local function clamp(value)
  return math.max(MIN_VALUE, math.min(MAX_VALUE, value))
end

local function parse_physical_volume(output)
  local value = tostring(output and output.stdout or ""):
    match("Volume:%s*([%d%.]+)")
  value = tonumber(value)
  if not value then return nil end
  return math.max(0, math.min(1, value))
end

local function to_logical(value, mapped)
  local logical = mapped and
    (value - USB_SPEAKER_FLOOR) / (1 - USB_SPEAKER_FLOOR) * 100 or
    value * 100
  -- PipeWire hardware controls are quantized. Round the readback to an
  -- integer logical percentage so a 2% wheel step cannot become 51%, 53%,
  -- etc. merely because the physical value was rounded by the USB mixer.
  return clamp(math.floor(logical + 0.5))
end

function system_volume.new(args)
  local process, msg = args.process, args.msg
  local helper = args.helper or HELPER
  local service = {
    active = false,
    value = nil,
    committed = nil,
    pending = nil,
    operation = nil,
    mapped = false,
    on_change = nil
  }

  local function warn(text)
    if msg and msg.warn then msg.warn("system volume: " .. text) end
  end

  local function is_mapped_sink()
    local ok, result = process:run({
      "wpctl", "inspect", "@DEFAULT_AUDIO_SINK@"
    }, {capture_size = 8192})
    if not ok then return false end
    return tostring(result and result.stdout or ""):
      find(USB_SPEAKER_PATTERN, 1, true) ~= nil
  end

  local function read()
    local ok, result = process:run({
      "wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"
    }, {capture_size = 4096})
    if not ok then
      warn("wpctl could not read the default output")
      return nil
    end
    local physical = parse_physical_volume(result)
    if not physical then return nil end
    local mapped = is_mapped_sink()
    return {
      value = to_logical(physical, mapped),
      mapped = mapped
    }
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

    -- The helper is the single source of truth for the USB speaker's
    -- nonlinear 0..100% logical range (physical 34..100%). For other sinks it
    -- falls back to normal PipeWire percentage handling. Sending `set` also
    -- avoids turning a logical 0% into a physical mute on this speaker.
    local command = {
      helper, "set", string.format("%.6f%%", target)
    }
    service.operation = process:run_async(command, {capture_size = 4096}, function(ok)
      service.operation = nil
      if not ok then warn("volume helper could not change the default output") end
      local actual = read()
      if actual then
        service.mapped = actual.mapped
        if service.pending == nil then
          -- Keep the optimistic logical target as the baseline. The USB
          -- mixer may report a nearby physical value after quantization;
          -- feeding that value back would make a fixed 2% step appear as an
          -- odd or drifting percentage in the OSD.
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
    self.value = actual and actual.value or 0
    self.committed = self.value
    self.mapped = actual and actual.mapped or false
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
