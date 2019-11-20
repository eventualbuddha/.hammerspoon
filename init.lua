hs.dockicon.hide()

-- Windowing hotkeys

hs.window.animationDuration = 0

hs.hotkey.bind({"cmd", "alt"}, "Left", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end)

hs.hotkey.bind({"cmd", "alt"}, "Right", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x + (max.w / 2)
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end)

hs.hotkey.bind({"cmd", "alt"}, "F", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w
  f.h = max.h
  win:setFrame(f)
end)

hs.hotkey.bind({"cmd", "alt"}, "C", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = (max.w - f.w) / 2
  f.y = (max.h - f.h) / 2
  win:setFrame(f)
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
  hs.reload()
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Right", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local nextScreen = screen:next()
  local max = nextScreen:frame()

  f.w = math.min(f.w, max.w)
  f.h = math.min(f.h, max.h)
  f.x = max.x + (max.w - f.w) / 2
  f.y = max.y + (max.h - f.h) / 2

  win:setFrame(f)
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Left", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local nextScreen = screen:previous()
  local max = nextScreen:frame()

  f.w = math.min(f.w, max.w)
  f.h = math.min(f.h, max.h)
  f.x = max.x + (max.w - f.w) / 2
  f.y = max.y + (max.h - f.h) / 2

  win:setFrame(f)
end)

hs.hotkey.bind({"cmd", "ctrl"}, "E", function()
  local expose = hs.expose.new()
  expose:toggleShow()
end)


-- Sends "escape" if "caps lock" is tapped, and no other keys are pressed.
-- https://stackoverflow.com/questions/41094098/hammerspoon-remap-control-key-sends-esc-when-pressed-alone-send-control-when-p

local send_escape = false
local last_mods = {}
local control_key_timer = hs.timer.delayed.new(0.1, function()
  send_escape = false
end)

hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, function(evt)
  local new_mods = evt:getFlags()
  if last_mods["ctrl"] == new_mods["ctrl"] then
    return false
  end
  if not last_mods["ctrl"] then
    last_mods = new_mods
    send_escape = true
    control_key_timer:start()
  else
    if send_escape then
      hs.eventtap.keyStroke({}, "escape")
    end
    last_mods = new_mods
    control_key_timer:stop()
  end
  return false
end):start()


hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(evt)
  send_escape = false
  return false
end):start()


-- Caffeine

local caffeine = hs.menubar.new()
function setCaffeineDisplay(state)
    if state then
        caffeine:setIcon("active@2x.png")
    else
        caffeine:setIcon("inactive@2x.png")
    end
end

function caffeineClicked()
    setCaffeineDisplay(hs.caffeinate.toggle("displayIdle"))
end

if caffeine then
    caffeine:setClickCallback(caffeineClicked)
    setCaffeineDisplay(hs.caffeinate.get("displayIdle"))
end

-- HTTP config

local http = dofile('./lib/http.lua')

http.registerURLHandler()

-- Load extra config

for file in hs.fs.dir('.') do
  if string.find(file, '.lua$') ~= nil and file ~= 'init.lua' then
    dofile(file)
  end
end

-- Startup messages

hs.notify.new({title="Hammerspoon", informativeText="Config Loaded"}):send()