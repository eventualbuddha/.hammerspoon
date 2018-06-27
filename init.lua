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

-- Load extra config

for file in hs.fs.dir('.') do
  if string.find(file, '.lua$') ~= nil and file ~= 'init.lua' then
    dofile(file)
  end
end

-- Startup messages

hs.notify.new({title="Hammerspoon", informativeText="Config Loaded"}):send()