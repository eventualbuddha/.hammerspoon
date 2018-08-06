local log = hs.logger.new('square', 'debug')

log.i('Loading Square config')


--- UTC Clock in Menubar ---

local utcMenuBar = hs.menubar.new()

function updateMenuBarWithCurrentTime(menubar)
  menubar:setTitle(os.date("!%H:%M UTC"))
end

-- set initial value
updateMenuBarWithCurrentTime(utcMenuBar)

-- update every second
hs.timer.doEvery(1, function()
  updateMenuBarWithCurrentTime(utcMenuBar)
end)

--- END UTC Clock in Menubar ---


--- HTTP Handler ---

local http = dofile('./lib/http.lua')

http.registerURLHandler()
http.registerShortenerHost('go.squareup.com')
http.openHostWithBrowser('www.smartrecruiters.com', http.chromeBundleId)

--- END HTTP Handler ---
