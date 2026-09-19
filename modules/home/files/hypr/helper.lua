-- Shared helpers for Hyprland Lua configuration (standalone, no omarchy deps).

o = o or {}

local function shell_quote(value)
  return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

o.shell_quote = shell_quote

local function file_exists(path)
  local file = io.open(path, "r")
  if file then
    file:close()
    return true
  end

  return false
end

function o.cmd_present(command)
  if command:find("/", 1, true) then
    return file_exists(command)
  end

  local path = os.getenv("PATH") or "/usr/local/bin:/usr/bin"
  for directory in (path .. ":"):gmatch("([^:]*):") do
    if file_exists((directory ~= "" and directory or ".") .. "/" .. command) then
      return true
    end
  end

  return false
end

function o.cmd_missing(command)
  return not o.cmd_present(command)
end

-- First word of a shell command, for presence checks.
local function bin_of(command)
  return tostring(command):match("^%s*(%S+)")
end

function o.bind(keys, description, dispatcher, options)
  local opts = options or {}

  if description then
    opts.description = description
  end

  -- { tui = "btop" } -> run in terminal.
  if type(dispatcher) == "table" and dispatcher.tui then
    dispatcher = o.launch("kitty -- " .. dispatcher.tui)
  end

  if type(dispatcher) == "string" then
    local bin = bin_of(dispatcher)
    -- Allow shell built-ins / wrappers that don't resolve in PATH.
    if bin and bin ~= "command" and o.cmd_missing(bin) then
      print("[hypr] skip bind '" .. keys .. "' (" .. description .. "): missing binary '" .. bin .. "'")
      return nil
    end
    dispatcher = hl.dsp.exec_cmd(dispatcher)
  end

  return hl.bind(keys, dispatcher, opts)
end

function o.rebind(keys, description, dispatcher, options)
  hl.unbind(keys)
  o.bind(keys, description, dispatcher, options)
end

function o.launch(command)
  return "uwsm-app -- " .. command
end

function o.exec_on_start(command)
  hl.on("hyprland.start", function()
    hl.exec_cmd(command)
  end)
end

function o.launch_on_start(command)
  o.exec_on_start(o.launch(command))
end

function o.window(match, rules)
  rules.match = rules.match or {}

  if type(match) == "string" then
    rules.match.class = match
  else
    for key, value in pairs(match) do
      rules.match[key] = value
    end
  end

  return hl.window_rule(rules)
end
