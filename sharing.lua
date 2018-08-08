local log = hs.logger.new('sharing', 'debug')

-- AirDrop Sharing

function shareFromFrontmostApplication()
	local app = hs.application.frontmostApplication()
	local appID = app:bundleID()
	local appName = app:name()
	local applescript
	local isFileURL = false

	log.f("Attempting to share from %s (%s)", appName, appID)
	if appID == "com.google.Chrome" then
		applescript = string.format("tell application \"%s\" to get URL of active tab of front window as string", appName)
	elseif appID == "com.apple.Safari" then
		applescript = string.format("tell application \"%s\" to return URL of front document as string", appName)
	elseif appID == "com.apple.finder" then
		applescript = string.format("tell application \"%s\" to get URL of (selection as alias)", appName)
		isFileURL = true
  else
    hs.notify.new({title="Unable to Share", informativeText=string.format("I don't know how to share from \"%s\"", appName)}):send()
		return
	end

	local success, output, raw = hs.osascript.applescript(applescript)

	if success then
		local shareSheet = hs.sharing.newShare("com.apple.share.AirDrop.send")
		local url = hs.sharing.URL(output, isFileURL)

		shareSheet:shareItems({ url })
	end
end

hs.hotkey.bind({"cmd", "ctrl", "alt"}, "Up", shareFromFrontmostApplication)
