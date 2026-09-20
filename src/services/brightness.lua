local brightness = {}

local STEP_PERCENT = 2
local MIN_VALUE, MAX_VALUE = 0, 1

local function trim(value)
  return tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function parse_value(value)
  if type(value) == "number" then
    return value >= MIN_VALUE and value <= MAX_VALUE and value or nil
  end
  local text = trim(value)
  local parsed = text:match("brightness to%s+([%d%.]+)") or
    text:match("([%d%.]+)%s*$")
  parsed = tonumber(parsed)
  return parsed and parsed >= MIN_VALUE and parsed <= MAX_VALUE and parsed or nil
end

local function format_value(value)
  return string.format("%.4f", math.max(MIN_VALUE, math.min(MAX_VALUE, value)))
end

function brightness.new(args)
  local process, filesystem, mp, msg =
    args.process, args.filesystem, args.mp, args.msg
  local service = {}
  local on_change = args.on_change
  local state = {
    active = false,
    original = nil,
    last = nil,
    pending_target = nil,
    operation = nil
  }

  local state_path = mp.command_native({
    "expand-path", "~~/script-opts/material-osc-brightness"
  })
  -- Shutdown restoration is detached so mpv can exit cleanly. Serialize it
  -- with the next startup/read or adjustment to avoid a quick restart racing
  -- the previous restore command.
  local lock_path = state_path .. ".lock"

  local function warn(text)
    if msg and msg.warn then msg.warn("brightness: " .. text) end
  end

  local function read_saved()
    local value = parse_value(filesystem:read(state_path))
    return value
  end

  local function save(value)
    if not value then return end
    if not filesystem:write_atomic(state_path, format_value(value)) then
      warn("could not save the last mpv brightness")
    end
  end

  local function set_value(value)
    local ok, result = process:run({
      "flock", "-x", lock_path, "caelestia", "shell", "brightness", "set",
      format_value(value)
    }, {capture_size = 4096})
    if not ok then
      warn("Caelestia brightness restore failed")
      return false
    end
    -- Caelestia acknowledges the command before the monitor state catches
    -- up, so its stdout may still contain the previous brightness. The value
    -- requested here is the reliable target for this session.
    return value
  end

  local function restore_value(value)
    if not value then return end
    -- mpv's `run` command is deliberately detached. A regular subprocess is
    -- terminated as mpv exits, which would leave the monitor at the mpv value.
    mp.commandv("run", "flock", "-x", lock_path, "caelestia", "shell",
      "brightness", "set", format_value(value))
  end

  function service:start()
    if state.active then return end
    state.active = true

    local ok, result = process:run({
      "flock", "-x", lock_path, "caelestia", "shell", "brightness", "get"
    }, {capture_size = 4096})
    if not ok then
      state.active = false
      warn("Caelestia brightness service is unavailable")
      return
    end

    state.original = parse_value(result and result.stdout)
    if not state.original then
      state.active = false
      warn("could not read the current system brightness")
      return
    end

    local saved = read_saved()
    if saved and math.abs(saved - state.original) > 0.005 then
      local restored = set_value(saved)
      if restored then state.last = restored end
    else
      state.last = saved or state.original
    end
  end

  local function run_pending()
    if state.operation or not state.pending_target or not state.active then
      return
    end
    local target = state.pending_target
    state.pending_target = nil
    state.operation = process:run_async({
      "flock", "-x", lock_path, "caelestia", "shell", "brightness", "set",
      format_value(target)
    }, {capture_size = 4096}, function(ok, result)
      state.operation = nil
      if ok then
        -- Do not parse stdout here: Caelestia's set command can report the
        -- previous value while the asynchronous monitor update is pending.
        if not state.pending_target then
          state.last = target
          save(target)
        end
      else
        warn("Caelestia brightness change failed")
      end
      run_pending()
    end)
  end

  function service:adjust(steps)
    if not state.active then return end
    steps = tonumber(steps) or 0
    if steps == 0 then return end
    steps = math.floor(steps)
    local base = state.pending_target or state.last or state.original
    if not base then return end
    local target = math.max(MIN_VALUE, math.min(MAX_VALUE,
      base + steps * STEP_PERCENT / 100))
    if math.abs(target - base) < 0.0001 then
      -- Keep boundary input visible: trying to go past 0%/100% should still
      -- refresh the current-value OSD even though no system write is needed.
      if on_change then on_change(base) end
      return
    end
    -- Keep a local, optimistic target. This makes rapid wheel input feel as
    -- immediate as volume even while Caelestia processes the previous value.
    state.last, state.pending_target = target, target
    save(target)
    if on_change then on_change(target) end
    run_pending()
  end

  function service:set_on_change(callback)
    on_change = callback
  end

  function service:dispose()
    if not state.active then return end
    state.pending_target = nil
    if state.operation then
      state.operation:cancel()
      state.operation = nil
    end
    if state.original then restore_value(state.original) end
    state.active = false
  end

  return service
end

return brightness
